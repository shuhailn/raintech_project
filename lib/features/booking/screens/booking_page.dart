import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/guest_filter_chips.dart';
import '../widgets/room_card.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final BookingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BookingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hotel, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAINTECH LUXURY SUITES',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Hotel Room Booking System',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Reset Selection',
            onPressed: () => _controller.reset(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 850;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Wide desktop / Chrome layout (Two-column layout)
  Widget _buildDesktopLayout() {
    final rooms = _controller.rooms;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Filters & Room list
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GuestFilterChips(controller: _controller),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Rooms (${rooms.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Prices per night (₹)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (rooms.isEmpty)
                    _buildEmptyRoomsState()
                  else
                    ...rooms.map(
                      (room) => RoomCard(
                        room: room,
                        isSelected: _controller.selectedRoom?.roomCode == room.roomCode,
                        isAvailable: _controller.isRoomAvailable(room),
                        onSelect: () => _controller.selectRoom(room),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right column: Date Selector & Booking Summary
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DateSelectorBar(controller: _controller),
                  const SizedBox(height: 16),
                  BookingSummaryCard(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Narrow mobile / Android layout (Single-column layout)
  Widget _buildMobileLayout() {
    final rooms = _controller.rooms;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateSelectorBar(controller: _controller),
          const SizedBox(height: 16),
          GuestFilterChips(controller: _controller),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Rooms (${rooms.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'All rates in ₹ INR',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rooms.isEmpty)
            _buildEmptyRoomsState()
          else
            ...rooms.map(
              (room) => RoomCard(
                room: room,
                isSelected: _controller.selectedRoom?.roomCode == room.roomCode,
                isAvailable: _controller.isRoomAvailable(room),
                onSelect: () => _controller.selectRoom(room),
              ),
            ),
          const SizedBox(height: 12),
          BookingSummaryCard(controller: _controller),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyRoomsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.hotel_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'No rooms match your filter',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try resetting or selecting a lower guest capacity.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _controller.setGuestFilter(null),
            child: const Text('Show All Rooms'),
          ),
        ],
      ),
    );
  }
}
