import 'dart:convert' show jsonDecode;

import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class PermissionHelper {

  static Map<String, dynamic>? permissions;

  static Future loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("UserPermissions");

    if (data != null) {
      permissions = jsonDecode(data);
    }
  }

  static bool canRead(String module) {
    return permissions?["Read"]?.contains(module) ?? false;
  }

  static bool canWrite(String module) {
    return permissions?["Write"]?.contains(module) ?? false;
  }

  static bool canUpdate(String module) {
    return permissions?["Update"]?.contains(module) ?? false;
  }

  static bool canDelete(String module) {
    return permissions?["Delete"]?.contains(module) ?? false;
  }
}