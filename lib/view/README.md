# MVVM - View

## Must be here
- Screens and UI widgets only
- UI-only formatting (layout, colors, RTL)
- Calling ViewModel methods (no direct DB access)

## Must NOT be here
- SQL/Drift queries, repositories, or DB objects
- Business logic (balance calculations, aggregations)
- Side effects (file IO, network, Firebase calls)

