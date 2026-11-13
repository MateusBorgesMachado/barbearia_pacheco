class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cksavpwkozgguzowhpxc.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrc2F2cHdrb3pnZ3V6b3docHhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3NDEzNjksImV4cCI6MjA5NTMxNzM2OX0.oNNjYEaf3L5Khg6nCUgpCS6RT_GKM5oxonxlSLdkcJ0',
  );
}
