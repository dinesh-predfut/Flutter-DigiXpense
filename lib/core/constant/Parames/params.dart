import 'package:shared_preferences/shared_preferences.dart';

class   Params {
  static String userToken = "null";
  static String userId = "Null";
  static String refreshtoken = "null";
  static String employeeId = "null";
  static String tokenExpiry = "null";
  static String userName = "null";
  static var employeeName;
}

class SetSharedPref {
  Future<void> setData({
    required String token,
    required String userId,
    required String employeeId,
    required String refreshtoken,
    required String userName,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("access_token", token);
    await pref.setString("EmployeeId", employeeId);
    await pref.setString("userId", userId);
    await pref.setString("refresh_token", refreshtoken);
    await pref.setString("UserName", userName);

    Params.refreshtoken = refreshtoken;
    Params.userToken = token;
    Params.employeeId = employeeId;
    Params.userId = userId;
        Params.userName = userName;
    print("Saving userId: ${Params.refreshtoken}");
  }

  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    Params.userToken = pref.getString("access_token") ?? "null";
    Params.refreshtoken = pref.getString("refresh_token") ?? "null";
    Params.employeeId = pref.getString("EmployeeId") ?? "null";
    Params.userId = pref.getString("userId") ?? "null";
      Params.userName = pref.getString("userName") ?? "null";

    print("Retrieved userId: ${Params.refreshtoken}");
  } 

  Future<void> clearData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    Params.userToken = "null";
    Params.refreshtoken = "null";
    Params.employeeId = "null";
    Params.userId = "null";
    Params.tokenExpiry = "null";
Params.userName = "null";
    print("Data cleared, userId is now ${Params.userId}"); // Debugging log
  }
 
}
