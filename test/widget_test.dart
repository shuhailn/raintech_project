import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/booking/screens/booking_page.dart';
import 'package:hotel_booking_app/features/booking/widgets/mobile_pinned_booking_bar.dart';
import 'package:hotel_booking_app/features/booking/widgets/room_card.dart';
import 'package:hotel_booking_app/main.dart';

void main() {
  testWidgets('HotelBookingApp mobile layout greyed-out Book button and bottom sheet rise', (
    WidgetTester tester,
  ) async {
    // Set screen size to mobile
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const HotelBookingApp());
    await tester.pumpAndSettle();

    // Verify title and page header
    expect(find.byType(BookingPage), findsOneWidget);
    expect(find.text('RAINTECH LUXURY SUITES'), findsOneWidget);

    // Verify rooms are loaded
    expect(find.text('Deluxe Room'), findsWidgets);
    expect(find.text('Executive Suite'), findsWidgets);
    expect(find.text('Family Room'), findsOneWidget);

    // Verify pinned mobile booking bar is present
    expect(find.byType(MobilePinnedBookingBar), findsOneWidget);

    // 1. Initial state: Book button is greyed-out / disabled
    final bookBtnFinder = find.widgetWithText(ElevatedButton, 'Book');
    expect(bookBtnFinder, findsOneWidget);
    final initialButton = tester.widget<ElevatedButton>(bookBtnFinder);
    expect(initialButton.onPressed, isNull);

    // 2. Chevron (^) can open the details bottom sheet
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pumpAndSettle();

    // Verify booking summary details sheet appears
    expect(find.text('Booking Summary'), findsOneWidget);

    // Close the bottom sheet
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle();

    // 3. Select Check-in date
    await tester.tap(find.text('CHECK-IN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SELECT'));
    await tester.pumpAndSettle();

    // 4. Select Check-out date
    await tester.tap(find.text('CHECK-OUT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SELECT'));
    await tester.pumpAndSettle();

    // 5. Select the first Room
    await tester.tap(find.byType(RoomCard).first);
    await tester.pumpAndSettle();

    // 6. Button is now active and colored
    final activeButton = tester.widget<ElevatedButton>(bookBtnFinder);
    expect(activeButton.onPressed, isNotNull);

    // 7. Tapping active Book button gives the bottom sheet rise
    await tester.tap(bookBtnFinder);
    await tester.pumpAndSettle();

    // Verify details bottom sheet opened
    expect(find.text('Booking Summary'), findsOneWidget);
  });

  testWidgets('HotelBookingApp desktop layout renders sidebar summary', (
    WidgetTester tester,
  ) async {
    // Set screen size to wide desktop
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const HotelBookingApp());
    await tester.pumpAndSettle();

    // Verify summary card is displayed directly in the desktop sidebar
    expect(find.text('Booking Summary'), findsOneWidget);
    // Pinned mobile bar should not be present on desktop
    expect(find.byType(MobilePinnedBookingBar), findsNothing);
  });
}
