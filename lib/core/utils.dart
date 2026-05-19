    import 'package:diginexa/data/service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;

int toMillisecondsWithTimezone(DateTime localDt) {
        final controller = Get.find<Controller>();

      final int offsetMs = int.tryParse(controller.selectedTimezonevalue!) ?? 0;

      /// Create pure UTC midnight for the selected date
      final DateTime utcMidnight = DateTime.utc(
        localDt.year,
        localDt.month,
        localDt.day,
        0,
        0,
        0,
      );

      print("localDt: $localDt");
      print("utcMidnight: $utcMidnight");
      print("utcMs: ${utcMidnight.millisecondsSinceEpoch}");

      return utcMidnight.millisecondsSinceEpoch - offsetMs; // ✅ 1778011200000
    }