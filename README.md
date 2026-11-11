# Farm Project Manager (Farmivo) 🌱📊

> **"Plan smarter. Farm with numbers. Know your profit."**

Farm Project Manager (Farmivo) is an offline-first agricultural financial planning, management, and decision-support mobile application built with Flutter. Specifically tailored for smallholders, commercial farmers, and agribusiness entrepreneurs in Ghana and across Africa, Farmivo bridges pre-season budgeting with operational field realities.

---

## 🌾 The 5 Critical Questions

Farmivo moves far beyond basic digital bookkeeping to help farmers answer:

1. **How much money will I need?** *(Pre-season category budgeting & capital requirements)*
2. **How much have I spent?** *(Real-time expense & casual labour tracking)*
3. **How much money am I making?** *(Yield, harvest storage, sales, and debtor collections)*
4. **Will this farm project be profitable?** *(Break-even yield/price, actual vs. projected profit, ROI)*
5. **Should I continue, change, or stop this project?** *(Automated project health scoring & sensitivity analysis)*

$$\text{Planning} \longrightarrow \text{Budget} \longrightarrow \text{Expenses} \longrightarrow \text{Production} \longrightarrow \text{Harvest} \longrightarrow \text{Sales} \longrightarrow \text{Cash Flow} \longrightarrow \text{Profit} \longrightarrow \text{Decision}$$

---

## 🚀 Core Features

- **Tri-Value Separation:** Never conflates **Planned** (budgeted), **Actual** (transacted), and **Projected** (reforecasted) figures.
- **Strict Minor-Unit Arithmetic:** Financial numbers are stored in 64-bit integer minor units (e.g., **Pesewas** for GHS: $\text{GH₵}1.00 = 100\text{ pesewas}$) to guarantee zero floating-point rounding errors.
- **100% Offline-First:** Runs completely without internet. All database queries, analytics, and PDF reports execute on-device using SQLite via Drift.
- **Fast Field Entry (<15s):** Streamlined expense entry optimized for one-handed outdoor operation under direct sunlight glare.
- **Harvest $\neq$ Sale:** Agricultural yields enter storage inventory and are tracked independently from credit or cash sales.
- **Algorithmic Health Scoring:** Rates projects as 🟢 **Healthy**, 🟡 **Watch**, or 🔴 **At Risk**, always accompanied by clear, actionable explanations.
- **Bank-Ready PDF Export:** One-tap generation of professional multi-page financial statements for investors, cooperatives, and commercial banks.
- **Local Biometrics & Encrypted Backup:** PIN and fingerprint authentication via `local_auth` and one-tap SQLite snapshot export/restore.

---

## 🛠 Tech Stack

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | **Flutter** (Latest Stable) | Cross-platform performance (Android & iOS) from a single Dart codebase. |
| **Architecture** | **Clean Architecture + Feature-First** | Modular scalability, testability, and strict layer isolation. |
| **State Management** | **Riverpod** (`flutter_riverpod` + code-gen) | Compile-time safe, testable dependency injection and reactive state streams. |
| **Database** | **Drift + SQLite** | Strongly-typed SQL queries, migrations, isolate-based concurrency, and offline transactions. |
| **Navigation** | **GoRouter** | Declarative typed routing, sub-routes, and auth/PIN guards. |
| **Security** | **flutter_secure_storage** + **local_auth** | Hardware-backed keystore/keychain storage and biometric security. |
| **Visualizations** | **fl_chart** | Outdoor-optimized interactive graphs (donuts, grouped bars, line charts). |
| **Reporting** | **pdf** & **printing** | Offline native PDF compilation and system share sheet integration. |

---

## 📚 Engineering Documentation

The project includes exhaustive engineering documentation in the repository:

- 📋 [**Product Requirements Document (PRD.md)**](./PRD.md) — Comprehensive 80-section product requirements, business rules, target personas, and scope.
- 🗺️ [**Implementation Roadmap (ROADMAP.md)**](./ROADMAP.md) — 10-milestone engineering breakdown with granular task lists, acceptance criteria, and Definitions of Done.
- 🏗️ [**Technical Architecture (docs/ARCHITECTURE.md)**](./docs/ARCHITECTURE.md) — System layer separation, directory structure, Riverpod reactive flows, and offline sync queue.
- 🗄️ [**Database Schema Specification (docs/DATABASE_SCHEMA.md)**](./docs/DATABASE_SCHEMA.md) — Exhaustive SQL DDL and Drift schemas for all 22+ tables, relationships, and minor-unit monetary fields.
- 🧮 [**Financial Engine & Formulas (docs/FINANCIAL_ENGINE.md)**](./docs/FINANCIAL_ENGINE.md) — Mathematical formulas for variance, break-even, ROI, health scoring (0-100), and pesewas arithmetic.
- 🎨 [**UI/UX & Field Usability (docs/UI_UX_SPECIFICATION.md)**](./docs/UI_UX_SPECIFICATION.md) — Sunlight-readable design tokens, $\ge 48\text{ dp}$ tap targets, and rapid entry flows (<15s).
- 🧪 [**Testing & Quality Assurance (docs/TESTING_STRATEGY.md)**](./docs/TESTING_STRATEGY.md) — Test pyramid, financial test vectors, offline recovery scenarios, and security benchmarks.

---

## 📁 Project Directory Structure

```text
farmivo/
├── PRD.md                             # Complete Product Requirements Document
├── ROADMAP.md                         # Step-by-Step Implementation Roadmap
├── README.md                          # Repository Overview
├── docs/                              # Deep-Dive Engineering Specifications
│   ├── ARCHITECTURE.md                # System Architecture & Layering
│   ├── DATABASE_SCHEMA.md             # Drift SQLite Schemas & Tables
│   ├── FINANCIAL_ENGINE.md            # Formulas, Minor Units & Health Scorer
│   ├── UI_UX_SPECIFICATION.md         # Field Usability & Outdoor Tokens
│   └── TESTING_STRATEGY.md            # Test Suite & Verification Matrix
├── lib/
│   ├── app/                           # App Bootstrapping, Router & Themes
│   ├── core/                          # Constants, Errors, Money Value Object, Security
│   ├── data/                          # Drift Database, Repositories, DAOs, Sync
│   ├── features/                      # Feature-First Modules
│   │   ├── dashboard/                 # Overview KPIs & Speed Dial
│   │   ├── farms/                     # Landholdings & Properties
│   │   ├── projects/                  # Projects Lifecycle & State Machine
│   │   ├── budgets/                   # Pre-season Budgeting
│   │   ├── expenses/                  # Expense Tracking & Variance
│   │   ├── activities/                # Agronomic Operations & Labour
│   │   ├── harvests/                  # Harvests & Inventory
│   │   ├── sales/                     # Commercial Sales & Buyers
│   │   ├── payments/                  # Receivables & Installments
│   │   ├── scenarios/                 # Sensitivity Analysis
│   │   └── reports/                   # PDF & CSV Exporting
│   └── shared/                        # Reusable Widgets, Dialogs & Charts
└── test/                              # Unit, Database, and Widget Test Suites
```

---

## ⚡ Quick Start for Developers

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.29+ recommended)
- Dart SDK 3.7+
- Android Studio / VS Code with Flutter extensions

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/your-org/farmivo.git
cd farmivo
flutter pub get
```

### 2. Run Code Generation (Drift, Riverpod, Freezed)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Launch Application
```bash
flutter run
```

---

## 📄 License
Farmivo is released under the [MIT License](./LICENSE).
