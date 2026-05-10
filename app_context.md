# مداخيل — Incomes App — Cursor Agent Context

> Full project context from design conversation. Use this as the single source of truth for building the app.

---

## 1. Project Overview

A Flutter mobile app to help a friend organize multiple income sources (e.g. Internet Café, Source B, Source C). Each income source is fully standalone with its own transaction types, balance, and statistics.

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
| State management | Provider or Riverpod | Simple, scalable |
| No capital tracking | MVP scope | Avoid complex calculations for now |
| No hardcoded income types | User creates them | Flexible, reusable for any business |

---

## 3. Database — Final Entity Model

### MVP Tables (build these now)

#### `IncomeTypes`
```dart
class IncomeTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get starterBalance => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  DateTimeColumn get createdAt => dateTime()();
}
```

**Notes:**
- `starterBalance` = sum of all history before the app started (user calculates manually)
- Formula: `Current Balance = starterBalance + Σ in transactions − Σ out transactions`
- Optional field, defaults to 0 if business starts fresh with the app

#### `Transactions`
```dart
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get incomeTypeId => integer().references(IncomeTypes, #id)();
  TextColumn get name => text()(); // e.g. "Football Matches Income"
  TextColumn get direction => text()(); // 'in' | 'out'
  RealColumn get amount => real().nullable()(); // null = template, value = real transaction
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
```

**Notes:**
- `amount = null` means this row is a **template** (shown in menu when adding a transaction)
- `amount != null` means this is a **real transaction**
- `direction` is fixed at creation — inherited from the template
- No separate TransactionType/Category table needed

### Future Tables (do NOT build yet)

```
Category              — tag transactions (salary, supplies, etc.)
RecurringTransaction  — auto-repeat entries (daily/weekly/monthly)
Snapshot/Report       — saved summaries per period
```

---

## 4. Business Logic

### Balance Calculation (per IncomeType)
```
Balance = starterBalance
        + Σ transactions WHERE direction = 'in' AND amount IS NOT NULL
        − Σ transactions WHERE direction = 'out' AND amount IS NOT NULL
```

### Template vs Real Transaction
```
Template row:  amount = null, date = null  → shown in dropdown menu
Real row:      amount = value, date = set  → counted in balance & stats
```

### Statistics
- Per IncomeType: total in, total out, balance, transaction count
- Per transaction name (GROUP BY name): subtotal for each type
- Filter by date range (daily / weekly / monthly)

---

## 5. User Flow

```
Splash
  └── Sign Up / Sign In (Firebase Auth)
        └── Home — list of IncomeTypes with balances
              ├── Add IncomeType
              │     ├── Fill: name, starterBalance, currency
              │     └── Add TransactionTypes (name + direction)
              │           └── Each type: name + direction (in/out) → saved as template rows
              └── IncomeType Detail
                    ├── Stats: balance, total in, total out, count
                    ├── Recent transactions list
                    ├── FAB (+) → Add Transaction
                    │     └── Pick template from dropdown → fill amount, note, date
                    └── (⋯) Context menu
                          ├── Edit IncomeType (name, currency, starterBalance)
                          ├── Edit/Delete TransactionTypes
                          └── Delete IncomeType
```

---

## 6. Screens List

| # | Screen | Type | Notes |
|---|---|---|---|
| 1 | Splash | Full screen | App logo + get started / sign in |
| 2 | Sign In | Full screen | Email + password, forgot password link |
| 3 | Sign Up | Full screen | Name + email + password + confirm |
| 4 | Forgot Password | Full screen | Email input → send reset link |
| 4b | Reset Sent | Full screen | Confirmation + resend option |
| 5 | Home | Full screen | List of IncomeType cards with balance |
| 6 | Add IncomeType | Full screen | Name, starterBalance, currency + transaction types list |
| 7 | Add TransactionType | Bottom sheet | Name + direction chip (in/out) |
| 8 | IncomeType Detail | Full screen | Stats grid + recent transactions + FAB |
| 9 | Context Menu — IncomeType | Overlay sheet | Edit / Add tx type / Delete |
| 10 | Edit IncomeType | Full screen | Same as Add but pre-filled |
| 11 | Context Menu — TransactionType | Overlay sheet | Edit / Delete |
| 12 | Edit TransactionType | Bottom sheet | Same as Add tx type but pre-filled |
| 13 | Delete Confirmation | Dialog overlay | Confirm / Cancel |
| 14 | Add Transaction | Bottom sheet | Dropdown (templates) + amount + date + note |
| 15 | Settings | Full screen | Profile, change password, export CSV, sign out |

---

## 7. Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
│
├── db/
│   ├── tables.dart          # Drift table definitions
│   ├── app_db.dart          # Database class + connection
│   └── app_db.g.dart        # Generated by build_runner (do not edit)
│
├── models/
│   └── (Drift generates these from tables)
│
├── repositories/
│   ├── income_type_repo.dart    # CRUD for IncomeTypes
│   └── transaction_repo.dart   # CRUD + stats for Transactions
│
├── providers/
│   ├── auth_provider.dart
│   ├── income_type_provider.dart
│   └── transaction_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── signin_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── income_type/
│   │   ├── add_income_type_screen.dart
│   │   ├── edit_income_type_screen.dart
│   │   └── income_type_detail_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
├── widgets/
│   ├── income_type_card.dart
│   ├── transaction_row.dart
│   ├── stat_card.dart
│   ├── add_transaction_sheet.dart
│   ├── add_tx_type_sheet.dart
│   ├── context_menu_sheet.dart
│   └── delete_confirm_dialog.dart
│
└── utils/
    ├── constants.dart           # currencies, direction enum
    └── formatters.dart          # date, currency formatters
```

---

## 8. Dependencies

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  provider: ^6.1.0             # or riverpod
  intl: ^0.19.0                # date + number formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
```

---

## 9. Setup Steps

```bash
# 1. Create project
flutter create incomes_app
cd incomes_app

# 2. Add dependencies (pubspec.yaml — see above)
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Generate Drift code (after writing tables.dart + app_db.dart)
dart run build_runner build

# 5. Run
flutter run
```

---

## 10. Database Class (app_db.dart)

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [IncomeTypes, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'incomes.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## 11. Key Queries (Repositories)

```dart
// Balance for an IncomeType
Future<double> getBalance(int incomeTypeId) async {
  final type = await (db.select(db.incomeTypes)
    ..where((t) => t.id.equals(incomeTypeId))).getSingle();

  final inSum = await (db.selectOnly(db.transactions)
    ..addColumns([db.transactions.amount.sum()])
    ..where(db.transactions.incomeTypeId.equals(incomeTypeId) &
            db.transactions.direction.equals('in') &
            db.transactions.amount.isNotNull()))
    .map((r) => r.read(db.transactions.amount.sum()) ?? 0.0)
    .getSingle();

  final outSum = await (db.selectOnly(db.transactions)
    ..addColumns([db.transactions.amount.sum()])
    ..where(db.transactions.incomeTypeId.equals(incomeTypeId) &
            db.transactions.direction.equals('out') &
            db.transactions.amount.isNotNull()))
    .map((r) => r.read(db.transactions.amount.sum()) ?? 0.0)
    .getSingle();

  return type.starterBalance + inSum - outSum;
}

// Get templates (menu items) for an IncomeType
Future<List<Transaction>> getTemplates(int incomeTypeId) {
  return (db.select(db.transactions)
    ..where((t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNull()))
    .get();
}

// Get real transactions for an IncomeType
Future<List<Transaction>> getTransactions(int incomeTypeId) {
  return (db.select(db.transactions)
    ..where((t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNotNull())
    ..orderBy([(t) => OrderingTerm.desc(t.date)]))
    .get();
}
```

---

## 12. UI Design Decisions

- **Minimal colors:** only green for `in`, red for `out`, black/white for everything else
- **RTL Arabic layout** throughout
- **Bottom sheets** for: Add Transaction, Add/Edit TransactionType
- **Overlay context menu** for: IncomeType actions, TransactionType actions
- **Stats grid (2x2):** balance, total in, total out, transaction count
- **FAB** on detail screen to add transactions
- **Tab bar:** Home, Transactions, Settings

---

## 13. Auth Flow (Firebase)

```dart
// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email, password: password);

// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email, password: password);

// Reset password
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

// Sign out
await FirebaseAuth.instance.signOut();

// Get current user uid (use for future Supabase sync)
final uid = FirebaseAuth.instance.currentUser?.uid;
```

---

## 14. Future Roadmap (do NOT build in MVP)

- [ ] Online backup → Supabase (PostgreSQL, same SQL structure)
- [ ] Recurring transactions
- [ ] Transaction categories/tags
- [ ] Date range filters (daily/weekly/monthly reports)
- [ ] Export to CSV
- [ ] Snapshot/saved reports
- [ ] Multi-currency conversion

---

*Generated from full design conversation. Last updated: May 2026.*
