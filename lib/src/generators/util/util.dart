import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class AssignmentExpressionVisitor extends RecursiveAstVisitor {
  final List<AssignmentExpression> allElements;

  AssignmentExpressionVisitor(this.allElements);

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    allElements.add(node);
    return super.visitAssignmentExpression(node);
  }
}

List<AssignmentExpression> findAssignmentExpressions(AstNode node) {
  List<AssignmentExpression> expressions = [];
  node.visitChildren(AssignmentExpressionVisitor(expressions));
  return expressions;
}
