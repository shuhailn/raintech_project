import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/booking_controller.dart';
import '../models/booking_calculation.dart';

class BookingSummaryCard extends StatelessWidget {
  final BookingController controller;

  const BookingSummaryCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final calc = controller.calculation;
    final room = controller.selectedRoom;
    final checkIn = controller.checkIn;
    final checkOut = controller.checkOut;

    final hasDates = checkIn != null && checkOut != null;
    final hasRoom = room != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: calc.isValid ? AppColors.primaryLight : AppColors.border,
          width: calc.isValid ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Room preview
          _SummaryRow(
            label: 'Selected Room',
            value: hasRoom ? '${room.roomType} (${room.roomCode})' : 'None selected',
            isPlaceholder: !hasRoom,
          ),
          const SizedBox(height: 8),

          // Dates preview
          _SummaryRow(
            label: 'Dates',
            value: hasDates
                ? '${DateFormatter.formatShort(checkIn)} → ${DateFormatter.formatShort(checkOut)}'
                : 'Dates incomplete',
            isPlaceholder: !hasDates,
          ),
          const SizedBox(height: 8),

          // Number of nights
          _SummaryRow(
            label: 'Number of Nights',
            value: calc.nights > 0
                ? '${calc.nights} night${calc.nights > 1 ? "s" : ""}'
                : '—',
            isPlaceholder: calc.nights <= 0,
          ),
          const SizedBox(height: 8),

          // Price per night
          _SummaryRow(
            label: 'Rate per Night',
            value: hasRoom
                ? '${DateFormatter.formatCurrency(room.pricePerNight)} / night'
                : '—',
            isPlaceholder: !hasRoom,
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),

          // Total Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                calc.isValid ? DateFormatter.formatCurrency(calc.totalPrice) : '₹0',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: calc.isValid ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Calculation breakdown formula if valid
          if (calc.isValid && hasRoom) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '(${DateFormatter.formatCurrency(room.pricePerNight)} × ${calc.nights} nights)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Validation alert message (instead of failing silently)
          if (!calc.isValid) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: calc.status == BookingValidationStatus.incomplete
                    ? AppColors.infoBg
                    : AppColors.errorBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: calc.status == BookingValidationStatus.incomplete
                      ? AppColors.info.withOpacity(0.4)
                      : AppColors.error.withOpacity(0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    calc.status == BookingValidationStatus.incomplete
                        ? Icons.info_outline
                        : Icons.error_outline,
                    size: 16,
                    color: calc.status == BookingValidationStatus.incomplete
                        ? AppColors.info
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      calc.errorMessage ??
                          'Please select valid dates and a room to complete booking.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: calc.status == BookingValidationStatus.incomplete
                            ? AppColors.textPrimary
                            : AppColors.error,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Booking Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isBookingInProgress
                  ? null
                  : () => controller.confirmBooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: calc.isValid ? AppColors.primary : AppColors.surfaceMuted,
                foregroundColor: calc.isValid ? Colors.white : AppColors.textMuted,
                elevation: calc.isValid ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: controller.isBookingInProgress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      calc.isValid ? 'Confirm & Book Room' : 'Complete Selection to Book',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w600,
              color: isPlaceholder ? AppColors.textMuted : AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
