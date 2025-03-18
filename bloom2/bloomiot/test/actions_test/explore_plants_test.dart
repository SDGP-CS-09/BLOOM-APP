import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloomiot/actions/explore_plants.dart';

void main() {
  testWidgets('ExplorePlantsScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ExplorePlantsScreen()),
    );

    // Verify the app bar title
    expect(find.text('Explore Plants'), findsOneWidget);

    // Verify the presence of the search bar
    expect(find.byType(TextField), findsOneWidget);

    // Verify the presence of category grid
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Flowering\nPlants'), findsOneWidget);
    expect(find.text('Trees'), findsOneWidget);
    expect(find.text('Shrubs &\nHerbs'), findsOneWidget);
    expect(find.text('Weeds &\nShrubs'), findsOneWidget);

    // Test typing in the search bar
    await tester.enterText(find.byType(TextField), 'Rose');
    await tester.pump();
  });
}
