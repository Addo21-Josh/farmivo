# Farm Project Manager (Farmivo)
# Financial Engine & Calculation Specifications

**Core Rule:** *Never mix Planned, Actual, and Projected values. Never use floating-point numbers for money.*

---

## 1. Monetary Representation & Arithmetic

### 1.1 The Minor-Unit Rule
All monetary calculations in Farmivo operate strictly on integer minor currency units:
- For Ghanaian Cedi (`GHS`): The minor unit is **Pesewas** ($1\text{ GHS} = 100\text{ pesewas}$).
  - Example: $\text{GH₵}1,250.75 \longrightarrow 125,075\text{ pesewas}$.
- For Nigerian Naira (`NGN`): Minor unit is Kobo ($1\text{ NGN} = 100\text{ kobo}$).
- For Kenyan Shilling (`KES`): Minor unit is Cents ($1\text{ KES} = 100\text{ cents}$).
- For US Dollar (`USD`): Minor unit is Cents ($1\text{ USD} = 100\text{ cents}$).

### 1.2 Dart `Money` Value Object
```dart
@immutable
class Money {
  final BigInt minorUnits; // Stored in pesewas
  final String currency;   // 'GHS'

  const Money(this.minorUnits, {this.currency = 'GHS'});

  factory Money.fromMajor(num major, {String currency = 'GHS'}) {
    final minor = (major * 100).round();
    return Money(BigInt.from(minor), currency: currency);
  }

  double toMajor() => minorUnits.toInt() / 100.0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  Money multiplyByQuantity(double quantity) {
    final result = (minorUnits.toDouble() * quantity).round();
    return Money(BigInt.from(result), currency: currency);
  }

  String format() {
    final major = toMajor();
    final fmt = NumberFormat.currency(symbol: 'GH₵', decimalDigits: 2);
    return fmt.format(major);
  }
}
```

---

## 2. Core Tri-Value Model

```
       PLANNED
 (What you budget)
        │
        ├────────────────────────┐
        ▼                        ▼
     ACTUAL                  PROJECTED
 (What happened)       (Dynamic current expectation)
```

| Dimension | Definition | Source of Data |
| :--- | :--- | :--- |
| **Planned Cost** | Total capital budgeted prior to project launch. | Sum of `budget_items.planned_amount_minor`. |
| **Actual Cost** | Total money disbursed in confirmed operational expenses. | Sum of active `expenses.amount_minor` where `is_voided = FALSE`. |
| **Projected Cost** | Best forecast of total expenditure at completion. | $\text{Actual Incurred} + \max(0, \text{Planned} - \text{Actual})$. |
| **Planned Revenue** | Pre-season anticipated sales from budgeted yield & price. | Budgeted Yield $\times$ Budgeted Selling Price. |
| **Actual Revenue** | Contracted sales value dispatched to buyers. | Sum of active `sales.total_amount_minor` where `is_voided = FALSE`. |
| **Collected Revenue**| Liquid cash actually received from buyers. | Sum of active `payments.amount_minor` where `is_voided = FALSE`. |
| **Projected Revenue**| Anticipated final income based on progress to date. | $\text{Actual Sales} + (\text{Remaining Unharvested Yield} \times \text{Expected Price})$. |

---

## 3. Mathematical Formulas

### 3.1 Budget Variance
$$\text{Variance Amount} = \text{Actual Amount} - \text{Planned Amount}$$
$$\text{Variance Percentage} = \begin{cases} \left( \frac{\text{Actual} - \text{Planned}}{\text{Planned}} \right) \times 100 & \text{if Planned} > 0 \\ 0\% & \text{if Planned} = 0 \end{cases}$$

#### Variance Threshold Classifications:
- **Normal:** $\text{Actual} < 0.80 \times \text{Planned}$ (Green)
- **Warning:** $0.80 \times \text{Planned} \le \text{Actual} < 1.00 \times \text{Planned}$ (Yellow: approaching cap)
- **Critical:** $\text{Actual} = 1.00 \times \text{Planned}$ (Orange: budget depleted)
- **Overrun:** $\text{Actual} > 1.00 \times \text{Planned}$ (Red: budget breached)

---

### 3.2 Receivables & Debtor Aging
$$\text{Outstanding Balance} = \text{Gross Sale Amount} - \sum \text{Payments Received}$$

```text
Sale Status:
- If Outstanding == 0             -> PAID
- If 0 < Outstanding < GrossSale -> PARTIAL
- If Payments == 0                -> UNPAID (Credit)
```

---

### 3.3 Profitability Metrics

#### Actual Net Profit (Accrual Basis):
$$\text{Actual Net Profit} = \text{Actual Sales Revenue} - \text{Actual Incurred Costs}$$

#### Cash-Basis Profit (Liquidity Basis):
$$\text{Cash Profit} = \text{Collected Revenue} - \text{Actual Cash Disbursed}$$

#### Projected Final Profit:
$$\text{Projected Final Profit} = \text{Projected Total Revenue} - \text{Projected Final Cost}$$

---

### 3.4 Return on Investment (ROI)
$$\text{Actual ROI \%} = \begin{cases} \left( \frac{\text{Actual Net Profit}}{\text{Actual Incurred Costs}} \right) \times 100 & \text{if Actual Cost} > 0 \\ 0\% & \text{if Actual Cost} \le 0 \end{cases}$$

$$\text{Projected ROI \%} = \begin{cases} \left( \frac{\text{Projected Net Profit}}{\text{Planned Total Cost}} \right) \times 100 & \text{if Planned Cost} > 0 \\ 0\% & \text{if Planned Cost} \le 0 \end{cases}$$

*UI Requirement: The user interface must never render bare "ROI: 120%". It must state "Actual ROI: 45%" or "Projected ROI: 120%" explicitly.*

---

### 3.5 Break-Even Analysis

#### 1. Break-Even Revenue:
$$\text{Break-Even Revenue} = \text{Total Costs (Actual to Date or Budgeted)}$$

#### 2. Break-Even Output Volume (Quantity):
$$\text{Break-Even Quantity} = \frac{\text{Total Budgeted Cost}}{\text{Unit Selling Price}}$$

#### 3. Break-Even Unit Price:
$$\text{Break-Even Unit Price} = \frac{\text{Total Budgeted Cost}}{\text{Total Expected Yield}}$$

---

### 3.6 Cash Flow Liquidity
$$\text{Closing Cash Balance} = \text{Opening Balance} + \sum \text{Cash In} - \sum \text{Cash Out}$$
$$\text{Cash Burn Rate} = \frac{\text{Total Actual Expenses}}{\text{Days Elapsed since Start Date}}$$
$$\text{Cash Runway (Days)} = \begin{cases} \frac{\text{Current Cash Balance}}{\text{Cash Burn Rate}} & \text{if Burn Rate} > 0 \\ \infty & \text{otherwise} \end{cases}$$

---

## 4. Algorithmic Project Health Scoring Engine

The Health Scorer computes a composite score ($0 - 100$) for every active project using five weighted indices:

$$\text{Score} = (0.30 \times S_{\text{budget}}) + (0.25 \times S_{\text{revenue}}) + (0.20 \times S_{\text{cash}}) + (0.15 \times S_{\text{schedule}}) + (0.10 \times S_{\text{credit}})$$

### Sub-Score Evaluation:

| Sub-Score | Logic & Formula | Maximum |
| :--- | :--- | :--- |
| **$S_{\text{budget}}$ (Budget Discipline)** | $100 - \max(0, \text{Variance \%})$. Clamped to $[0, 100]$. | 100 |
| **$S_{\text{revenue}}$ (Sales Execution)** | $\min\left(100, \left(\frac{\text{Actual Sales}}{\text{Expected Sales to Date}}\right) \times 100\right)$. | 100 |
| **$S_{\text{cash}}$ (Liquidity Buffer)** | If Cash Runway $> 30\text{ days} \to 100$; if $15-30\text{ days} \to 75$; if $<7\text{ days} \to 25$. | 100 |
| **$S_{\text{schedule}}$ (Timeline Drift)**| Ratio of completed milestones vs days elapsed. | 100 |
| **$S_{\text{credit}}$ (Debtor Risk)** | $100 - \left(\frac{\text{Uncollected Receivables}}{\text{Total Sales}} \times 100\right)$. | 100 |

### Health Classification & Plain-Language Diagnostics:
- **🟢 Healthy ($\ge 80$):**
  > *"Project is performing within budgeted parameters with adequate liquidity."*
- **🟡 Watch ($60 - 79$):**
  > *"Labour expenditure is trending 14% higher than planned. Monitor weed control frequency."*
- **🔴 At Risk ($< 60$):**
  > *"Critical: Actual expenses exceed total budget by 24% while 45% of sales revenue remains uncollected in market credit."*

---

## 5. Decision Support Recommendations

The engine synthesizes findings into one of four executive recommendations:

1. **Proceed (High Confidence):**
   - Criteria: $\text{Projected ROI} > 30\%$, Health Score $\ge 80$, Break-even volume $\le 60\%$ of expected yield.
2. **Proceed With Caution (Moderate Risk):**
   - Criteria: Health Score $60-79$, Break-even volume between $60\% - 85\%$ of expected yield, or high sensitivity to market price fluctuations.
3. **Review & Adjust (Intervention Needed):**
   - Criteria: Budget overrun in key category $> 20\%$, or uncollected credit $> 30\%$ of total revenue.
4. **Halt / Liquidate / High Risk:**
   - Criteria: Health Score $< 60$, projected revenue unable to cover variable harvesting costs.

---

## 6. End-to-End Concrete Example (2-Acre Pepper Farm)

### Scenario Inputs:
- **Crop:** Pepper
- **Land:** 2 Acres
- **Budget:**
  - Land Preparation: GH₵1,000 (100,000 pesewas)
  - Seeds / Seedlings: GH₵500 (50,000 pesewas)
  - Fertilizers: GH₵1,500 (150,000 pesewas)
  - Agro-chemicals: GH₵1,000 (100,000 pesewas)
  - Labour: GH₵2,000 (200,000 pesewas)
  - Logistics / Fuel: GH₵500 (50,000 pesewas)
  - Miscellaneous: GH₵500 (50,000 pesewas)
  - **Total Budget:** $\text{GH₵}7,000$ ($700,000$ pesewas)
- **Yield Projection:** $3,500\text{ kg}$
- **Price Projection:** $\text{GH₵}10.00 / \text{kg}$ ($1,000\text{ pesewas/kg}$)

### Computed Benchmarks:
- **Projected Revenue:** $3,500 \times 10 = \text{GH₵}35,000$
- **Projected Net Profit:** $35,000 - 7,000 = \text{GH₵}28,000$
- **Projected ROI:** $(28,000 / 7,000) \times 100 = 400\%$
- **Break-Even Output:** $7,000 / 10 = 700\text{ kg}$
- **Break-Even Price:** $7,000 / 3,500 = \text{GH₵}2.00 / \text{kg}$

### Mid-Season Progress Update:
- **Actual Costs Incurred:** $\text{GH₵}8,200$ (Budget Overrun: $+\text{GH₵}1,200$ or $+17.1\%$)
- **Harvest to Date:** $2,400\text{ kg}$
- **Sales Recorded:** $2,000\text{ kg}$ at $\text{GH₵}11.00 = \text{GH₵}22,000$
- **Cash Payments Collected:** $\text{GH₵}18,000$
- **Outstanding Debtors:** $\text{GH₵}4,000$

### Final Intelligent Evaluation Displayed to User:
> *"You invested GH₵8,200 against a planned GH₵7,000 (+17.1% variance). You generated GH₵22,000 in sales, collected GH₵18,000 in cash, and have GH₵4,000 in outstanding credit. Current actual net profit is GH₵13,800 with an actual ROI of 168.3%. Your project has already passed its break-even point (700 kg). Recommendation: Proceed; follow up on GH₵4,000 unpaid market credit."*

