import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The set of every `ElementDescriptor(id: '…')` id declared in
/// element_registry.dart — the authority the decomposer cross-checks each
/// `CfgText` / `CfgVisible` id against. AST-parsed (no resolution needed).
class RegistryIndex {
  RegistryIndex(this.ids);

  final Set<String> ids;

  bool has(String id) => ids.contains(id);

  /// Parse [registryPath] and collect the id of every `ElementDescriptor(...)`.
  factory RegistryIndex.fromFile(String registryPath) {
    final unit = parseFile(
      path: registryPath,
      featureSet: FeatureSet.latestLanguageVersion(),
    ).unit;
    final v = _RegistryIdCollector();
    unit.accept(v);
    return RegistryIndex(v.ids);
  }
}

class _RegistryIdCollector extends RecursiveAstVisitor<void> {
  final Set<String> ids = <String>{};

  void _collect(String typeName, ArgumentList argList) {
    if (typeName != 'ElementDescriptor') return;
    for (final arg in argList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'id') {
        final v = arg.expression;
        if (v is SimpleStringLiteral) ids.add(v.value);
      }
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _collect(node.constructorName.type.name.lexeme, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  // Unresolved AST parses a non-const `ElementDescriptor(...)` as a
  // MethodInvocation — cover that form too.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null) {
      _collect(node.methodName.name, node.argumentList);
    }
    super.visitMethodInvocation(node);
  }
}
