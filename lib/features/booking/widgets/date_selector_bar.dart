import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/booking_controller.dart';

class DateSelectorBar extends StatelessWidget {
  final BookingController controller;

  const DateSelectorBar({
    super.key,
    required this.controller,
  });

  Future<void> _pickCheckInDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = controller.checkIn != null && !controller.checkIn!.isBefore(today)
        ? controller.checkIn!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'SELECT CHECK-IN DATE',
      confirmText: 'SELECT',
    );

    if (picked != null) {
      controller.setCheckIn(picked);
    }
  }

  Future<void> _pickCheckOutDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Default first possible check-out is the day after check-in or tomorrow
    final minCheckOut = controller.checkIn != null
        ? controller.checkIn!.add(const Duration(days: 1))
        : today.add(const Duration(days: 1));

    final initial = controller.checkOut != null &&
            controller.checkOut!.isAfter(controller.checkIn ?? today)
        ? controller.checkOut!
        : minCheckOut;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minCheckOut,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'SELECT CHECK-OUT DATE',
      confirmText: 'SELECT',
    );

    if (picked != null) {
      controller.setCheckOut(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Stay Dates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (controller.checkIn != null || controller.checkOut != null)
                TextButton(
                  onPressed: () => controller.reset(),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Check-in card
              Expanded(
                child: _DateTile(
                  label: 'CHECK-IN',
                  date: controller.checkIn,
                  icon: Icons.login,
                  onTap: () => _pickCheckInDate(context),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 18),
              ),
              // Check-out card
              Expanded(
                child: _DateTile(
                  label: 'CHECK-OUT',
                  date: controller.checkOut,
                  icon: Icons.logout,
                  onTap: () => _pickCheckOutDate(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isSelected ? DateFormatter.formatShort(date!) : 'Select Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
