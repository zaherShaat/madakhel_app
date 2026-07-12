# Madakhel App - Project Context

> Current source of truth for the Flutter app.
> Updated: May 23, 2026.
> This file compares the intended app design with what is already implemented in the project and lists the remaining work.

---

## 1. App Goal

Madakhel is a Flutter mobile app for tracking multiple income sources. Each income source has its own financial transactions, balance, and statistics.

- Platform: Flutter mobile
- Language/UI direction: Arabic / RTL intended
- Local storage: Drift over SQLite
- Auth: Firebase Authentication, currently focused on Google sign-in
- State management: Provider + ChangeNotifier ViewModels
- Future backup: Supabase, using the existing sync fields as preparation

---

## 2. Current Architecture

The actual project structure does not match the older `screens/`, `providers/`, and `repositories/` layout from the previous context file. The current code uses:

```text
lib/
  main.dart
  firebase_options.dart

  core/
    routing/
      app_router.dart
      app_transition.dart
    theme/
      app_theme.dart
      app_colors.dart
    app_states.dart
    actions_states.dart
    color_helper.dart
    context_ext.dart
    utils.dart

  data/
    auth/
      auth_service.dart
      auth_storage.dart
    db/
      app_db.dart
      app_db.g.dart
      tables.dart
    repositories/
      income_type_repository.dart
      transaction_category_repository.dart
      transaction_repository.dart

  model/
    auth_user.dart
    income_source_with_balance.dart
    transaction_direction.dart

  view/
    auth/
    home/
    income_source/
    settings/
    shared/
    transactions/

  view_model/
    auth_view_model.dart
    category_view_model.dart
    home_view_model.dart
    income_source_detail_view_model.dart
    income_source_view_model.dart
    splash_view_model.dart
    theme_view_model.dart
    transaction_view_model.dart
    transactions_view_model.dart

Views should not read repositories directly. Repositories are injected into ViewModels in `main.dart`, and screens consume ViewModels.
```

---

## 3. Intended Data Model

The intended v3 model is implemented in `lib/data/db/tables.dart`.

```text
IncomeSources
  id
  name
  currency
  starterBalance
  createdAt
  updatedAt
  syncStatus
  remoteId
  isDeleted

TransactionCategories
  id
  name
  direction
  createdAt
  updatedAt
  syncStatus
  remoteId
  isDeleted

FinancialTransactions
  id
  incomeSourceId
  categoryId
  direction  <-- DENORMALIZED: stores `TransactionDirection` at creation time
  isSystem
  amount
  note
  date
  createdAt
  updatedAt
  syncStatus
  remoteId
  isDeleted
```

Relationships:

```text
IncomeSources 1 -> many FinancialTransactions
TransactionCategories 1 -> many FinancialTransactions
FinancialTransactions belongs to one IncomeSource and one TransactionCategory
```

Important rule (updated): transaction direction is now denormalized on `FinancialTransactions.direction`.
  - The app continues to maintain `TransactionCategories.direction` as the canonical category direction.
  - On create/update/restore the transaction's `direction` is populated from the category, and kept in sync when the transaction's category is changed.
  - This denormalization simplifies queries (no joins required) for sums and filters and improves read performance.
  - Tradeoff: if a category's direction is changed after transactions exist, those historical transactions retain their original `direction` (intentional for preserving historical context).

---

## 4. What Is Done

### Project setup

- Flutter app is present for Android and iOS.
- Firebase configuration files are present.
- `main.dart` initializes Firebase and Google Sign-In.
- Provider wiring exists for auth, theme, repositories, and ViewModels.
- Light/dark theme support exists through `ThemeViewModel`.

### Database

- Drift database exists in `lib/data/db/app_db.dart`.
- Schema version is `4`.
- The three core tables are implemented.
- Sync fields are already included on all tables:
  - `updatedAt`
  - `syncStatus`
  - `remoteId`
  - `isDeleted`
- Migration currently drops and recreates the three app tables when upgrading from versions below 4.

### Repositories

- `IncomeTypeRepository` handles income source create/read/update/soft-delete.
- `TransactionRepository` handles transaction create/read/update/soft-delete and sum queries.
- `TransactionCategoryRepository` handles category create/read/update/soft-delete.
- Soft delete is used for income sources, categories, and transactions.
- Deleting an income source soft-deletes only the source. Related transactions are preserved and excluded from active source balance and grouped transaction lists because the source is no longer active.

### Home and income sources

- Home screen exists at `lib/view/home/home_screen.dart`.
- Home lists income sources from the local database.
- Income source cards show computed balances.
- Add/edit income source screen exists at `lib/view/income_source/income_source_form_screen.dart`.
- Income source detail screen exists at `lib/view/income_source/source_detail_screen.dart`.
- Source detail shows:
  - balance
  - total income
  - total expense
  - transaction count
  - latest transactions, currently limited to 3
- Source edit/delete actions exist through a bottom sheet.

### Transactions

- Add transaction bottom sheet exists.
- Transactions can be created with:
  - category
  - amount
  - date
  - optional note
- Transactions can be soft-deleted from source detail by long-pressing a row.
- Total income and total expense queries use category direction.

### Categories

- Category table and repository exist.
- Category management screens exist:
  - `lib/view/transactions/categories_screen.dart`
  - `lib/view/transactions/add_category_screen.dart`
- Settings links to the categories screen.

### Auth

- Firebase Auth and Google Sign-In service/controller exist.
- Start screen is the active auth screen.
- Sign-in, sign-up, forgot password, and forgot password sent files still exist but are intentionally outside the active router.
- Splash screen exists and routes after auth readiness.
- Google sign-in is wired through `AuthViewModel` and `AuthService`.
- Auth user can be persisted locally through `AuthUserStorage`.

### Navigation and UI

- GoRouter is used.
- Routes exist for:
  - `/start`
  - `/home`
  - `/source-detail`
  - `/income-source/new`
  - `/income-source/edit`
  - `/transactions`
  - `/settings`
  - `/categories`
  - `/add-category`
- Shared bottom navigation exists with Settings, Transactions, and Home tabs.
- Shared UI components exist for app bars, buttons, dialogs, text fields, cards, and transaction rows.

---

## 5. Partially Done / Needs Correction

### Balance calculation

Current behavior:

- `watchIncomeSourcesWithBalance()` joins income sources, transactions, and categories.
- It calculates signed transaction totals by category direction.
- Deleted sources, deleted transactions, and deleted categories are filtered out of the balance query.

Issues to fix:

- `starterBalance` is not included in the computed balance.
- The income source form does not expose `starterBalance`; it always creates sources with `0`.
- The code still uses the old name `IncomeTypeRepository` and `incomeTypeId` in several places, even though the domain model is now `IncomeSource`.

### Transactions page

Current behavior:

- `/transactions` route exists.
- `TransactionsScreen` shows real grouped transactions by category.
- Source detail "Show all" navigates to the transactions tab.

Missing:

- Pagination or progressive loading.

### Category management UI

Current behavior:

- Category screens exist visually.
- `TransactionCategoryRepository.createCategory()` exists.
- Category CRUD is wired to the local database.
- Category add/edit opens as a bottom sheet.
- Category direction is selected at creation and locked during edit.

Issues to fix:

- Add stronger UX around categories that are already used by transactions if needed.

### Auth flow

Current behavior:

- Google sign-in is implemented.
- `/start` is the active auth entry point.
- Start page shows only a Google sign-in action.
- Sign-out is available from Settings and returns to `/start`.
- Email/password, sign-up, and forgot-password screen files still exist but are intentionally not routed in the active app flow.
- Router starts at `/splash`, then sends signed-in users to `/home` and signed-out users to `/start`.

Issues to fix:

- Remove or archive the unused email/password auth files later if the project is ready for that cleanup. Do not mix that deletion with behavior work.

### Add transaction flow

Current behavior:

- Add transaction sheet creates a transaction through `TransactionViewModel`.
- Add/edit transaction sheet is wired.

Issues to fix:

- Verify edit transaction UX on the full transactions tab after UI polish.

### Source detail

Current behavior:

- Source detail shows stats and the latest three transactions.

Issues to fix:

- Transaction rows only receive `FinancialTransaction`; category name/direction may not be available for display unless fetched elsewhere.
- "Show all" navigates to the transactions tab.
- Bottom navigation variable exists but is not rendered on this screen.
- `isSystem` rows are not treated specially in UI or repository operations yet.

### Sync flags

Current behavior:

- Sync fields exist and many writes set `updatedAt` and `syncStatus`.

Issues to fix:

- Not every query filters `isDeleted = false`.
- There is no sync service yet, which is expected for MVP.

### Text encoding

Many Arabic strings in source files and the old context file appear mojibake/encoding-corrupted, for example text rendered as `ط§...`. This should be fixed separately by restoring proper UTF-8 Arabic strings across source files.

---

## 6. Current Dependencies

Actual dependencies from `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  intl: ^0.19.0
  provider: ^6.1.0
  firebase_core: ^4.7.0
  firebase_auth: ^6.4.0
  google_sign_in: ^7.2.0
  currency_picker: ^2.0.21
  go_router: ^17.2.3
  shared_preferences: ^2.2.0
```

Dev dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
  change_app_package_name: ^1.5.0
```

---

## 7. Recommended Next Steps

### Step 1 - Verify navigation/auth correctness

Success criteria:

- Signed-out user lands on `/start`.
- Signed-in user lands on `/home`.
- Google sign-in redirects correctly.
- Sign-out returns to the auth flow.

Tasks:

- Current MVP supports only Google sign-in.
- Smoke-test splash, Google sign-in, app restart, and sign-out.
- Keep unused email/password auth screens out of the active router.

### Step 2 - Fix income source balance

Success criteria:

- Home balance equals `starterBalance + income - expense`.
- Deleted transactions/categories do not affect balance.
- Deleted sources do not appear on Home.

Tasks:

- Add `starterBalance` to income source create/edit UI or explicitly remove it from MVP.
- Include `starterBalance` in `watchIncomeSourcesWithBalance()`.
- Deleted source and transaction filters are in the balance query; confirm whether deleted categories should hide old transaction impact or preserve historical direction.
- Rename `IncomeTypeRepository` and `incomeTypeId` later if desired; do this as a separate cleanup, not mixed with behavior fixes.

### Step 3 - Verify category CRUD

Success criteria:

- Categories screen reads from Drift.
- Add category saves to Drift.
- Edit category name works.
- Delete category soft-deletes it.
- Direction is selected at create time and cannot be changed after.

Tasks:

- Smoke-test create/edit/delete from Settings -> categories.
- Add guardrails if deleting a category that has transactions should be restricted instead of soft-hidden.

### Step 4 - Fix add transaction flow

Success criteria:

- Pressing Add in `AddTransactionSheet` inserts exactly one transaction.
- The sheet closes after successful insert.
- Invalid amount/category input shows validation feedback.

Tasks:

- The unused transaction confirmation state has been removed.
- Remove unused `transactionName` from the transaction creation path.
- Ensure selected category direction determines income/expense behavior.

### Step 5 - Build the Transactions tab

Success criteria:

- `/transactions` shows real database transactions grouped by category.
- Each category section shows name, direction, subtotal, and rows.
- Deleted transactions, deleted categories, and transactions from deleted sources are excluded.

Tasks:

- Smoke-test grouped transaction sections with active and deleted data.
- Add pagination/progressive loading if needed after the basic screen works.

### Step 6 - Add edit transaction support

Success criteria:

- User can edit amount, date, note, and category.
- System transactions cannot be edited.
- Updated rows set `updatedAt` and `syncStatus = pending`.

Tasks:

- Add edit transaction bottom sheet.
- Wire transaction row tap or menu to edit.
- Preserve soft-delete and sync rules.

### Step 7 - Clean up Arabic text encoding

Success criteria:

- All visible Arabic text renders correctly in UTF-8.
- No mojibake strings remain in `lib/`.

Tasks:

- Restore proper Arabic strings in source files.
- Confirm editor and repository encoding are UTF-8.
- Run the app and inspect key screens.

---

## 8. Future Roadmap - Do Not Build Until MVP Is Stable

- Supabase online backup/sync.
- PDF export per transaction category.
- CSV export.
- Recurring transactions.
- Date range reports.
- Saved report snapshots.
- Multi-currency conversion.

---

## 9. Current MVP Definition

The practical MVP should be:

- Google sign-in works.
- User can create/edit/delete income sources.
- User can create/edit/delete categories.
- User can create/delete transactions and later edit them.
- Home shows accurate balances.
- Source detail shows accurate stats and recent transactions.
- Transactions tab shows grouped transactions.
- Soft-delete and sync flags are consistently maintained.
