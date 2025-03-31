import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bloomiot/garden/my_plants.dart';
import '../mocks/supabase_mock.mocks.dart' as generated_mocks;

// Custom mocks
class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late generated_mocks.MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;
  late generated_mocks.MockPostgrestFilterBuilder<PostgrestList>
      mockPostgrestFilterBuilder;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(
        PostgrestResponse.fromJson({'data': [], 'status': 200}));
  });

  setUp(() {
    mockSupabaseClient = generated_mocks.MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();
    mockPostgrestFilterBuilder =
        generated_mocks.MockPostgrestFilterBuilder<PostgrestList>();

    // Auth setup
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');

    // Default PostgrestList response
    final emptyResponse =
        PostgrestResponse.fromJson({'data': [], 'status': 200});

    when(() => mockPostgrestFilterBuilder.then(any()))
        .thenAnswer((_) async => emptyResponse);
  });

  PostgrestList _createMockResponse(List<Map<String, dynamic>> data) {
    return PostgrestResponse.fromJson({'data': data, 'status': 200}).data
        as PostgrestList;
  }

  group('GardenScreen', () {
    testWidgets('displays loading indicator when fetching plants',
        (tester) async {
      when(() => mockSupabaseClient
              .from('user_plants')
              .select()
              .eq('user_id', any(that: isA<String>())))
          .thenReturn(mockPostgrestFilterBuilder);

      await tester.pumpWidget(MaterialApp(home: GardenScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays plant cards with valid data', (tester) async {
      final mockData = [
        {
          'plant_id': 1,
          'plants': {'id': 1, 'common_name': 'Tomato'}
        },
        {
          'plant_id': 2,
          'plants': {'id': 2, 'common_name': 'Potato'}
        },
      ];

      when(() => mockPostgrestFilterBuilder.then(any()))
          .thenAnswer((_) async => _createMockResponse(mockData));

      await tester.pumpWidget(MaterialApp(home: GardenScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PlantCard), findsNWidgets(2));
    });
  });
}
