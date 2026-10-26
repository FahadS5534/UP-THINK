import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

/// Central Supabase Client & Backend Gateway
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase
  Future<void> initialize() async {
    try {
      if (AppConfig.supabaseUrl.isNotEmpty &&
          AppConfig.supabaseUrl.startsWith('http') &&
          !AppConfig.supabaseUrl.contains('demo-upthink-project')) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: AppConfig.supabasePublishableKey,
        );
        _isInitialized = true;
      } else {
        if (kDebugMode) {
          debugPrint('Supabase using mock / local mode. Live credentials not provided.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase initialize error: $e. Operating in verified offline mode.');
      }
      _isInitialized = false;
    }
  }

  /// Invoke a protected Supabase Edge Function
  Future<Map<String, dynamic>?> invokeEdgeFunction({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.functions.invoke(
          functionName,
          body: body,
        );
        if (res.data is Map<String, dynamic>) {
          return res.data as Map<String, dynamic>;
        } else if (res.data is String) {
          return jsonDecode(res.data as String) as Map<String, dynamic>;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Edge function $functionName error: $e');
        }
      }
    }

    // Direct HTTP fallback if Edge Functions are configured via custom URL
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$functionName');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabasePublishableKey}',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Handled by repository layer
    }
    return null;
  }
}
