import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upthink/app.dart';
import 'package:upthink/core/widgets/upthink_logo.dart';
import 'package:upthink/core/widgets/metric_card.dart';
import 'package:upthink/core/widgets/severity_badge.dart';
import 'package:upthink/core/widgets/mastery_bar.dart';

void main() {
  testWidgets('UpthinkApp smoke test - initializes and renders properly', (WidgetTester tester) async {
    // Set surface size to modern phone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: UpthinkApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Upthink branding or initial student dashboard screen renders
    expect(find.byType(UpthinkApp), findsOneWidget);
  });

  testWidgets('Upthink visual components smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              UpthinkLogo(size: 32),
              SeverityBadge(severity: GapSeverity.high),
              MetricCard(
                label: 'System Diagnostic',
                value: '84.2%',
              ),
              MasteryBar(
                percentage: 64.0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(UpthinkLogo), findsOneWidget);
    expect(find.byType(SeverityBadge), findsOneWidget);
    expect(find.text('HIGH RISK'), findsOneWidget);
    expect(find.text('SYSTEM DIAGNOSTIC'), findsOneWidget);
    expect(find.text('84.2%'), findsOneWidget);
    expect(find.byType(MasteryBar), findsOneWidget);
  });
}
