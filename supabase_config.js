// Configurações do Supabase
const SUPABASE_URL = "https://yjhnfyullkibhkiwmmlp.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlqaG5meXVsbGtpYmhraXdtbWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4NzU2ODIsImV4cCI6MjEwNjQ1MTY4Mn0.8Ng-Ck3ECd8A5S7MlXQu76FYnou8ssAYJwOkfnEitx4";

// Inicializa o cliente Supabase
const _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);