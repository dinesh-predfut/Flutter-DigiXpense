import 'dart:convert';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constant/Parames/params.dart';
import '../../../core/constant/url.dart';

class ApiService {
  // =============================================
  // SINGLE FLIGHT REFRESH PROTECTION
  // =============================================
  static Future<bool>? _refreshFuture;
  static final String digiSessionId = const Uuid().v4();
  // =============================================
  // DEFAULT HEADERS
  // =============================================
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      "DigiSessionID": digiSessionId.toString(),
    };
  }

  // =============================================
  // REFRESH TOKEN SINGLE EXECUTION
  // =============================================
  static Future<bool> _refreshTokenSingle() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    _refreshFuture = _refreshToken();
    final result = await _refreshFuture!;
    _refreshFuture = null;

    return result;
  }

  // =============================================
  // REFRESH TOKEN API
  // =============================================
  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse('${Urls.baseURL}/api/v1/tenant/auth/refresh_token');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
          
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);

        Params.userToken = data['access_token'];

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // =============================================
  // CORE REQUEST HANDLER
  // =============================================
  static Future<http.Response> _sendRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn, {
    bool retry = true,
    BuildContext? context,
  }) async {
    // Wait if refresh already running
    if (_refreshFuture != null) {
      await _refreshFuture;
    }

    Map<String, String> headers = await _getHeaders();

    http.Response response = await requestFn(headers);

    // TOKEN EXPIRED
    if ((response.statusCode == 401 || response.statusCode == 481) && retry) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry with new token
        headers = await _getHeaders();
      
        return await requestFn(headers);
      } else {
          if (context != null) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.signin, (route) => false);
        }
        await _logoutUser();

        throw Exception('Session expired. Login again.');
      }
    }

    return response;
  }

  // =============================================
  // LOGOUT METHOD
  // =============================================
  static Future<void> _logoutUser() async {
    Fluttertoast.showToast(msg: 'Session expired. Please login again.');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

  
  }

  // =============================================
  // GET
  // =============================================
  static Future<http.Response> get(Uri url, [BuildContext? context]) {
    return _sendRequest(
      (headers) => http.get(url, headers: headers),
      context: context,
    );
  }

  // =============================================
  // POST
  // =============================================
  static Future<http.Response> post(Uri url, {dynamic body}) {
    return _sendRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // =============================================
  // PUT
  // =============================================
  static Future<http.Response> put(Uri url, {dynamic body}) {
    return _sendRequest(
      (headers) => http.put(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // =============================================
  // PATCH
  // =============================================
  static Future<http.Response> patch(Uri url, {dynamic body}) {
    return _sendRequest(
      (headers) => http.patch(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // =============================================
  // DELETE
  // =============================================
  static Future<http.Response> delete(Uri url, {dynamic body}) {
    return _sendRequest((headers) async {
      final request = http.Request('DELETE', url);

      request.headers.addAll(headers);

      if (body != null) {
        request.body = body is String ? body : jsonEncode(body);
      }

      final streamed = await request.send();

      return http.Response.fromStream(streamed);
    });
  }
}
