import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/core/constant/url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get Bearer token globally
  String get _bearerToken => Params.userToken ?? '';

  // Common headers with Bearer token
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_bearerToken',
  };

  // GET request
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? _headers,
      );
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers ?? _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers ?? _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers ?? _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  // Handle response and parse JSON
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API request failed with status: ${response.statusCode}, body: ${response.body}');
    }
  }
} 