import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bloomiot/garden/garden_setup.dart';
import 'package:bloomiot/actions/plant_select.dart'; // Adjust the import path

// Mock SupabaseClient
class MockSupabase extends Mock implements Supabase {}

void main() {
  late MockSupabase mockSupabase;

  setUp(() {
    mockSupabase = MockSupabase();

    // Mock Supabase initialization
    when(() => Supabase.instance).thenReturn(mockSupabase);
  });

  testWidgets('SetupScreen should display the correct widgets',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: SetupScreen(),
      ),
    );

    // Verify that the garden illustration is displayed.
    expect(find.byType(Image), findsOneWidget);

    // Verify that the setup text is displayed.
    expect(find.text('Setup Your Garden'), findsOneWidget);

    // Verify that the "Add plants" button is displayed.
    expect(find.text('Add plants'), findsOneWidget);

    // Verify that the "Open Camera" button is displayed.
    expect(find.text('Open Camera'), findsOneWidget);
  });

  testWidgets(
      'Tapping "Add plants" button should navigate to PlantSelectionScreen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: SetupScreen(),
        routes: {
          '/plantSelection': (context) => const PlantSelectionScreen(),
        },
      ),
    );

    // Tap the "Add plants" button.
    await tester.tap(find.text('Add plants'));
    await tester.pumpAndSettle(); // Wait for the navigation to complete.

    // Verify that the PlantSelectionScreen is displayed.
    expect(find.byType(PlantSelectionScreen), findsOneWidget);
  });

  testWidgets('Tapping "Open Camera" button should not navigate',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: SetupScreen(),
      ),
    );

    // Tap the "Open Camera" button.
    await tester.tap(find.text('Open Camera'));
    await tester.pump(); // Trigger a frame.

    // Verify that the SetupScreen is still displayed.
    expect(find.byType(SetupScreen), findsOneWidget);
  });
}
