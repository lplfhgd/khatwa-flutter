import 'package:flutter_test/flutter_test.dart';
import 'package:khatwa/main.dart';

void main() {
  testWidgets('Khatwa startup shows role selection', (WidgetTester tester) async {
    await tester.pumpWidget(const KhatwaApp());
    expect(find.text('من سيستخدم التطبيق؟'), findsOneWidget);
    expect(find.text('ولي الأمر'), findsOneWidget);
    expect(find.text('الطفل'), findsOneWidget);
  });
}
