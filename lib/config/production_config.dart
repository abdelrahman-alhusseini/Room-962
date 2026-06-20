/// Production configuration notes for the real Room +962 build.
///
/// Do not hardcode secrets in Flutter. Public values can be passed with:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// Server secrets such as RESEND_API_KEY and SUPABASE_SERVICE_ROLE_KEY belong
/// only in Supabase Edge Function secrets.
class ProductionConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const appUrl = String.fromEnvironment('APP_URL', defaultValue: 'room962://auth');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
