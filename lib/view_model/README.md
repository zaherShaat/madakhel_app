# MVVM - ViewModel

## Must be here
- Presentation/state logic (screen state, loading/error handling)
- Form validation and orchestration
- Calling repositories / use-cases and exposing state to the View

## Must NOT be here
- Flutter UI widgets (keep UI in `view/`)
- Drift table definitions and raw query logic
- Direct platform code

