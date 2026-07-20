<div align="center">

<img src="assets/images/logo.png" alt="مداخيل Logo" width="100" height="100" style="border-radius:20px"/>

# مداخيل — Madakhel

**تطبيق Flutter لتتبّع مصادر الدخل · A Flutter app for tracking income sources**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black)
![Drift](https://img.shields.io/badge/Drift-SQLite-003B57?logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-red)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)

</div>

---

## العربية

### نظرة عامة

**مداخيل** تطبيق موبايل مبني بـ Flutter يساعد أصحاب الأعمال الصغيرة على تنظيم مصادر دخلهم المتعددة، تتبّع الحركات المالية، ومعرفة الرصيد الحقيقي لكل مصدر في أي وقت.

### المميزات الرئيسية

- 📊 **مصادر دخل متعددة** — أضف أي عدد من مصادر الدخل بعملات مختلفة
- 💰 **حساب الرصيد التلقائي** — رصيد حقيقي = رصيد ابتدائي + دخل − مصروف
- 🗂️ **فئات معاملات عامة** — أنشئ فئات (دخل/مصروف) وشاركها بين جميع المصادر
- 📋 **المعاملات** — عرض جميع الحركات المالية مصنّفة بقوائم قابلة للطي
- 🔐 **تسجيل دخول آمن** — Firebase Auth مع دعم Google Sign-In
- 🌙 **وضع داكن/فاتح/تلقائي** — يتبع إعداد الجهاز تلقائياً
- 📴 **يعمل بدون إنترنت** — كل البيانات محلية على الجهاز
- 🔄 **نسخ احتياطي عبر Supabase** — مزامنة البيانات مع قاعدة بيانات Supabase السحابية

### التقنيات المستخدمة

| التقنية | الاستخدام |
|---|---|
| Flutter + Dart | إطار العمل الأساسي |
| Drift (SQLite) | قاعدة بيانات محلية — ORM نقي بـ Dart |
| Firebase Auth | المصادقة وتسجيل الدخول |
| Google Sign-In | تسجيل دخول سريع بحساب Google |
| Provider | إدارة الحالة |
| GoRouter | التنقل بين الشاشات |
| Cairo Font | خط عربي للواجهة |

### هيكل قاعدة البيانات

```
IncomeSources ──< FinancialTransactions >── TransactionCategories
مصادر الدخل       الحركات المالية            فئات المعاملات
```

**معادلة الرصيد:**
```
الرصيد = الرصيد الابتدائي + Σ حركات الدخل − Σ حركات المصروف
```

---

## English

### Overview

**Madakhel** (Arabic for "Incomes") is an offline-first Flutter mobile app designed to help small business owners organize multiple income sources, track financial transactions, and instantly know the real balance of each source.

### Key Features

- 📊 **Multiple income sources** — add unlimited sources with different currencies
- 💰 **Auto balance calculation** — real balance = starter balance + income − expenses
- 🗂️ **Global transaction categories** — create in/out categories shared across all sources
- 📋 **Transactions view** — all financial movements grouped by category with expandable lists
- 🔐 **Secure authentication** — Firebase Auth with Google Sign-In support
- 🌙 **Dark / Light / System theme** — follows device preference automatically
- 📴 **Fully offline** — all data stored locally on the device
- 🔄 **Supabase cloud backup** — sync local data to Supabase PostgreSQL

### Tech Stack

| Technology | Purpose |
|---|---|
| Flutter + Dart | Core framework |
| Drift (SQLite ORM) | Local database — pure Dart, no raw SQL |
| Firebase Auth | Authentication & sign-in |
| Google Sign-In `^7.2.0` | One-tap Google login |
| Provider | State management |
| GoRouter | Navigation + transitions |
| Cairo Font | Arabic-first typography |

### Architecture

```
lib/
├── db/                  # Drift tables + generated code
├── model/               # Sealed states, enums, converters
├── repositories/        # Data layer — abstract DbController<T>
├── providers/           # Business logic — ChangeNotifier
├── screens/             # UI screens
├── widgets/             # Reusable components
├── router/              # GoRouter + pure Flutter transitions
└── utils/               # Colors, formatters, constants
```

### Database Schema

3 tables — all carry sync flags for future cloud backup:

```dart
// Every table includes:
DateTimeColumn get updatedAt  // conflict resolution
TextColumn get syncStatus     // 'pending' | 'synced' | 'failed'
TextColumn get remoteId       // Supabase UUID — null until synced
BoolColumn get isDeleted      // soft delete
```

### Screens

| Screen | Description |
|---|---|
| Splash | App entry point |
| Sign In / Sign Up | Email + Google authentication |
| Forgot Password | Firebase reset link with confirmation state |
| Home | Income source cards with live balance |
| Source Detail | Stats grid + paginated financial transactions |
| Add/Edit Source | Name, currency, starter balance |
| Financial Transaction | Add/edit — pick category, amount, date, note |
| المعاملات | All transactions grouped by category — expandable + paginated |
| Manage Categories | Global CRUD for transaction categories |
| Settings | Theme, profile, sign out |

### Getting Started

```bash
# 1. Clone the repo
git clone https://github.com/zahershaat/madakhel.git
cd madakhel

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Generate Drift code
dart run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

### Requirements

```
Flutter  ≥ 3.x
Dart     ≥ 3.x
Android  API 23+ (minSdk)
compileSdk 36
```

### Environment Setup

- Add `google-services.json` to `android/app/`
- Add your SHA-1 fingerprint in Firebase Console
- Firebase project must have **Email/Password** and **Google** sign-in enabled

### Roadmap

**MVP — Completed ✅**
- [x] Offline-first local storage with Drift
- [x] Firebase Auth + Google Sign-In (email & Google)
- [x] Multi-source income tracking with custom currencies
- [x] Global transaction categories (in/out)
- [x] Financial transactions — full CRUD
- [x] Auto balance calculation per source
- [x] Transactions view — grouped by category, expandable + paginated
- [x] Dark / Light / System theming
- [x] Arabic RTL UI with Cairo font
- [x] Soft delete with sync flags for all tables
- [x] Pure Flutter navigation transitions (no packages)
- [x] Supabase cloud backup & sync

**Future Features 🔜**
- [ ] PDF export per transaction category
- [ ] Date range filters & reports

---

<div align="center">

Built with ❤️ by [Zaher Shaat](https://zahershaat.github.io)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Zaher_Shaat-0077B5?logo=linkedin)](https://www.linkedin.com/in/%D8%B2%D8%A7%D9%87%D8%B1-%D8%A3%D8%AD%D9%85%D8%AF-%D8%B4%D8%B9%D8%AA-%F0%9F%87%B5%F0%9F%87%B8-52b2b3293/)
[![Portfolio](https://img.shields.io/badge/Portfolio-zahershaat.github.io-black?logo=github)](https://zahershaat.github.io)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-Contact-25D366?logo=whatsapp&logoColor=white)](https://wa.me/970597826287)

</div>
