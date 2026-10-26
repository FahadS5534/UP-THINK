/// Upthink Environment & Runtime Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Upthink';
  static const String brandTagline = 'Think beyond memorization.';

  // Supabase Configuration via --dart-define or sensible defaults
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-upthink-project.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sbp_mock_publishable_key_upthink_secure_2026',
  );

  // Gemini API Key for client fallback / direct AI capabilities
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const bool enableLocalFallback = true;
}
