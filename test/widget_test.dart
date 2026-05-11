import 'package:flutter_test/flutter_test.dart';
import 'package:uwangku/app/app.dart';

void main() {
  testWidgets('Finance app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());
    await tester.pumpAndSettle();
  });
}