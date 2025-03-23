// plant_details_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloomiot/plants/plant_detail.dart';

void main() {
  group('PlantDetailScreen Widget Tests', () {
    testWidgets('displays correct scientific and common name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'tomato',
            scientificName: 'Solanum lycopersicum',
            imageUrl: 'https://example.com/tomato.jpg',
          ),
        ),
      );

      expect(find.text('Solanum lycopersicum (tomato)'), findsOneWidget);
    });

    testWidgets('displays correct description for known plants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'tomato',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      expect(
        find.text(
            'Tomato is a visually appealing plant that adds elegance and symbolizes prosperity.'),
        findsOneWidget,
      );
    });

    testWidgets('displays default description for unknown plants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'unknown',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      expect(
        find.text('This plant adds beauty and vitality to your space.'),
        findsOneWidget,
      );
    });

    testWidgets('displays correct condition values for tomato',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'tomato',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      expect(find.text('250 ml'), findsOneWidget); // Water
      expect(find.text('Normal'), findsNWidgets(2)); // Sunlight and Eggplant
      expect(find.text('70 ml'), findsOneWidget); // Fertilizer
      expect(find.text('54%'), findsOneWidget); // Humidity
    });

    testWidgets('displays default values for unknown plants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'unknown',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      expect(find.text('Varies'), findsNWidgets(4));
    });

    testWidgets('navigates back when back button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'tomato',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      // Verify screen is visible
      expect(find.byType(PlantDetailScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Verify screen is removed
      expect(find.byType(PlantDetailScreen), findsNothing);
    });

    testWidgets('shows SnackBar when Add to My Plants is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'tomato',
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      // Tap the "Add to My Plants" button
      await tester.tap(find.text('Add to My Plants'));
      await tester.pump(); // Trigger SnackBar display

      // Verify SnackBar content
      expect(find.text('tomato added to My Plants'), findsOneWidget);
    });

    testWidgets('handles case-insensitive common names',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailScreen(
            commonName: 'Tomato', // Upper case
            scientificName: 'SciName',
            imageUrl: '',
          ),
        ),
      );

      // Verify description still matches
      expect(
        find.text(
            'Tomato is a visually appealing plant that adds elegance and symbolizes prosperity.'),
        findsOneWidget,
      );
    });
  });
}
