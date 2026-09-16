# Hotel Room Booking System — Developer Skills Assessment

A responsive, single-page Hotel Room Booking application built with **Flutter 3.35.0 (Dart 3.9.0)**, designed for **Chrome (Web)**, **Android**, and **Windows**.

Developed for the **Raintech Software Limited** Developer Skills Assessment.

---

##  Live Demo & How to Run

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.35.0 or compatible) or [FVM (Flutter Version Management)](https://fvm.app/)

### 1. Run on Chrome (Web)
```bash
fvm flutter run -d chrome
```
*Or without FVM:*
```bash
flutter run -d chrome
```

### 2. Run on Android
```bash
fvm flutter run -d android
```

### 3. Run on Windows Desktop
```bash
fvm flutter run -d windows
```

### 4. Run Automated Test Suite
```bash
fvm flutter test
```
All **11 unit and widget tests** run and pass in under 5 seconds.

---

## 🛠️ Stack & Technology Choices
- **Framework**: Flutter (Channel Stable 3.35.0, Dart 3.9.0)
- **UI Architecture**: Material 3 Design Tokens, Custom Semantic Color Palette (`AppColors`), Responsive `LayoutBuilder`
- **State Management**: `ChangeNotifier` + `ListenableBuilder` (Lightweight, decoupled, zero external package bloat)
- **Code Standards**: Strict `camelCase` naming conventions, `debugPrint` logging, clean separation of domain logic from UI presentation.

---

##  Features Implemented

### Core Requirements
- **Hotel Room Directory**: Displays all sample rooms directly from hardcoded specifications:
  - `R101` — Deluxe Room (₹3,500/night, Max 2 Guests)
  - `R102` — Deluxe Room (₹3,500/night, Max 2 Guests)
  - `R201` — Executive Suite (₹5,800/night, Max 3 Guests)
  - `R202` — Executive Suite (₹5,800/night, Max 3 Guests)
  - `R301` — Family Room (₹4,200/night, Max 4 Guests)
- **Date Pickers**: Intuitive Check-in and Check-out calendar date selectors.
- **Room Selection**: Interactive room selection cards with pricing and details.
- **Dynamic Price Breakdown**:
  - Automatically calculates number of nights between Check-in and Check-out.
  - Formula: $\text{Total Price} = \text{Nights} \times \text{Price per Night}$.
  - Formatted in Indian Rupee format (e.g. `₹10,500`).
- **Validation & Error Handling (No Silent Failures)**:
  - **Check-in in the past**: Prevented with clear alert banner: *"Check-in date cannot be in the past"*.
  - **Same-day bookings**: Prevented with alert: *"Check-out date must be at least 1 day after check-in"*.
  - **Reverse date selection**: Prevented with alert: *"Check-out date must be after check-in date"*.
  - **Missing room or dates**: Clear guidance banner informing user what step is missing.

###  Bonus Features Included
1. **Double-Booking Collision Prevention**:
   - Rooms can have existing bookings (e.g., `R102` and `R201` have mock reserved dates).
   - If a user selects dates that overlap with an existing reservation, the room is clearly flagged as **"Booked for selected dates"**, dimmed, and blocked from selection.
2. **Room Filtering by Guest Capacity**:
   - Filter chips allow instant filtering by guest capacity (*All Rooms*, *2 Guests*, *3 Guests*, *4 Guests*).
3. **DialogSnackbarHelper**:
   - Centralized helper for clean confirmation dialogs, success dialogs, and error snackbars.
4. **Comprehensive Automated Tests**:
   - 10 pure domain unit tests verifying all calculation formulas and validation edge cases.
   - 1 widget smoke test verifying end-to-end rendering on screen.

---

## 📐 Architecture & Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart            # Semantic brand & status color system
│   └── utils/
│       ├── date_formatter.dart        # Clean date & INR currency formatting
│       └── dialog_snackbar_helper.dart# Reusable Dialog & SnackBar UI helper
├── features/
│   └── booking/
│       ├── controllers/
│       │   └── booking_controller.dart# ChangeNotifier managing state & actions
│       ├── data/
│       │   └── mock_hotel_data.dart   # Hardcoded room data & initial bookings
│       ├── models/
│       │   ├── booking_calculation.dart# Strongly-typed calculation & status enum
│       │   ├── booking_reservation.dart# Reservation model for mock bookings
│       │   └── room.dart              # Immutable Room model
│       ├── screens/
│       │   └── booking_page.dart      # Adaptive responsive single page
│       ├── services/
│       │   └── booking_service.dart   # Pure business logic & collision engine
│       └── widgets/
│           ├── booking_summary_card.dart# Price & validation breakdown card
│           ├── date_selector_bar.dart # Stay dates calendar pickers
│           ├── guest_filter_chips.dart# Capacity filter chips
│           └── room_card.dart         # Room item card with status badges
└── main.dart                          # App entry point & Material 3 theme configuration

test/
├── booking_service_test.dart          # 10 unit tests for math, logic & edge cases
└── widget_test.dart                   # UI smoke test
```

### Key Architectural Decisions:
- **Separation of Logic vs. UI**: The core logic (`BookingService` & `BookingCalculator`) contains zero Flutter UI imports. It operates on pure Dart primitives, making it 100% unit testable and deterministic.
- **Normalized Date Arithmetic**: All date comparisons are normalized to midnight (`DateTime(year, month, day)`) to prevent daylight savings shifts or hour/minute discrepancies from causing off-by-one night calculations.
- **Adaptive Layout**: Responsive design with desktop two-column view (>=850px width) and mobile single-column vertical flow (<850px width).


