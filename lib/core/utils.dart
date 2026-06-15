import 'package:diginexa/data/service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:intl/intl.dart';

int getTimezoneOffsetMs() {
  return int.tryParse(
        Get.find<Controller>().selectedTimezonevalue.value ?? '0',
      ) ??
      0;
}

int toMillisecondsWithTimezone(DateTime localDt) {
  final controller = Get.find<Controller>();
  final int offsetMs =
      int.tryParse(controller.selectedTimezonevalue.value ?? '0') ?? 0;

  // Use dynamic time from localDt instead of hardcoded 23:59:59
  final DateTime endOfDay = DateTime.utc(
    localDt.year,
    localDt.month,
    localDt.day,
    23,
    59,
    59,
    999,
  );

  print("toEndOfDayUtc - localDt: $localDt");
  print("toEndOfDayUtc - offsetMs: $offsetMs");
  print("toEndOfDayUtc - endOfDay (UTC): $endOfDay");
  print(
    "toEndOfDayUtc - finalMs: ${endOfDay.millisecondsSinceEpoch - offsetMs}",
  );

  // ✅ MINUS offsetMs (not plus)
  return endOfDay.millisecondsSinceEpoch - offsetMs;
  // 1778011200000
}

DateTime todayInOrgTimezone() {
  final offsetMs = getTimezoneOffsetMs();
  final nowUtc = DateTime.now().toUtc();
  final orgNow = DateTime.fromMillisecondsSinceEpoch(
    nowUtc.millisecondsSinceEpoch + offsetMs,
    isUtc: true,
  );
  return DateTime.utc(orgNow.year, orgNow.month, orgNow.day);
}

int toStartOfDayUtc(DateTime orgLocalDate) {
  final offsetMs = getTimezoneOffsetMs();
  
  final DateTime utcMidnight = DateTime.utc(
    orgLocalDate.year,
    orgLocalDate.month,
    orgLocalDate.day,
    0, 0, 0, 0,
  );
  
  return utcMidnight.millisecondsSinceEpoch - offsetMs;
}

int toEndOfDayUtc(DateTime orgLocalDate) {
  final offsetMs = getTimezoneOffsetMs();
  
  final DateTime utcEndOfDay = DateTime.utc(
    orgLocalDate.year,
    orgLocalDate.month,
    orgLocalDate.day,
    23, 59, 59, 999,
  );
  
  return utcEndOfDay.millisecondsSinceEpoch - offsetMs;
}

DateTime fromOrgMilliseconds(int ms) {
  final offsetMs = getTimezoneOffsetMs();

  return DateTime.fromMillisecondsSinceEpoch(ms + offsetMs, isUtc: true);
}

String formatDate(DateTime date) {
    final controller = Get.find<Controller>();

  // Ensure we're working with UTC
  final DateTime utcDate = date.isUtc ? date : date.toUtc();
  
  // Convert UTC to organization's local time for display
  final offsetMs = getTimezoneOffsetMs();
  final DateTime orgLocalDate = DateTime.fromMillisecondsSinceEpoch(
    utcDate.millisecondsSinceEpoch + offsetMs,
    isUtc: true,
  );
  
  return DateFormat(
    controller.selectedFormat?.key ?? 'dd/MM/yyyy',
  ).format(orgLocalDate);
}
