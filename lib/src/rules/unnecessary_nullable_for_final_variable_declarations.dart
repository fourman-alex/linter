// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Use a non-nullable type for a final variable initialized '
    'with a non-nullable value.';

const _details = r'''
Use a non-nullable type for a final variable initialized with a non-nullable
value.

**BAD:**
```dart
final int? i = 1;
```

**GOOD:**
```dart
final int i = 1;
```

''';

class UnnecessaryNullableForFinalVariableDeclarations extends LintRule {
  static const LintCode code = LintCode(
      'unnecessary_nullable_for_final_variable_declarations',
      'Type could be non-nullable.',
      correctionMessage: 'Try changing the type to be non-nullable.');

  UnnecessaryNullableForFinalVariableDeclarations()
      : super(
            name: 'unnecessary_nullable_for_final_variable_declarations',
            description: _desc,
            details: _details,
            maturity: Maturity.experimental,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    if (!context.isEnabled(Feature.non_nullable)) {
      return;
    }

    var visitor = _Visitor(this, context);
    registry.addFieldDeclaration(this, visitor);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addVariableDeclarationStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  final LinterContext context;
  _Visitor(this.rule, this.context);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (var variable in node.fields.variables) {
      if (Identifier.isPrivateName(variable.name.lexeme) || node.isStatic) {
        _visit(variable);
      }
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    node.variables.variables.forEach(_visit);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    node.variables.variables.forEach(_visit);
  }

  void _visit(VariableDeclaration variable) {
    if (!variable.isFinal && !variable.isConst) {
      return;
    }
    if (variable.isSynthetic) {
      return;
    }
    var initializerType = variable.initializer?.staticType;
    if (initializerType == null) {
      return;
    }
    var declaredElement = variable.declaredElement;
    if (declaredElement == null || declaredElement.type.isDynamic) {
      return;
    }

    if (context.typeSystem.isNullable(declaredElement.type) &&
        context.typeSystem.isNonNullable(initializerType)) {
      rule.reportLint(variable);
    }
  }
}
