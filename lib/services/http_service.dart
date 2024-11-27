import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:help_chat/consts/consts.dart';
import 'package:help_chat/services/api_response.dart';

class HTTPService {
  static final HTTPService _instance = HTTPService._internal();
  final Dio _dio;

  factory HTTPService() {
    return _instance;
  }

  HTTPService._internal() : _dio = Dio() {
    setup();
  }

  void setup({String? bearerToken}) {
    final headers = {
      "Content-Type": "application/json",
    };

    if (bearerToken != null) {
      headers["Authorization"] = "Bearer $bearerToken";
    }

    _dio.options = BaseOptions(
      baseUrl: API_BASE_URL,
      headers: headers,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );
  }

  Future<ApiResponse?> post(String path, Map<String, dynamic> queryParameters) async {
    try {
      final response = await _dio.post(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      log('Error: $e');
      return _handleError(e);
    }
  }

  Future<ApiResponse?> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      log('Error: $e');
      return _handleError(e);
    }
  }

  Future<ApiResponse?> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } catch (e) {
      log('Error: $e');
      return _handleError(e);
    }
  }

  ApiResponse _handleResponse(Response response) {
    // if (response.statusCode == 200) {
      // log('_handleResponse: ${response.data}');
      return ApiResponse.fromJson(response.data);
    // } else {
    //   log('Error: ${response.statusCode} - ${response.statusMessage}');
    //   return ApiResponse(
    //     success: false,
    //     status: response.statusCode ?? 500,
    //     content: null,
    //     timestamp: DateTime.now().toIso8601String(),
    //   );
    // }
  }

  ApiResponse _handleError(dynamic error) {
    if (error is DioException) {
      // Handle DioError specifically
      return ApiResponse(
        success: false,
        status: error.response?.statusCode ?? 500,
        content: null,
        timestamp: DateTime.now().toIso8601String(),
      );
    } else {
      // Handle other types of errors
      return ApiResponse(
        success: false,
        status: 500,
        content: null,
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }
}