import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../analytics/analytics_taxonomy.dart';

/// Best-effort fire-and-forget analytics of retention events (OBS-02).
///
/// Writes into `analytics_events`. Never throws: each call is wrapped in its
/// own try-catch, so it can be fired with `unawaited()` from the caller
/// without blocking the main flow.
class RetentionAnalytics {
  RetentionAnalytics(this._client);

  final SupabaseClient _client;

  static RetentionAnalytics? _instance;

  /// Singleton accessor. The SupabaseClient is injected via the constructor
  /// so tests can build their own instance with a fake client.
  static RetentionAnalytics get instance {
    return _instance ??= RetentionAnalytics(Supabase.instance.client);
  }

  /// Registra un evento de [AnalyticsEvent]. Las propiedades pasan por
  /// [sanitizeAnalyticsProperties]: sin PII, sin texto libre y con topes.
  Future<void> track(
    String userId,
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (userId.isEmpty || eventName.isEmpty) return;
    try {
      await _client.from('analytics_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'properties': sanitizeAnalyticsProperties(properties),
      });
      debugPrint('[Analytics] Event tracked: $eventName');
    } catch (e) {
      debugPrint('[Analytics] Error tracking event ($eventName): $e');
    }
  }
  /// Issue #35: `app_open` estaba documentado pero nunca se emitía. Se emite
  /// una sola vez por proceso para no inflar la tabla en cada rebuild.
  static bool _appOpenTracked = false;

  Future<void> trackAppOpenOnce(String userId) async {
    if (_appOpenTracked) return;
    _appOpenTracked = true;
    await track(userId, AnalyticsEvent.appOpen);
  }
}

final retentionAnalyticsProvider = Provider<RetentionAnalytics>((ref) {
  return RetentionAnalytics.instance;
});
