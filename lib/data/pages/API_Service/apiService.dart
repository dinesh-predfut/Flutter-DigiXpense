import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constant/Parames/params.dart';
import '../../../core/constant/url.dart';

class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool retry = true,
  }) async {
    final reqHeaders = headers ?? await getHeaders();

    final response = await http.get(url, headers: reqHeaders);

    if (response.statusCode == 481 && retry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        reqHeaders['Authorization'] = 'Bearer ${Params.userToken ?? ''}';
        return await get(url, headers: reqHeaders, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }
    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    bool retry = true,
  }) async {
    final reqHeaders = headers ?? await getHeaders();

    final response = await http.post(url, headers: reqHeaders, body: body);

    if (response.statusCode == 481 && retry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        reqHeaders['Authorization'] = 'Bearer ${Params.userToken ?? ''}';
        return await post(url, headers: reqHeaders, body: body, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }
    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    bool retry = true,
  }) async {
    final reqHeaders = headers ?? await getHeaders();

    final response = await http.put(url, headers: reqHeaders, body: body);

    if (response.statusCode == 481 && retry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        reqHeaders['Authorization'] = 'Bearer ${Params.userToken ?? ''}';
        return await put(url, headers: reqHeaders, body: body, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }
    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    bool retry = true,
  }) async {
    final reqHeaders = headers ?? await getHeaders();

    final request = http.Request('DELETE', url);
    request.headers.addAll(reqHeaders);
    if (body != null) request.body = body;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 481 && retry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        reqHeaders['Authorization'] = 'Bearer ${Params.userToken ?? ''}';
        return await delete(url, headers: reqHeaders, body: body, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }
    return response;
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    bool retry = true,
  }) async {
    final reqHeaders = headers ?? await getHeaders();

    final response = await http.patch(url, headers: reqHeaders, body: body);

    if (response.statusCode == 481 && retry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        reqHeaders['Authorization'] = 'Bearer ${Params.userToken ?? ''}';
        return await patch(url, headers: reqHeaders, body: body, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }
    return response;
  }

  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    try {
      final uri = Uri.parse('${Urls.baseURL}/api/v1/tenant/auth/refresh_token');

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json","Authorization": "Bearer $refreshToken"},
        body: jsonEncode({"refresh_token": refreshToken}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        prefs.setString('access_token', newAccessToken);
        prefs.setString('refresh_token', newRefreshToken);

        Params.userToken = newAccessToken;

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
