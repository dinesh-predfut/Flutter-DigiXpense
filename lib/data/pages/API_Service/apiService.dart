import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constant/Parames/params.dart';
import '../../../core/constant/url.dart';

class ApiService {
  // ----------------------------------------------
  // DEFAULT HEADERS
  // ----------------------------------------------
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ----------------------------------------------
  // SINGLE-FLIGHT REFRESH LOGIC
  // Ensures only ONE refresh happens at a time
  // ----------------------------------------------
  static Future<bool>? _refreshTokenFuture;

 static Future<bool> _refreshTokenSingle() async {
  // If a refresh is already in progress → await the same Future
  if (_refreshTokenFuture != null) {
    final result = await _refreshTokenFuture!;
    return result == true; // ensure non-null bool
  }

  // Start a new refresh
  _refreshTokenFuture = _refreshToken();

  final result = await _refreshTokenFuture!;

  // Reset after completion
  _refreshTokenFuture = null;

  return result == true; // ensure non-null bool
}


  // Actual refresh request (only executed ONCE)
  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    try {
      final uri = Uri.parse('${Urls.baseURL}/api/v1/tenant/auth/refresh_token');

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken"
        },
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

  // ----------------------------------------------
  // UNIFIED HANDLER FOR ALL REQUEST TYPES
  // ----------------------------------------------
  static Future<http.Response> _sendRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn, {
    bool retry = true,
  }) async {
    final reqHeaders = await getHeaders();
    http.Response response = await requestFn(reqHeaders);

    if (response.statusCode == 481 && retry) {
      // wait for refresh (single-flight)
      final refreshed = await _refreshTokenSingle();

      if (refreshed) {
        final newHeaders = await getHeaders();
        return await _sendRequest(requestFn, retry: false);
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
        throw Exception("Token refresh failed");
      }
    }

    return response;
  }

  // ----------------------------------------------
  // GET REQUEST
  // ----------------------------------------------
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest((reqHeaders) {
      return http.get(url, headers: headers ?? reqHeaders);
    });
  }

  // ----------------------------------------------
  // POST REQUEST
  // ----------------------------------------------
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _sendRequest((reqHeaders) {
      return http.post(url,
          headers: headers ?? reqHeaders, body: body);
    });
  }

  // ----------------------------------------------
  // PUT REQUEST
  // ----------------------------------------------
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _sendRequest((reqHeaders) {
      return http.put(url,
          headers: headers ?? reqHeaders, body: body);
    });
  }

  // ----------------------------------------------
  // PATCH REQUEST
  // ----------------------------------------------
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _sendRequest((reqHeaders) {
      return http.patch(url,
          headers: headers ?? reqHeaders, body: body);
    });
  }

  // ----------------------------------------------
  // DELETE REQUEST
  // ----------------------------------------------
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _sendRequest((reqHeaders) async {
      final request = http.Request("DELETE", url);
      request.headers.addAll(headers ?? reqHeaders);
      if (body != null) request.body = body;

      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    });
  }
}
