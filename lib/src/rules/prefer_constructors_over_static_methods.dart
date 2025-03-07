// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc =
    r'Prefer defining constructors instead of static methods to create instances.';

const _details = r'''
**PREFER** defining constructors instead of static methods to create instances.

In most cases, it makes more sense to use a named constructor rather than a
static method because it makes instantiation clearer.

**BAD:**
```dart
class Point {
  num x, y;
  Point(this.x, this.y);
  static Point polar(num theta, num radius) {
    return Point(radius * math.cos(theta),
        radius * math.sin(theta));
  }
}
```

**GOOD:**
```dart
class Point {
  num x, y;
  Point(this.x, this.y);
  Point.polar(num theta, num radius)
      : x = radius * math.cos(theta),
        y = radius * math.sin(theta);
}
```
''';

bool _hasNewInvocation(DartType returnType, FunctionBody body) =>
    _BodyVisitor(returnType).containsInstanceCreation(body);

class PreferConstructorsInsteadOfStaticMethods extends LintRule {
  static const LintCode code = LintCode(
      'prefer_constructors_over_static_methods',
      'Static method should be a constructor.',
      correctionMessage: 'Try converting the method into a constructor.');

  PreferConstructorsInsteadOfStaticMethods()
      : super(
            name: 'prefer_constructors_over_static_methods',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _BodyVisitor extends RecursiveAstVisitor {
  bool found = false;

  final DartType returnType;
  _BodyVisitor(this.returnType);

  bool containsInstanceCreation(FunctionBody body) {
    body.accept(this);
    return found;
  }

  @override
  visitInstanceCreationExpression(InstanceCreationExpression node) {
    found = node.staticType == returnType;
    if (!found) {
      super.visitInstanceCreationExpression(node);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    var returnType = node.returnType?.type;
    var parent = node.parent;
    if (node.isStatic &&
        parent is ClassDeclaration &&
        returnType is InterfaceType &&
        parent.typeParameters == null &&
        node.typeParameters == null) {
      var declaredElement = parent.declaredElement;
      if (declaredElement != null) {
        var interfaceType = declaredElement.thisType;
        if (!context.typeSystem.isAssignableTo(returnType, interfaceType)) {
          return;
        }
        if (_hasNewInvocation(returnType, node.body)) {
          rule.reportLintForToken(node.name);
        }
      }
    }
  }
}
