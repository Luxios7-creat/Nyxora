import 'package:flutter_test/flutter_test.dart';
import 'package:led_app/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {

    await tester.pumpWidget(
      const LedApp(),
    );

    expect(find.text('Indie Room'), findsOneWidget);
  });
}