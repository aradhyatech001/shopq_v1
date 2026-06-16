import 'package:flutter_test/flutter_test.dart';

import 'package:dxmart_delivery/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());
    expect(find.byType(DeliveryApp), findsOneWidget);
  });
}
