# Farm Project Manager (Farmivo)
# Testing & Quality Assurance Strategy

**Target Coverage:** $>85\%$ for Domain & Financial Engine, $>70\%$ overall  
**Test Categories:** Unit, Repository / Database, Widget, Integration, Offline Resilience, and Security

---

## 1. Test Pyramid & Automation Strategy

```
           /\
          /  \     End-to-End & Integration (10%)
         /----\    Full season lifecycle, PDF generation, backup/restore
        /      \
       /--------\   Widget & Flow Tests (25%)
      /          \  Expense form <15s, forms validation, reactive UI
     /------------\
    /              \ Unit & Repository Tests (65%)
   /________________\ Financial engine, minor units, Drift SQLite DAOs
```

---

## 2. Unit Testing Suite (Financial Core)

### 2.1 Critical Test Vectors
- **Minor-Unit Arithmetic:**
  - Verify that adding `100.20 GHS` and `50.10 GHS` in pesewas equals exactly `15030 pesewas` with zero binary IEEE-754 floating-point drift.
  - Verify multiplication of fractional quantities (e.g., $3.75\text{ kg} \times \text{GH₵}12.50$).
- **Variance Formulas:**
  - Standard overrun: Planned $\text{GH₵}1,000$, Actual $\text{GH₵}1,250 \to \text{Variance} = +\text{GH₵}250$ ($+25\%$).
  - Zero-budget spending: Planned $\text{GH₵}0$, Actual $\text{GH₵}500 \to$ Safe handling without division by zero.
  - Under-budget savings: Planned $\text{GH₵}1,000$, Actual $\text{GH₵}700 \to \text{Variance} = -\text{GH₵}300$ ($-30\%$).
- **Break-Even Edge Cases:**
  - Verify that when expected unit price is zero or negative, the calculator returns an explicit validation failure rather than `Infinity` or `NaN`.
- **Project Health Algorithm:**
  - High debt test: Project with $90\%$ uncollected receivables triggers `At Risk` or `Watch` status.
  - Budget overrun test: Expense exceeding $130\%$ of total budget drops health score below 60.

---

## 3. Database & Repository Integration Tests

### 3.1 In-Memory Drift Database Harness
Use Drift's `NativeDatabase.memory()` to spin up clean, isolated SQLite instances per test suite:
```dart
void main() {
  late AppDatabase db;
  late ExpenseRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ExpenseRepositoryImpl(db);
  });

  tearDown(() async => await db.close());

  test('saving an expense updates category spent aggregation', () async {
    // 1. Insert farm and project
    // 2. Insert budget item
    // 3. Insert expense
    // 4. Verify stream emission
  });
}
```

### 3.2 Transactional Rollbacks & Concurrency
- Test that failing midway through an atomic multi-table operation (e.g. creating an activity with an auto-generated expense) cleanly rolls back with no orphan records.

---

## 4. Offline Resilience & Sync Verification

| Test Scenario | Steps Executed | Expected Verification Result |
| :--- | :--- | :--- |
| **Offline Transaction Save** | Disconnect network $\to$ Record expense $\to$ Verify UI. | Expense appears instantly in UI; marked `is_synced = 0`. |
| **Cold Kill During Inactivity** | Record transactions $\to$ Hard terminate app process $\to$ Relaunch. | Database opens cleanly; all recorded data is intact. |
| **Connectivity Resumption** | Re-enable Wi-Fi / Cellular $\to$ Trigger sync queue worker. | Pending changes dispatched sequentially to mock server; marked `is_synced = 1`. |
| **Sync Server Failure** | Simulate HTTP 500 / Timeout during sync upload. | Local records remain completely untouched; retry counter increments with exponential backoff. |

---

## 5. Security & Cryptographic Tests

- **PIN Security:**
  - Verify incorrect PIN entry 5 times locks authentication for 60 seconds.
  - Verify PIN salt + hash storage in mock secure storage.
- **Biometric Bypass Prevention:**
  - Verify that app lifecycle change (backgrounded $\to$ foregrounded) immediately surfaces the biometric/PIN lock screen.
- **Backup Verification:**
  - Export database to compressed backup archive.
  - Delete local database.
  - Restore from backup archive.
  - Verify all 22+ tables, relationships, and foreign keys restore with zero data loss.

