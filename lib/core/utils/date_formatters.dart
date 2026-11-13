class DateFormatters {
  DateFormatters._();

  static const monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static String ymd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String displayDay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String displayMonth(DateTime date) {
    return '${monthNames[date.month - 1]} de ${date.year}';
  }

  static String displayRange(DateTime start, DateTime end) {
    if (ymd(start) == ymd(end)) {
      return displayDay(start);
    }
    return '${displayDay(start)} — ${displayDay(end)}';
  }

  static String normalizeTime(String time) {
    final cleaned = time.length > 8 ? time.substring(0, 8) : time;
    if (cleaned.length == 5) return '$cleaned:00';
    return cleaned;
  }

  static String displayTime(String time) {
    final normalized = normalizeTime(time);
    return normalized.length >= 5 ? normalized.substring(0, 5) : normalized;
  }

  static DateTime? parseAppointment(String dateStr, String timeStr) {
    try {
      final time = displayTime(timeStr);
      return DateTime.parse('$dateStr $time:00');
    } catch (_) {
      return null;
    }
  }

  static bool isInThePast(String dateStr, String timeStr, {DateTime? now}) {
    final parsed = parseAppointment(dateStr, timeStr);
    if (parsed == null) return false;
    return parsed.isBefore(now ?? DateTime.now());
  }

  static int notificationId(String appointmentId) {
    return appointmentId.hashCode & 0x7fffffff;
  }

  static int slotBlocks(int durationMinutes) {
    if (durationMinutes <= 0) return 2;
    final blocks = (durationMinutes / 15).ceil();
    return blocks < 1 ? 1 : blocks;
  }
}
