# MVVM - Model

## Must be here
- Data models / entities (immutable where possible)
- Enums and value objects
- Domain rules that don't depend on Flutter UI

## Must NOT be here
- Flutter widgets (`Widget`, `BuildContext`)
- Database code (Drift tables, queries)
- HTTP/Firebase/Supabase implementations
- State management (`ChangeNotifier`, `Riverpod`, etc.)

