# مداخيل — Incomes App — Cursor Agent Context

> Full project context. Use this as the single source of truth for building the app.
> Last updated: May 2026 — v3 entity model (sync flags added).

---

## 1. Project Overview

A Flutter mobile app to help a friend organize multiple income sources (e.g. Internet Café, Source B, Source C). Each income source is fully standalone with its own financial transactions, balance, and statistics.

- **Platform:** Flutter (mobile)
- **Storage:** Local — Drift (SQLite ORM, pure Dart, no raw SQL)
- **Auth:** Firebase Authentication only (online sign-in, local data)
- **Future:** Online backup via Supabase (PostgreSQL — same SQL structure, smooth migration)
- **Language:** Arabic (RTL)

---

## 2. Core Decisions

| Decision | Choice | Reason |
|---|---|---|
| Local DB | Drift (SQLite) | Type-safe, pure Dart queries, supports SUM/GROUP BY/JOIN |
| Auth | Firebase Auth | Lightweight, gives `uid` for future sync, no backend needed |
| State management | Provider | Simple, scalable |
| No capital tracking | MVP scope | Avoid complex calculations for now |
| No hardcoded income sources | User creates them | Flexible, reusable for any business |
| Transaction categories global | Shared across sources | One category can be used in many income sources |

---

## 3. Database — Final Entity Model

### 3 Tables

```
IncomeSource  ──<  FinancialTransaction  >── TransactionCategory
```

---

#### `IncomeSource` (مصدر الدخل)
```dart
class IncomeSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  RealColumn get starterBalance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  // ── Sync flags (future Supabase backup) ─────
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**Notes:**
- `starterBalance` = sum of all history before the app (user calculates manually)
- Formula: `Balance = starterBalance + Σ in − Σ out`
- One table only — no income type concept

---

#### `TransactionCategory` (نوع المعاملة)
```dart
class TransactionCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // 'in' | 'out' stored via TransactionDirectionConverter
  TextColumn get direction => text().map(const TransactionDirectionConverter())();
  DateTimeColumn get createdAt => dateTime()();

  // ── Sync flags (future Supabase backup) ─────
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**Notes:**
- Global — not tied to any specific income source
- One category can be used across many income sources
- Direction is fixed at creation (in/out) and cannot be changed
- User manages categories independently from income sources

---

#### `FinancialTransaction` (الحركة المالية)
```dart
class FinancialTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Belongs to one income source
  IntColumn get incomeSourceId => integer().references(IncomeSources, #id)();

  // Belongs to one transaction category
  IntColumn get categoryId => integer().references(TransactionCategories, #id)();

  /// True for system-generated rows (e.g. opening balance).
  /// System rows are included in sums but must NOT be editable by the user.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  // ── Sync flags (future Supabase backup) ─────
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**Notes:**
- Every financial transaction belongs to exactly ONE income source
- Every financial transaction belongs to exactly ONE transaction category
- `direction` is NOT stored here — inherited from `TransactionCategory.direction`
- `amount` is always non-null — no template concept
- `isSystem = true` rows are auto-created (e.g. opening balance) and must not be editable

---

### Relationships Summary

```
IncomeSource (1) ──────────────── (∞) FinancialTransaction
TransactionCategory (1) ────────── (∞) FinancialTransaction

IncomeSource        ←→  TransactionCategory  (many-to-many via FinancialTransaction)
FinancialTransaction →  IncomeSource          (belongs to one)
FinancialTransaction →  TransactionCategory   (belongs to one)
```

---

## 4. Business Logic

### Balance Calculation (per IncomeSource)
```
Balance = starterBalance
        + Σ amount WHERE incomeSourceId = X AND category.direction = 'in'
        − Σ amount WHERE incomeSourceId = X AND category.direction = 'out'
```

> Direction is resolved by joining FinancialTransaction with TransactionCategory.

### Statistics
- Per IncomeSource: total in, total out, balance, transaction count
- Per TransactionCategory: subtotal grouped by category across all or one source
- Filter by date range (daily / weekly / monthly)

---

## 5. User Flow

```
Splash
  └── Sign Up / Sign In (Firebase Auth)
        ├── Home (مصادر الدخل)
        │     └── List of IncomeSource cards with balance
        │           ├── Add IncomeSource (name, currency, starterBalance)
        │           └── IncomeSource Detail
        │                 ├── Stats: balance, total in, total out, count
        │                 ├── Financial transactions list (paginated)
        │                 ├── FAB (+) → Add FinancialTransaction
        │                 │     └── Pick category → fill amount, note, date
        │                 └── (⋯) Context menu
        │                       ├── Edit IncomeSource
        │                       └── Delete IncomeSource
        │
        ├── المعاملات (Financial Transactions)
        │     └── All financial transactions grouped by TransactionCategory
        │           └── Expandable section per category (paginated)
        │                 └── Future: Export PDF report per category
        │
        └── Settings
              └── Manage Categories (CRUD for TransactionCategories)
```

---

## 6. Screens List

| # | Screen | Type | Notes |
|---|---|---|---|
| 1 | Splash | Full screen | App logo + get started / sign in |
| 2 | Sign In | Full screen | Email + password + Google, forgot password |
| 3 | Sign Up | Full screen | Name + email + password + confirm |
| 4 | Forgot Password | Full screen | Email input → send reset link |
| 4b | Reset Sent | Full screen | Confirmation + resend option |
| 5 | Home | Full screen | List of IncomeSource cards with balance |
| 6 | Add IncomeSource | Full screen | Name, starterBalance, currency |
| 7 | IncomeSource Detail | Full screen | Stats grid + transactions list + FAB |
| 8 | Add FinancialTransaction | Bottom sheet | Pick category + amount + date + note |
| 9 | Edit FinancialTransaction | Bottom sheet | Same as add but pre-filled |
| 10 | Context Menu — IncomeSource | Overlay sheet | Edit / Delete |
| 11 | Edit IncomeSource | Full screen | Same as Add but pre-filled |
| 12 | Delete Confirmation | Dialog overlay | Confirm / Cancel |
| 13 | المعاملات | Full screen | All transactions grouped by category — expandable + paginated |
| 14 | Manage Categories | Full screen | CRUD for TransactionCategories (in Settings) |
| 15 | Add/Edit Category | Bottom sheet | Name + direction chip (in/out) |
| 16 | Settings | Full screen | Profile, change password, manage categories, sign out |

---

## 7. المعاملات Screen — UI/UX Detail

- Bottom nav bar tab — shows ALL financial transactions across all income sources
- Grouped by **TransactionCategory** — one expandable section per category
- Each section header shows: category name, direction badge, subtotal
- Each section body: paginated list of transactions (15 per page, load more on scroll)
- All sections collapsed by default — user expands what they need
- Pull to refresh
- **Future:** Export PDF button per category section

```
المعاملات Screen
  ├── [دخل الإنترنت  +]  ──── subtotal: $1,200   ▾ (expanded)
  │     ├── مقهى الإنترنت   |  $120  |  اليوم
  │     ├── مقهى الإنترنت   |  $80   |  أمس
  │     └── ... (load more)
  │
  ├── [مباريات كرة القدم  +]  ── subtotal: $340   › (collapsed)
  │
  └── [فواتير الإنترنت  −]  ─── subtotal: $200   › (collapsed)
```

---

## 8. Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
│
├── db/
│   ├── tables.dart                      # Drift table definitions
│   ├── app_db.dart                      # Database class + connection
│   └── app_db.g.dart                    # Generated — do not edit
│
├── model/
│   ├── transaction_direction.dart       # enum TransactionDirection + converter
│   └── app_state.dart                   # sealed AppState<T> + ActionState
│
├── repositories/
│   ├── db_controller.dart               # abstract DbController<T>
│   ├── income_source_repo.dart          # CRUD for IncomeSources
│   ├── transaction_category_repo.dart   # CRUD for TransactionCategories
│   └── financial_transaction_repo.dart  # CRUD + stats + balance
│
├── providers/
│   ├── auth_provider.dart
│   ├── home_provider.dart               # income sources list + actions
│   ├── income_source_detail_provider.dart
│   ├── transactions_page_provider.dart  # المعاملات grouped by category
│   └── category_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── signin_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── income_source/
│   │   ├── add_income_source_screen.dart
│   │   ├── edit_income_source_screen.dart
│   │   └── income_source_detail_screen.dart
│   ├── transactions/
│   │   └── transactions_screen.dart     # المعاملات — grouped expandable
│   ├── categories/
│   │   └── manage_categories_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
├── widgets/
│   ├── components.dart                  # shared reusable components
│   ├── income_source/
│   │   ├── income_source_card.dart
│   │   ├── stat_grid.dart
│   │   ├── financial_transaction_item.dart
│   │   ├── add_transaction_sheet.dart
│   │   └── source_context_menu.dart
│   └── transactions/
│       └── category_expandable_section.dart
│
├── router/
│   ├── app_router.dart
│   └── app_transitions.dart
│
└── utils/
    ├── source_color.dart                # color derived from ID
    ├── constants.dart                   # currencies list
    └── formatters.dart                  # date, currency formatters
```

---

## 9. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  firebase_core: ^3.0.0
  firebase_auth: ^6.4.0
  google_sign_in: ^7.2.0
  provider: ^6.1.0
  intl: ^0.19.0
  go_router: ^14.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
```

---

## 10. Database Class (app_db.dart)

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../model/transaction_direction.dart';
import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [IncomeSources, TransactionCategories, FinancialTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 4) {
            await m.deleteTable('financial_transactions');
            await m.deleteTable('transaction_categories');
            await m.deleteTable('income_sources');
            await m.createAll();
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'madakhel.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## 11. Key Queries (Repositories)

```dart
// Balance for an IncomeSource
Future<double> getBalance(int incomeSourceId) async {
  final source = await (db.select(db.incomeSources)
    ..where((s) => s.id.equals(incomeSourceId))).getSingle();

  final rows = await (db.select(db.financialTransactions).join([
    innerJoin(db.transactionCategories,
        db.transactionCategories.id
            .equalsExp(db.financialTransactions.categoryId))
  ])
    ..where(db.financialTransactions.incomeSourceId.equals(incomeSourceId)
        & db.financialTransactions.isSystem.equals(false)))
  .get();

  double totalIn = 0;
  double totalOut = 0;
  for (final row in rows) {
    final tx = row.readTable(db.financialTransactions);
    final cat = row.readTable(db.transactionCategories);
    if (cat.direction == TransactionDirection.inbound) {
      totalIn += tx.amount;
    } else {
      totalOut += tx.amount;
    }
  }
  return source.starterBalance + totalIn - totalOut;
}

// Get transactions for an income source — paginated
Future<List<TypedResult>> getTransactionsPaginated({
  required int incomeSourceId,
  required int page,
  int pageSize = 15,
}) {
  return (db.select(db.financialTransactions).join([
    innerJoin(db.transactionCategories,
        db.transactionCategories.id
            .equalsExp(db.financialTransactions.categoryId))
  ])
    ..where(db.financialTransactions.incomeSourceId.equals(incomeSourceId))
    ..orderBy([OrderingTerm.desc(db.financialTransactions.date)])
    ..limit(pageSize, offset: page * pageSize))
  .get();
}

// Get all transactions grouped by category — for المعاملات screen
Future<Map<TransactionCategory, List<FinancialTransaction>>>
    getAllGroupedByCategory() async {
  final rows = await (db.select(db.financialTransactions).join([
    innerJoin(db.transactionCategories,
        db.transactionCategories.id
            .equalsExp(db.financialTransactions.categoryId))
  ])
    ..orderBy([OrderingTerm.desc(db.financialTransactions.date)]))
  .get();

  final Map<TransactionCategory, List<FinancialTransaction>> grouped = {};
  for (final row in rows) {
    final cat = row.readTable(db.transactionCategories);
    final tx = row.readTable(db.financialTransactions);
    grouped.putIfAbsent(cat, () => []).add(tx);
  }
  return grouped;
}
```

---

## 12. UI Design Decisions

- **Minimal colors:** green for `in`, red for `out`, black/white for everything else
- **RTL Arabic layout** throughout
- **Bottom nav bar:** Home (مصادر الدخل), المعاملات, Settings
- **Bottom sheets** for: Add/Edit FinancialTransaction, Add/Edit Category
- **Overlay context menu** for: IncomeSource actions
- **Stats grid (2×2):** balance, total in, total out, transaction count
- **FAB** on IncomeSource detail to add financial transactions
- **Expandable sections** on المعاملات screen — collapsed by default
- **Source dot color** derived from ID via `SourceColor.fromId(id)` — no DB column needed
- **Pagination:** 15 rows per page, load more on scroll

---

## 13. Auth Flow (Firebase)

```dart
// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email, password: password);

// Sign in with email
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email, password: password);

// Sign in with Google (google_sign_in ^7.2.0)
final googleUser = await GoogleSignIn.instance.authenticate();
final googleAuth = await googleUser.authentication;
final credential = GoogleAuthProvider.credential(
  idToken: googleAuth.idToken,
  accessToken: googleAuth.accessToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);

// Reset password
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

// Sign out
await FirebaseAuth.instance.signOut();

// UID for future Supabase sync
final uid = FirebaseAuth.instance.currentUser?.uid;
```

---

## 14. State Handling Pattern

```dart
// lib/model/app_state.dart

sealed class AppState<T> {}
class IdleState<T> extends AppState<T> {}
class LoadingState<T> extends AppState<T> {}
class SuccessState<T> extends AppState<T> { final T data; }
class ErrorState<T> extends AppState<T> { final String message; }

sealed class ActionState {}
class ActionIdle extends ActionState {}
class ActionLoading extends ActionState {}
class ActionSuccess extends ActionState { final String? message; }
class ActionError extends ActionState { final String message; }
```

---

## 15. Router (GoRouter)

```
Transitions:
  fadeScale       → root screens (splash, signin, home)
  slideHorizontal → push deeper (detail, edit)
  slideVertical   → sheet-like screens
  fadeThrough     → tab switches

Routes:
  /splash
  /signin
  /signup
  /forgot-password
  /home
  /income-source/:id              → IncomeSourceDetailScreen
  /income-source/:id/edit         → EditIncomeSourceScreen
  /categories                     → ManageCategoriesScreen
  /transactions                   → TransactionsScreen (المعاملات)
  /settings
```

---

## 16. Sync Flags — Rules & Usage

Every table has 4 sync flags for future Supabase backup:

| Flag | Type | Default | Purpose |
|---|---|---|---|
| `updatedAt` | `DateTime` | now | Updated on every local change — conflict resolution |
| `syncStatus` | `String` | `'pending'` | `pending` = not synced, `synced` = pushed, `failed` = retry |
| `remoteId` | `String?` | `null` | Supabase UUID — null until first sync |
| `isDeleted` | `bool` | `false` | Soft delete — row stays until synced then purged |

### Rules

**1. Always filter deleted rows in every query:**
```dart
..where((t) => t.isDeleted.equals(false))
```

**2. Set `updatedAt` on every insert and update:**
```dart
// insert
createdAt: DateTime.now(),
updatedAt: DateTime.now(),
syncStatus: const Value('pending'),

// update
updatedAt: DateTime.now(),
syncStatus: const Value('pending'),  // re-mark for sync
```

**3. Soft delete — never hard delete until synced:**
```dart
// instead of db.delete(...)
await (db.update(db.incomeSources)..where((t) => t.id.equals(id)))
    .write(IncomeSourcesCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));
```

**4. Why soft delete:**
```
Hard delete → row gone locally → Supabase never knows → ghost data
Soft delete → isDeleted=true → sync sends delete → purge locally
```

---

## 17. Future Roadmap (do NOT build in MVP)

- [ ] PDF export per TransactionCategory from المعاملات screen
- [ ] Online backup → Supabase (PostgreSQL, same SQL structure)
- [ ] Recurring financial transactions
- [ ] Date range filters (daily/weekly/monthly reports)
- [ ] Export to CSV
- [ ] Snapshot/saved reports
- [ ] Multi-currency conversion

---

*Generated from full design conversation. Last updated: May 2026 — v3 (sync flags added).*
