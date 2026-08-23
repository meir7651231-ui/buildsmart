// The data-atom model produced by the data decomposer (DECOMP-DEPTH phase D).
// Where the logic decomposer opens a FUNCTION (algorithm), this opens an ENTITY
// (a catalog / schema / seed record) field-by-field.
//
//   Layer 1 · עצם     (object)      — fields: name · type · required · default ·
//                                     nullable · collection · DERIVED (a getter,
//                                     not a stored field — data computed at read).
//   Layer 2 · חיבורים (connections) — relations: FK (a `*sku*`/`*id*` reference) ·
//                                     embed (owns a model type) · enum/ref.
//   Layer 3 · התנהגות (behaviour)   — the lifecycle: decoders (fromJson/toJson,
//                                     with a tolerance note) + the record's own
//                                     methods (predicates / derivations).
//   Plus [DataEntity.contract] — the shape a VALID record satisfies (required
//   fields · defaults · invariants).
//
// Read-only: the decomposer documents debt (a homeless price, a string
// classifier that belongs in schema, a tolerant decoder with no validation), it
// never refactors.

/// One field of an entity.
class DataField {
  const DataField({
    required this.name,
    required this.type,
    required this.required,
    this.nullable = false,
    this.collection = false,
    this.defaultValue,
    this.derived = false,
    this.isStatic = false,
  });

  final String name;
  final String type;

  /// A required constructor argument (`required this.x`) or a non-nullable field
  /// with no default — a record cannot exist without it.
  final bool required;

  final bool nullable;

  /// The type is a `List`/`Set`/`Map`.
  final bool collection;

  /// The literal default from the constructor (`this.x = 40`), else null.
  final String? defaultValue;

  /// A GETTER, not a stored field — the value is DERIVED at read time (e.g.
  /// `connectionSizes` regexes it out of `nameHe`). Data wearing a method coat.
  final bool derived;

  final bool isStatic;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'type': type,
        'required': required,
        if (nullable) 'nullable': true,
        if (collection) 'collection': true,
        if (defaultValue != null) 'default': defaultValue,
        if (derived) 'derived': true,
      };
}

/// A relation from an entity to another entity / enum.
class DataRelation {
  const DataRelation({
    required this.field,
    required this.ref,
    required this.kind,
    this.collection = false,
  });

  final String field;

  /// The referenced type / entity.
  final String ref;

  /// 'fk' (a `*sku*`/`*id*` foreign key) · 'embed' (owns a model value) ·
  /// 'enum' (an enum reference) · 'ref' (a plain model reference).
  final String kind;
  final bool collection;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'field': field,
        'ref': ref,
        'kind': kind,
        if (collection) 'collection': true,
      };
}

/// One decomposed entity — a data class (catalog / schema / seed record).
class DataEntity {
  DataEntity({
    required this.entity,
    required this.kind,
    List<DataField>? fields,
    List<DataRelation>? relations,
    List<String>? decoders,
    List<String>? behaviour,
    List<String>? required,
    Map<String, String>? defaults,
    List<String>? invariants,
    this.tolerantDecoder = false,
  })  : fields = fields ?? <DataField>[],
        relations = relations ?? <DataRelation>[],
        decoders = decoders ?? <String>[],
        behaviour = behaviour ?? <String>[],
        required = required ?? <String>[],
        defaults = defaults ?? <String, String>{},
        invariants = invariants ?? <String>[];

  final String entity;

  /// 'const-value' (an immutable const record — a catalog row / schema) ·
  /// 'value' (final fields, runtime-built) · 'mutable' (has non-final fields) ·
  /// 'enum'.
  final String kind;

  final List<DataField> fields;
  final List<DataRelation> relations;

  /// Present decoders — `fromJson` / `toJson` / `fromMap` / `toMap`.
  final List<String> decoders;

  /// The record's own methods (predicates / derivations) — the behaviour a
  /// valid record carries (e.g. VerifiedSpec.compatibleWith).
  final List<String> behaviour;

  /// The contract: the required fields, the defaults, and the invariants.
  final List<String> required;
  final Map<String, String> defaults;
  final List<String> invariants;

  /// True when a decoder swallows malformed input (falls back instead of
  /// throwing) — a documented debt: a corrupt record decodes silently.
  final bool tolerantDecoder;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'entity': entity,
        'kind': kind,
        'object': <String, dynamic>{
          'fields': fields.map((f) => f.toJson()).toList(),
        },
        'connections': <String, dynamic>{
          'relations': relations.map((r) => r.toJson()).toList(),
        },
        'behaviour': <String, dynamic>{
          'decoders': decoders,
          'tolerantDecoder': tolerantDecoder,
          'methods': behaviour,
        },
        'contract': <String, dynamic>{
          'required': required,
          'defaults': defaults,
          'invariants': invariants,
        },
      };
}

/// The whole data decomposition of one module (.dart file in data/domain).
class DataModuleDecomposition {
  DataModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.entities,
  });

  final String module;
  final String sourcePath;
  final List<DataEntity> entities;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'entityCount': entities.length,
        'entities': entities.map((e) => e.toJson()).toList(),
      };
}
