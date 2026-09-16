import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/booking/screens/booking_page.dart';
import 'package:hotel_booking_app/main.dart';

void main() {
  testWidgets('HotelBookingApp smoke test renders booking page and rooms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HotelBookingApp());
    await tester.pumpAndSettle();

    // Verify title and page header
    expect(find.byType(BookingPage), findsOneWidget);
    expect(find.text('RAINTECH LUXURY SUITES'), findsOneWidget);

    // Verify rooms are loaded
    expect(find.text('Deluxe Room'), findsWidgets);
    expect(find.text('Executive Suite'), findsWidgets);
    expect(find.text('Family Room'), findsOneWidget);

    // Verify summary card is present
    expect(find.text('Booking Summary'), findsOneWidget);
  });
}
