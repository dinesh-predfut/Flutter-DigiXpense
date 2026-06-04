import 'package:diginexa/data/service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;

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

DateTime todayInOrgTimezone(String? offsetMsStr) {
  final controller = Get.find<Controller>();

  final int offsetMs =
      int.tryParse(controller.selectedTimezonevalue.value ?? '0') ?? 0;
  final int nowUtcMs = DateTime.now().toUtc().millisecondsSinceEpoch;

  final DateTime orgNow = DateTime.fromMillisecondsSinceEpoch(
    nowUtcMs + offsetMs,
    isUtc: true,
  );

  // Return date-only (no time)
  return DateTime.utc(orgNow.year, orgNow.month, orgNow.day);
}

int toStartOfDayUtc(DateTime localDt) {
  final int offsetMs =
      int.tryParse(Get.find<Controller>().selectedTimezonevalue.value) ?? 0;

  // ✅ Step 1: get correct date in ORG timezone — not device timezone
  final int nowUtcMs = localDt.toUtc().millisecondsSinceEpoch;
  final DateTime orgNow = DateTime.fromMillisecondsSinceEpoch(
    nowUtcMs + offsetMs,
    isUtc: true,
  );

  // ✅ Step 2: build midnight using ORG date (not localDt)
  final DateTime startOfDay = DateTime.utc(
    orgNow.year,
    orgNow.month,
    orgNow.day,
    0,
    0,
    0,
    0,
  );

  final int result = startOfDay.millisecondsSinceEpoch - offsetMs;

  print("toStartOfDayUtc - nowUtcMs  : $nowUtcMs");
  print("toStartOfDayUtc - offsetMs  : $offsetMs");
  print("toStartOfDayUtc - orgNow    : $orgNow"); // ✅ should show NZT date
  print("toStartOfDayUtc - startOfDay: $startOfDay");
  print("toStartOfDayUtc - result    : $result");

  return result;
}

int toEndOfDayUtc(DateTime localDt) {
  final int offsetMs =
      int.tryParse(Get.find<Controller>().selectedTimezonevalue.value ?? '0') ??
      0;

  // ✅ Same fix — use org timezone date
  final int nowUtcMs = DateTime.now().millisecondsSinceEpoch;
  final DateTime orgNow = DateTime.fromMillisecondsSinceEpoch(
    nowUtcMs + offsetMs,
    // isUtc: true,
  );

  final DateTime endOfDay = DateTime.utc(
    localDt.year,
    localDt.month,
    localDt.day,
    23,
    59,
    59,
    999,
  );

  final int result = endOfDay.millisecondsSinceEpoch - offsetMs;

  print("toEndOfDayUtc - orgNow    : $orgNow");
  print("toEndOfDayUtc - endOfDay  : $endOfDay");
  print("toEndOfDayUtc - result    : $result");

  return result;
}

DateTime fromOrgMilliseconds(int ms) {
  final offsetMs = getTimezoneOffsetMs();

  return DateTime.fromMillisecondsSinceEpoch(ms + offsetMs, isUtc: true);
}
