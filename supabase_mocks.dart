import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

// Setup function for mocking Supabase
void setupSupabaseMocks() {
  final mockSupabaseClient = MockSupabaseClient();
  final mockGoTrueClient = MockGoTrueClient();
  final mockUser = MockUser();

  // Mock the Supabase instance
  when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
  when(() => mockUser.id).thenReturn('test-user-id');
}
