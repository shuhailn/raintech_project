import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/booking/screens/booking_page.dart';
import 'package:hotel_booking_app/features/booking/widgets/mobile_pinned_booking_bar.dart';
import 'package:hotel_booking_app/main.dart';

void main() {
  testWidgets('HotelBookingApp smoke test renders mobile layout with pinned bar', (
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

    // Tap the chevron (^) to open bottom sheet details
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pumpAndSettle();

    // Verify booking summary details sheet appears
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
