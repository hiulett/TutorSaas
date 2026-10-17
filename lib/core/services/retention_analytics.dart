import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Logs a usage event. [eventName] should be one of:
  /// 'app_open' | 'session_start' | 'session_end' | 'invoke_llm' |
  /// 'claim_daily' | 'purchase_item' | 'paywall_viewed'.
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
        'properties': properties ?? const <String, dynamic>{},
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
    await track(userId, 'app_open');
  }
}

final retentionAnalyticsProvider = Provider<RetentionAnalytics>((ref) {
  return RetentionAnalytics.instance;
});
