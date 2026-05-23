# Data Layer

## Must be here
- Local persistence (Drift/SQLite) and repositories
- Query + aggregation code (SUM/GROUP BY)
- Data-source implementations (later: Supabase backup, etc.)

## Must NOT be here
- Flutter UI widgets/screens
- Screen state/controllers (keep in `view_model/`)
- Pure domain types that don't depend on persistence (keep in `model/`)

