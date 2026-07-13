import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voice2text_safe/main.dart';

void main() {
  testWidgets('App starts on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Voice2TextSafeApp());
    await tester.pump();

    expect(find.text('Voice2TextSafe'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
