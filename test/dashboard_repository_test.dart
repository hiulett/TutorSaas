import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    throw Exception('Simulated database network error');
  }
}

void main() {
  group('DashboardRepositoryImpl Tests', () {
    late DashboardRepositoryImpl repository;
    late FakeSupabaseClient fakeClient;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      repository = DashboardRepositoryImpl(fakeClient);
    });

    test('getRecommendedLessons returns empty list on full DB error', () async {
      final lessons = await repository.getRecommendedLessons('test-user-id');
      // FakeSupabaseClient throws on every .from() call, hitting the outer catch → returns []
      expect(lessons, isEmpty);
    });

    test('getUserAchievements returns empty list on DB error', () async {
      final achievements = await repository.getUserAchievements('test-user-id');
      expect(achievements, isEmpty);
    });

    test('getWeeklyPractice returns default 7-day list on DB error', () async {
      final weeklyPractice = await repository.getWeeklyPractice('test-user-id');
      // On DB failure the impl returns a 7-day default list with 0 minutes
      expect(weeklyPractice.length, 7);
      expect(weeklyPractice.first['minutes'], 0);
    });

    test('updateUserProfile returns successfully or throws expected', () async {
      expect(
        () => repository.updateUserProfile(
          'test-user-id',
          displayName: 'New Name',
          avatarUrl: 'warrior',
          bio: '[Stats|STR:10|INT:10|DEX:10|LUK:10] Hi',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
