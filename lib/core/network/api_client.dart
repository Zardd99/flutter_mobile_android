import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_mobile_app/core/constants/api_constants.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({required this.baseUrl, Map<String, String>? headers})
    : defaultHeaders = {
        ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
        ...?headers,
      };

  Future<Result<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(authToken);

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final headers = _buildHeaders(authToken);

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = _buildHeaders(authToken);

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> delete(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = _buildHeaders(authToken);

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Future<Result<List<dynamic>>> getList(
    String endpoint, {
    Map<String, String>? queryParams,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(authToken);

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleListResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = _buildHeaders(authToken);

      final response = await http
          .patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Map<String, String> _buildHeaders(String? authToken) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (authToken != null) {
      headers[ApiConstants.headerAuthorization] = 'Bearer $authToken';
    }
    return headers;
  }

  Result<Map<String, dynamic>> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('text/html') ||
        response.body.trim().startsWith('<!DOCTYPE')) {
      if (kDebugMode) {
        debugPrint('ERROR: Server returned HTML instead of JSON');
      }
      return ResultFailure(
        ServerFailure(
          'Server returned HTML instead of JSON. Status: $statusCode',
        ),
      );
    }

    try {
      final body = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        if (body is Map<String, dynamic>) {
          return Success(body);
        }
        return Success({'data': body});
      }

      return ResultFailure(_createFailure(statusCode, body));
    } catch (e) {
      return ResultFailure(GenericFailure('Failed to parse response: $e'));
    }
  }

  Result<List<dynamic>> _handleListResponse(http.Response response) {
    final statusCode = response.statusCode;

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('text/html') ||
        response.body.trim().startsWith('<!DOCTYPE')) {
      if (kDebugMode) {
        debugPrint('ERROR: Server returned HTML instead of JSON');
      }
      return ResultFailure(
        ServerFailure(
          'Server returned HTML instead of JSON. Status: $statusCode',
        ),
      );
    }

    try {
      final body = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        if (body is List) {
          return Success(body);
        }
        if (body is Map<String, dynamic> && body.containsKey('data')) {
          final data = body['data'];
          if (data is List) {
            return Success(data);
          }
        }
        return Success([]);
      }

      return ResultFailure(_createFailure(statusCode, body));
    } catch (e) {
      return ResultFailure(GenericFailure('Failed to parse response: $e'));
    }
  }

  Failure _createFailure(int statusCode, dynamic body) {
    String message;

    if (body is Map<String, dynamic>) {
      message =
          body['message']?.toString() ??
          body['error']?.toString() ??
          'Server error: $statusCode';
    } else if (body is String) {
      message = body;
    } else {
      message = 'Server error: $statusCode';
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return AuthenticationFailure(message);
      case 403:
        return PermissionFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 500:
      case 502:
      case 503:
        return ServerFailure(message);
      default:
        return GenericFailure(message);
    }
  }
}
