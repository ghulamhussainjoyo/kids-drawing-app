import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over the Supabase client for catalog sync.
///
/// Every method returns null on failure — the sync service decides what to do
/// with the absence.
class SyncApi {
  SupabaseClient get _client => Supabase.instance.client;

  /// Active languages — a simple select, not part of the RPC.
  Future<List<Map<String, dynamic>>?> fetchLanguages() async {
    try {
      final result = await _client
          .from('languages')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('SyncApi.fetchLanguages failed: $e');
      return null;
    }
  }

  /// One RPC call that returns everything that changed since [since] for
  /// the given [langs]. The server filters by `updated_at > since` and
  /// `language_code = any(langs)`.
  Future<Map<String, dynamic>?> fetchDelta(
    DateTime since,
    List<String> langs,
  ) async {
    try {
      final result = await _client.rpc('catalog_delta', params: {
        'since': since.toUtc().toIso8601String(),
        'langs': langs,
      });
      return result as Map<String, dynamic>;
    } catch (e) {
      debugPrint('SyncApi.fetchDelta failed: $e');
      return null;
    }
  }

  /// Downloads a file from a public storage bucket.
  Future<Uint8List?> downloadFile(String bucket, String path) async {
    try {
      return await _client.storage.from(bucket).download(path);
    } catch (e) {
      debugPrint('SyncApi.downloadFile($bucket/$path) failed: $e');
      return null;
    }
  }
}
