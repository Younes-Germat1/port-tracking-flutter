import 'package:flutter_test/flutter_test.dart';
import 'package:port_tracking_flutter/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PortTrackingApp());
    expect(find.byType(PortTrackingApp), findsOneWidget);
  });
}