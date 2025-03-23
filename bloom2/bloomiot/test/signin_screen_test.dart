import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bloomiot/auth/signin_screen.dart';
import 'package:bloomiot/mainscreens/home.dart';

// Mock NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake Route class for Mocktail
class FakeRoute<T> extends Fake implements Route<T> {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://your-supabase-url.supabase.co',
      anonKey: 'your-anon-key',
    );

    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  testWidgets('SignInScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(),
        navigatorObservers: [mockObserver],
      ),
    );

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('Shows error when email or password is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignInScreen()));

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Navigates to HomeScreen on successful login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(),
        navigatorObservers: [mockObserver],
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );

    // Debug: Print initial widget tree
    print('Widget tree before login: ${tester.allWidgets}');

    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle(); // Ensure UI updates

    // Debug: Print widget tree after login attempt
    print('Widget tree after login: ${tester.allWidgets}');

    // Verify HomeScreen is present after navigation
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
