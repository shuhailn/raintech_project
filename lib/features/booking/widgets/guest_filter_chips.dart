import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/booking_controller.dart';

class GuestFilterChips extends StatelessWidget {
  final BookingController controller;

  const GuestFilterChips({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'All Rooms', 'value': null},
      {'label': '2 Guests', 'value': 2},
      {'label': '3 Guests', 'value': 3},
      {'label': '4 Guests', 'value': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text(
              'Filter by Capacity',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((item) {
            final value = item['value'] as int?;
            final label = item['label'] as String;
            final isSelected = controller.guestFilter == value;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => controller.setGuestFilter(value),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}
