# Farm Project Manager (Farmivo)
# UI/UX & Field Usability Specification

**Design System:** Material Design 3 (Optimized for Outdoor Agricultural Field Use)  
**Primary Constraints:** High ambient sunlight glare, intermittent dirt/sweat on touchscreens, variable literacy, rapid data entry.

---

## 1. Ergonomic & Outdoor Design Principles

### 1.1 Direct Sunlight Readability
- **High-Contrast Palette:** Strict adherence to WCAG AAA contrast ratio ($\ge 7:1$) for primary informational elements.
- **Deep Pure Blacks & Crisp Whites:** Avoid subtle pastel grays (e.g., `#E0E0E0` text on `#FFFFFF` is strictly forbidden). Primary surfaces use pure `#0D1117` in dark mode and `#FFFFFF` in light mode with `#1A1D20` high-contrast typography.
- **OLED Sun-Glare Mode:** High-contrast toggle providing maximum luminance borders, heavy bold weights, and solid card dividers.

### 1.2 Physical Field Ergonomics
- **Touch Targets:** All clickable interactive elements (buttons, chip selectors, date pickers, list tiles) must have an active tap target dimension of at least **$48 \times 48\text{ dp}$**.
- **Thumb Zone Optimization:** Primary actions, quick FABs, and numerical keyboards reside in the lower $60\%$ of the screen.

### 1.3 Color Independence & Accessibility
- **Never rely on color alone:** Red/Yellow/Green health badges must always include explicit text and an accompanying recognizable icon:
  - 🟢 **Healthy** (`CheckCircleIcon` + *"Healthy"*)
  - 🟡 **Watch** (`AlertTriangleIcon` + *"Watch"*)
  - 🔴 **At Risk** (`AlertOctagonIcon` + *"At Risk"*)

---

## 2. Color Palette & Typography Tokens

### 2.1 Color Tokens
```dart
class AppColors {
  // Brand & Agriculture Primaries
  static const Color primaryGreen = Color(0xFF1E7E34); // Forest Emerald
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD4EDDA);
  static const Color onPrimaryContainer = Color(0xFF0F3E1A);

  // Surface & Outdoor Neutrals
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFF121417);
  static const Color textHighContrastLight = Color(0xFF1A1A1A);
  static const Color textHighContrastDark = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF4A5568);

  // Financial Status Indicators
  static const Color statusHealthy = Color(0xFF198754); // Green
  static const Color statusWarning = Color(0xFFD97706); // Amber / Orange
  static const Color statusCritical = Color(0xFFDC2626); // Crimson Red
  static const Color statusInformational = Color(0xFF0284C7); // Sky Blue
}
```

---

## 3. Navigation Architecture

### 3.1 Primary App Navigation (Bottom Navigation Bar)
The root of the application features a persistent bottom navigation bar with 5 destinations:

1. **Dashboard (Home):**
   - High-level KPIs: Total Invested, Incurred Expenses, Total Sales, Cash in Hand.
   - Quick Action Floating Action Button (Speed Dial).
   - Urgent Alerts (Budget overruns, debt collection reminders).
2. **Projects:**
   - Active and completed projects list with search, filter chips (Crops, Livestock, Aquaculture), and status badges.
3. **Transactions:**
   - Chronological unified transaction ledger (Expenses, Sales, Cash Payments) with date-range filters and voiding support.
4. **Reports & Analytics:**
   - Financial summaries, performance charts, scenario modeling, PDF export, and CSV download.
5. **Settings:**
   - Security (PIN / Biometrics), Local Backup & Restore, Currency configuration, and Farm Profiles.

### 3.2 Project-Specific Deep Hub (Sub-Navigation)
Within an active project, a top tab bar or segmented control organizes project sub-domains:
```text
[ Overview ]  [ Budget ]  [ Expenses ]  [ Activities ]  [ Harvest ]  [ Sales ]  [ Health ]
```

---

## 4. Rapid Field Entry Flows (<15 Seconds)

### 4.1 Rapid Expense Flow (`+ Expense`)
A farmer logging an expense in the field must be able to complete entry in $\le 4$ taps:

```
[Tap "+ Expense" FAB]
       ↓
1. Enter Amount on Custom Numeric Numpad (Large buttons)
       ↓
2. Tap Category Chip (Pre-selected or 1-tap: "Fertilizer", "Labour", "Fuel")
       ↓
3. Tap Payment Method Chip (Default: "Cash" or "MoMo")
       ↓
[Tap "Save" Floating Confirmation Pill]
```
- **Optional Details (Accordion / Expandable):** Vendor name, budget item assignment, receipt camera snapshot. These never block the primary quick save.

---

## 5. Screen Layouts & Component Patterns

### 5.1 Empty States
Every feature view must provide a friendly empty state illustration with immediate call-to-action:
- **No Projects:**
  > *"You haven't launched a farm project yet."*  
  > `[ Create Your First Project ]`
- **No Expenses:**
  > *"No expenses recorded for this project yet."*  
  > `[ Record Expense ]`
- **No Sales:**
  > *"No harvest sales logged. Your produce is either unharvested or stored in inventory."*  
  > `[ Record Produce Sale ]`

### 5.2 Form Input Validation
- Prevent accidental negative numbers on amounts and quantities.
- Format currency numbers automatically with thousands separators (`GH₵ 1,500.00`).
- Polite, non-technical error prompts:
  - ❌ *"Please enter a valid amount greater than zero."*
  - ❌ *"Payment received cannot exceed the remaining balance of GH₵ 450.00."*

