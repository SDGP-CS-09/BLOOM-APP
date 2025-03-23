import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bloomiot/plants/meters_screen.dart';

// Generate Mocks
@GenerateMocks([
  FirebaseDatabase,
  DatabaseReference,
  DatabaseEvent,
  DataSnapshot,
])
import 'meters_screen_test.mocks.dart'; // Generated file

void main() {
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockDatabaseRef;
  late MockDatabaseReference mockLightRef;
  late MockDatabaseReference mockSoilRef;
  late MockDatabaseReference mockHumidityRef;
  late MockDatabaseReference mockTempRef;

  setUpAll(() {
    // Setup Firebase Database mocks
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockDatabaseRef = MockDatabaseReference();
    mockLightRef = MockDatabaseReference();
    mockSoilRef = MockDatabaseReference();
    mockHumidityRef = MockDatabaseReference();
    mockTempRef = MockDatabaseReference();

    // Stub FirebaseDatabase.instance.ref()
    when(mockFirebaseDatabase.ref()).thenReturn(mockDatabaseRef);

    // Stub child references
    when(mockDatabaseRef.child('sensors/light_level')).thenReturn(mockLightRef);
    when(mockDatabaseRef.child('sensors/soil_moisture'))
        .thenReturn(mockSoilRef);
    when(mockDatabaseRef.child('sensors/humidity')).thenReturn(mockHumidityRef);
    when(mockDatabaseRef.child('sensors/ds18b20_temperature'))
        .thenReturn(mockTempRef);
  });

  testWidgets('Initializes with zero values', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SensorDashboard(),
      ),
    );

    expect(find.text('0.0%'), findsNWidgets(3)); // Light, Soil, Humidity
    expect(find.text('0.0°C'), findsOneWidget);
  });

  testWidgets('Updates UI when sensor values change',
      (WidgetTester tester) async {
    // Configure stream responses
    _mockStreamResponse(mockLightRef, 85.3);
    _mockStreamResponse(mockSoilRef, 45.7);
    _mockStreamResponse(mockHumidityRef, 60.0);
    _mockStreamResponse(mockTempRef, 25.5);

    await tester.pumpWidget(
      MaterialApp(
        home: SensorDashboard(),
      ),
    );
    await tester.pumpAndSettle(); // Wait for streams to initialize

    expect(find.text('85.3%'), findsOneWidget);
    expect(find.text('45.7%'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);
    expect(find.text('25.5°C'), findsOneWidget);
  });
}

void _mockStreamResponse(MockDatabaseReference ref, dynamic value) {
  final mockEvent = MockDatabaseEvent();
  final mockSnapshot = MockDataSnapshot();

  when(mockSnapshot.value).thenReturn(value);
  when(mockEvent.snapshot).thenReturn(mockSnapshot);
  when(ref.onValue).thenAnswer((_) => Stream.value(mockEvent));
}
