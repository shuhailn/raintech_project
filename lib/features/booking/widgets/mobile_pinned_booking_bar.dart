import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/booking_controller.dart';
import 'booking_summary_card.dart';

class MobilePinnedBookingBar extends StatelessWidget {
  final BookingController controller;

  const MobilePinnedBookingBar({
    super.key,
    required this.controller,
  });

  void _openDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => BookingSummaryCard(controller: controller),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = controller.calculation;
    final hasDates = controller.checkIn != null && controller.checkOut != null;
    final hasRoom = controller.selectedRoom != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left Section: Price / Status & Expand Details Button (^)
              Expanded(
                child: InkWell(
                  onTap: () => _openDetailsBottomSheet(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (calc.isValid) ...[
                                Row(
                                  children: [
                                    Text(
                                      DateFormatter.formatCurrency(calc.totalPrice),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${calc.nights}n)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${controller.selectedRoom!.roomCode} · ${controller.selectedRoom!.roomType}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ] else if (hasDates && !hasRoom) ...[
                                Text(
                                  '${calc.nights} night${calc.nights > 1 ? "s" : ""} stay',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Select a room from list',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'Pick your stay dates',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Select check-in & check-out',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Chevron Up (^) button to open details
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right Section: Action Button
              ElevatedButton(
                onPressed: controller.isBookingInProgress
                    ? null
                    : () {
                        if (calc.isValid) {
                          controller.confirmBooking(context);
                        } else {
                          _openDetailsBottomSheet(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: calc.isValid ? AppColors.primary : AppColors.surfaceMuted,
                  foregroundColor: calc.isValid ? Colors.white : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: calc.isValid ? 2 : 0,
                ),
                child: controller.isBookingInProgress
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        calc.isValid ? 'Book Now' : 'View Details',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
