import 'package:flutter_test/flutter_test.dart';
import 'package:health_safety_inspection/main.dart';

void main() {
  testWidgets('App bootstraps', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthSafetyApp());
    expect(find.text('Safety Inspector'), findsOneWidget);
  });
}
