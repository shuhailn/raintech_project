class DateFormatter {
  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _weekdaysShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  /// Formats date as '16 Sep 2026'
  static String formatShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthsShort[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// Formats date as 'Wed, 16 Sep 2026'
  static String formatWithWeekday(DateTime date) {
    final weekday = _weekdaysShort[date.weekday - 1];
    return '$weekday, ${formatShort(date)}';
  }

  /// Currency formatter in Indian Rupees (e.g. ₹3,500)
  static String formatCurrency(int amount) {
    final stringAmount = amount.toString();
    if (stringAmount.length <= 3) {
      return '₹$stringAmount';
    }

    // Indian numbering format: 3 digits from right, then groups of 2
    final lastThree = stringAmount.substring(stringAmount.length - 3);
    final remaining = stringAmount.substring(0, stringAmount.length - 3);

    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return '₹${buffer.toString()}';
  }
}
