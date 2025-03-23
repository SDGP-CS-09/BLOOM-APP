/*mport 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloomiot/actions/notifications.dart';

void main() {
  testWidgets('NotificationsScreen displays notifications correctly',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));

    // Check if the "Notifications" title is present
    expect(find.text("Notifications"), findsOneWidget);

    // Check if "Today" and "Yesterday" sections exist
    expect(find.text("Today"), findsOneWidget);
    expect(find.text("Yesterday"), findsOneWidget);

    // Check if notification cards are rendered correctly
    expect(find.text("Time to hydrate!"), findsNWidgets(2));
    expect(find.text("Our mental health matters."), findsNWidgets(2));

    // Check if images are displayed correctly in NotificationCard
    final plantImageFinder = find.byType(PlantImage);
    expect(plantImageFinder, findsNWidgets(4));

    // Verify that a specific image asset is used in one of the notifications
    final firstPlantImage = tester.widget<PlantImage>(plantImageFinder.first);
    expect(firstPlantImage.index, 'assets/plant1.png');

    // Check if active status indicator is green
    final activeStatusFinder = find.descendant(
      of: find.byType(NotificationCard).first,
      matching: find.byType(Container),
    );

    final activeStatusWidget = tester.widget<Container>(activeStatusFinder);
    final BoxDecoration? activeDecoration =
        activeStatusWidget.decoration as BoxDecoration?;
    expect(activeDecoration?.color, Colors.green.shade900);

    // Check if inactive status indicator is white
    final inactiveStatusFinder = find.descendant(
      of: find.byType(NotificationCard).last,
      matching: find.byType(Container),
    );

    final inactiveStatusWidget = tester.widget<Container>(inactiveStatusFinder);
    final BoxDecoration? inactiveDecoration =
        inactiveStatusWidget.decoration as BoxDecoration?;
    expect(inactiveDecoration?.color, Colors.white);
  });
}
*/
