import 'dart:convert';

import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constant/Parames/params.dart';
import '../../../core/constant/url.dart';

class ApiService {
  final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  // ----------------------------------------------
  // DEFAULT HEADERS
  // ----------------------------------------------
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ----------------------------------------------
  // SINGLE-FLIGHT REFRESH
  // ----------------------------------------------
  static Future<bool>? _refreshFuture;

  static Future<bool> _refreshTokenSingle() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    _refreshFuture = _refreshToken();
    final result = await _refreshFuture!;
    _refreshFuture = null;

    return result;
  }

  // ----------------------------------------------
  // REFRESH TOKEN API
  // ----------------------------------------------
  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse(
        '${Urls.baseURL}/api/v1/tenant/auth/refresh_token',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);

        Params.userToken = data['access_token'];
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------------------
  // CORE REQUEST HANDLER
  // ----------------------------------------------
static Future<http.Response> _sendRequest(
  Future<http.Response> Function(Map<String, String> headers) requestFn, {
  bool retry = true,
}) async {
  // 🔹 Always wait if refresh is in progress
  if (_refreshFuture != null) {
    await _refreshFuture;
  }

  Map<String, String> headers = await _getHeaders();
  http.Response response = await requestFn(headers);

  if ((response.statusCode == 401 || response.statusCode == 481) && retry) {
    final refreshed = await _refreshTokenSingle();

    if (refreshed) {
      // 🟢 IMPORTANT: wait again so ALL APIs sync
      if (_refreshFuture != null) {
        await _refreshFuture;
      }

      // 🔁 Retry API with NEW token
      headers = await _getHeaders();
      return await requestFn(headers);
    } else {
      Fluttertoast.showToast(
        msg: 'Session expired. Please login again.',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Get.reset();
      Get.offAllNamed(AppRoutes.login);

      throw Exception('Token refresh failed');
    }
  }

  return response;
}


  // ----------------------------------------------
  // GET
  // ----------------------------------------------
  static Future<http.Response> get(Uri url) {
    return _sendRequest(
      (headers) => http.get(url, headers: headers),
    );
  }

  // ----------------------------------------------
  // POST
  // ----------------------------------------------
  static Future<http.Response> post(
    Uri url, {
    dynamic body,
  }) {
    return _sendRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // ----------------------------------------------
  // PUT
  // ----------------------------------------------
  static Future<http.Response> put(
    Uri url, {
    dynamic body,
  }) {
    return _sendRequest(
      (headers) => http.put(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // ----------------------------------------------
  // PATCH
  // ----------------------------------------------
  static Future<http.Response> patch(
    Uri url, {
    dynamic body,
  }) {
    return _sendRequest(
      (headers) => http.patch(
        url,
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      ),
    );
  }

  // ----------------------------------------------
  // DELETE
  // ----------------------------------------------
  static Future<http.Response> delete(
    Uri url, {
    dynamic body,
  }) {
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
