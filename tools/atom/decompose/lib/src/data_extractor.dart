import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'data_models.dart';

/// SDK scalar / container types that are NEVER a relation target.
const _kScalarTypes = {
  'String', 'int', 'double', 'num', 'bool', 'dynamic', 'Object', 'DateTime',
  'Duration', 'Uri', 'Map', 'List', 'Set', 'Iterable', 'void', 'Null',
};

/// Decompose one data module [sourcePath] into entities — one per class / enum.
/// AST-only, read-only. When [only] is set, decompose just that entity.
DataModuleDecomposition decomposeData(
  String sourcePath, {
  String? only,
  String? moduleName,
}) {
  final unit = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;

  final entities = <DataEntity>[];
  for (final d in unit.declarations) {
    if (d is ClassDeclaration) {
      if (only != null && d.name.lexeme != only) continue;
      final e = _entityOf(d);
      if (e != null) entities.add(e);
    } else if (d is EnumDeclaration) {
      if (only != null && d.name.lexeme != only) continue;
      entities.add(_enumOf(d));
    }
  }

  return DataModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    entities: entities,
  );
}

DataEntity _enumOf(EnumDeclaration d) {
  final consts = d.constants.map((c) => c.name.lexeme).toList();
  return DataEntity(
    entity: d.name.lexeme,
    kind: 'enum',
    fields: [
      for (final c in consts)
        DataField(name: c, type: d.name.lexeme, required: false),
    ],
    invariants: ['a closed set of ${consts.length} values: ${consts.join(' · ')}'],
  );
}

DataEntity? _entityOf(ClassDeclaration d) {
  // A DATA class = one that carries fields (a record). Skip pure-behaviour
  // classes (notifiers/services with no data fields) — those are logic atoms.
  final fieldDecls = d.members.whereType<FieldDeclaration>().toList();
  final instanceFields =
      fieldDecls.where((f) => !f.isStatic).toList();
  if (instanceFields.isEmpty) return null;

  final methods = d.members.whereType<MethodDeclaration>().toList();
  final ctors = d.members.whereType<ConstructorDeclaration>().toList();

  // Constructor param facts: required + defaults, keyed by the field name.
  final requiredParams = <String>{};
  final defaults = <String, String>{};
  var hasConstCtor = false;
  for (final c in ctors) {
    if (c.constKeyword != null) hasConstCtor = true;
    for (final param in c.parameters.parameters) {
      final field = _fieldParamName(param);
      if (field == null) continue;
      final inner = param is DefaultFormalParameter ? param.parameter : param;
      if (inner.isRequired || (inner.isNamed && inner.requiredKeyword != null)) {
        requiredParams.add(field);
      }
      if (param is DefaultFormalParameter && param.defaultValue != null) {
        defaults[field] = param.defaultValue!.toSource();
      }
      // positional-required (no default, not named) → required.
      if (inner is SimpleFormalParameter || inner is FieldFormalParameter) {
        if (!inner.isNamed && !(param is DefaultFormalParameter && param.defaultValue != null)) {
          requiredParams.add(field);
        }
      }
    }
  }

  // Stored fields.
  final fields = <DataField>[];
  final relations = <DataRelation>[];
  var anyMutable = false;
  var allFinal = true;
  for (final fd in instanceFields) {
    final isFinal = fd.fields.isFinal || fd.fields.isConst;
    if (!isFinal) {
      anyMutable = true;
      allFinal = false;
    }
    final typeSrc = fd.fields.type?.toSource() ?? 'dynamic';
    final nullable = typeSrc.trimRight().endsWith('?');
    final coll = RegExp(r'^(List|Set|Map|Iterable)\b').hasMatch(typeSrc);
    for (final v in fd.fields.variables) {
      final name = v.name.lexeme;
      final req = requiredParams.contains(name) ||
          (!nullable && !defaults.containsKey(name) && v.initializer == null);
      fields.add(DataField(
        name: name,
        type: typeSrc,
        required: req,
        nullable: nullable,
        collection: coll,
        defaultValue: defaults[name],
      ));
      final rel = _relationOf(name, typeSrc);
      if (rel != null) relations.add(rel);
    }
  }

  // Derived fields (getters) — data computed at read (regex on a name field, …).
  for (final m in methods.where((m) => m.isGetter)) {
    fields.add(DataField(
      name: m.name.lexeme,
      type: m.returnType?.toSource() ?? 'dynamic',
      required: false,
      derived: true,
    ));
  }

  // Decoders + behaviour.
  final decoders = <String>[];
  var tolerant = false;
  for (final c in ctors) {
    final n = c.name?.lexeme ?? '';
    if (n == 'fromJson' || n == 'fromMap') {
      decoders.add(n);
      if (_isTolerant(c.body)) tolerant = true;
    }
  }
  final behaviour = <String>[];
  for (final m in methods) {
    if (m.isGetter || m.isSetter || m.isOperator) continue;
    final n = m.name.lexeme;
    if (n == 'toJson' || n == 'toMap' || n == 'fromJson') {
      decoders.add(n);
      if (n == 'fromJson' && _isTolerant(m.body)) tolerant = true;
      continue;
    }
    if (n == 'copyWith' || n == 'toString' || n == '==' || n == 'hashCode') continue;
    behaviour.add(n);
  }

  final kind = anyMutable
      ? 'mutable'
      : (hasConstCtor ? 'const-value' : (allFinal ? 'value' : 'value'));

  return DataEntity(
    entity: d.name.lexeme,
    kind: kind,
    fields: fields,
    relations: relations,
    decoders: decoders.toSet().toList(),
    behaviour: behaviour,
    tolerantDecoder: tolerant,
    required: fields.where((f) => f.required).map((f) => f.name).toList(),
    defaults: defaults,
  );
}

String? _fieldParamName(FormalParameter param) {
  final inner = param is DefaultFormalParameter ? param.parameter : param;
  if (inner is FieldFormalParameter) return inner.name.lexeme;
  return null;
}

DataRelation? _relationOf(String field, String typeSrc) {
  // strip nullability + unwrap a single container to its element type.
  var t = typeSrc.replaceAll('?', '').trim();
  final coll = RegExp(r'^(List|Set|Iterable)<').hasMatch(t);
  final m = RegExp(r'^(?:List|Set|Iterable)<(.+)>$').firstMatch(t);
  if (m != null) t = m.group(1)!.trim();
  final mapM = RegExp(r'^Map<[^,]+,\s*(.+)>$').firstMatch(t);
  if (mapM != null) t = mapM.group(1)!.trim();
  final base = t.replaceAll('?', '').trim();

  // A foreign key: a String named like an id.
  if (base == 'String' && RegExp(r'(^|[a-z])(sku|Id|id)$').hasMatch(field)) {
    return DataRelation(field: field, ref: 'catalog', kind: 'fk', collection: coll);
  }
  if (_kScalarTypes.contains(base) || base.isEmpty) return null;
  if (!RegExp(r'^[A-Z]').hasMatch(base)) return null;
  // A model / enum reference. (enum vs class is refined by convention only.)
  final kind = RegExp(r'(System|Type|Role|Kind|State|Status|Mode)$').hasMatch(base)
      ? 'enum'
      : 'embed';
  return DataRelation(field: field, ref: base, kind: kind, collection: coll);
}

/// A decoder is "tolerant" when it degrades malformed input (?? fallback, a
/// try/catch, or a `... ?? default`) instead of throwing — a documented debt.
bool _isTolerant(FunctionBody body) {
  final src = body.toSource();
  return src.contains('??') ||
      src.contains('catch') ||
      RegExp(r'\bas\s+\w+\?').hasMatch(src) ||
      src.contains('tryParse');
}
