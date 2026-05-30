import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_endpoints.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

class DioClient {
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check internet connection
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          // If offline, flag the request to return cached data or error
          options.extra['offline'] = true;
          Fluttertoast.showToast(msg: "You are offline. Showing cached data.");
        }

        // Add Authorization header
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // Cache successful GET requests in Hive
        if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
          try {
            final box = await Hive.openBox('api_cache');
            await box.put(response.requestOptions.uri.toString(), response.data);
          } catch (e) {
            // Ignore cache errors
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.requestOptions.extra['offline'] == true && e.requestOptions.method == 'GET') {
          // Attempt to load from Hive cache
          try {
            final box = await Hive.openBox('api_cache');
            final cachedData = box.get(e.requestOptions.uri.toString());
            if (cachedData != null) {
              return handler.resolve(Response(
                requestOptions: e.requestOptions,
                data: cachedData,
                statusCode: 200,
              ));
            }
          } catch (cacheError) {
            // No cache available
          }
        }

        if (e.response?.statusCode == 401) {
          // Auto refresh JWT logic would go here
          await _storage.delete(key: 'jwt_token');
          Fluttertoast.showToast(msg: "Session expired. Please log in again.");
        } else {
          // Extract backend error message if available
          String errorMsg = "Something went wrong";
          if (e.response?.data != null && e.response?.data is Map) {
            errorMsg = e.response?.data['message'] ?? errorMsg;
          } else if (e.response?.statusCode == 403) {
            errorMsg = "Premium Feature. Please upgrade.";
          } else if (e.response?.statusCode == 500) {
            errorMsg = "Server Error. Please try again later.";
          }
          Fluttertoast.showToast(msg: errorMsg);
        }
        return handler.next(e);
      },
    ));

    // Optional Logging Interceptor for debug mode
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
