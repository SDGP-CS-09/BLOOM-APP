import 'package:bloomiot/auth/signin_screen.dart';
import 'package:bloomiot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen should navigate to SignInScreen after 3 seconds',
      (WidgetTester tester) async {
    // Wrap in MaterialApp to simulate real navigation
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify SplashScreen elements are shown
    expect(find.text("BLOOM"), findsOneWidget);
    expect(find.text("SDGP CS 09"), findsOneWidget);

    // Wait for the duration of the splash screen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the SignInScreen is displayed
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
