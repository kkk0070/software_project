// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:sepro/providers/theme_provider.dart';
import 'package:sepro/providers/active_ride_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sepro/main.dart';

void main() {
  setUp(() {
    // Mock SharedPreferences for ThemeProvider and other services
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Landing screen smoke test', (WidgetTester tester) async {
    // Build our app with required providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ActiveRideProvider()),
        ],
        child: const EcoRideApp(),
      ),
    );

    // Initial pump to trigger initState and start animations
    await tester.pump();
    
    // pumpAndSettle might hang if there are infinite animations, 
    // but LandingScreen uses animate_do which should finish.
    // If it hangs, we'll use multiple pump() calls instead.
    await tester.pump(const Duration(seconds: 1));

    // Verify that 'EcoRide' exists.
    expect(find.text('EcoRide'), findsWidgets);
    
    // Verify that 'Get Started' button exists.
    expect(find.text('Get Started'), findsOneWidget);
  });
}
