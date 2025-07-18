import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'package:grs/di.dart';


import 'package:grs/interceptors/api_interceptor.dart';

import 'package:grs/service/auth_service.dart';
import 'package:grs/service/routes.dart';

import 'package:grs/view_models/global_view_model.dart';

const _200 = 200;
const _300 = 300;
const _400 = 400;
const _500 = 500;

class HttpLibrary implements ApiInterceptor {
  static String bearerToken = '';

  static setToken({required String token}) => bearerToken = 'Bearer $token';

  @override
  Future<ApiResponse> getRequest({required String endpoint, required Header header, bool? utfDecode}) async {
    // if (kDebugMode) print('get: $endpoint');
    HttpClient client = HttpClient();
    try {
      var uri = Uri.parse(endpoint);
      http.Response response = await http.get(uri, headers: _getHeader(header));
      return _returnResponse(response);
    } catch (error) {
      if (kDebugMode) print('ERROR::::::$error::::::$endpoint');
      client.close();
      return ApiResponse(status: _500, response: null);
    }
  }

  @override
  Future<ApiResponse> postRequest({required String endpoint, required Header header, body}) async {
    HttpClient client = HttpClient();
    // if (kDebugMode) print('post: $endpoint');
    try {
      var uri = Uri.parse(endpoint);
      var encodedBody = body == null ? null : json.encode(body);
      http.Response response = await http.post(uri, body: encodedBody, headers: _getHeader(header));
      return _returnResponse(response);
    } catch (error) {
      if (kDebugMode) print('ERROR::::::$error::::::$endpoint');
      client.close();
      return ApiResponse(status: _500, response: null);
    }
  }

  @override
  Future<ApiResponse> putRequest({required String endpoint, required Header header, body}) async {
    // if (kDebugMode) print('put: $endpoint');
    HttpClient client = HttpClient();
    try {
      var uri = Uri.parse(endpoint);
      var encodedBody = body == null ? null : json.encode(body);
      http.Response response = await http.put(uri, body: encodedBody, headers: _getHeader(header));
      return _returnResponse(response);
    } catch (error) {
      if (kDebugMode) print('ERROR::::::$error::::::$endpoint');
      client.close();
      return ApiResponse(status: _500, response: null);
    }
  }

  @override
  Future<ApiResponse> deleteRequest({required String endpoint, required Header header, body}) async {
    // if (kDebugMode) print('delete: $endpoint');
    HttpClient client = HttpClient();
    try {
      var uri = Uri.parse(endpoint);
      var encodedBody = body == null ? null : json.encode(body);
      http.Response response = await http.delete(uri, body: encodedBody, headers: _getHeader(header));
      return _returnResponse(response);
    } catch (error) {
      if (kDebugMode) print('ERROR::::::$error::::::$endpoint');
      client.close();
      return ApiResponse(status: _500, response: null);
    }
  }

  @override
  Future<ApiResponse> multipartRequest({required http.MultipartRequest request}) async {
    HttpClient client = HttpClient();
    try {
      http.StreamedResponse response = await request.send();
      var responseResult = await response.stream.bytesToString();
      var returnResponse = http.Response(responseResult, response.statusCode, headers: response.headers, request: response.request);
      return _returnResponse(returnResponse);
    } catch (error) {
      if (kDebugMode) print('ERROR::::::$error::::::${request.url.path}');
      client.close();
      return ApiResponse(status: _500, response: null);
    }
  }

  ApiResponse _returnResponse(http.Response response) {
    int statusCode = response.statusCode;
    if (kDebugMode) print('status: $statusCode api: ${response.request?.url}');
    if (kDebugMode) print('response: ${response.body}');
    if (statusCode >= 500 && statusCode <= 599) return ApiResponse(status: _500, response: null);
    var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    if (jsonResponse['status'] == 'error' && jsonResponse['message'] == 'Token response empty') _logoutUser();
    var isSuccess = jsonResponse['status'] == 'success';
    if ((statusCode >= 200 && statusCode <= 299) || statusCode == 422) {
      return ApiResponse(status: isSuccess ? _200 : _300, response: jsonResponse);
    } else if (statusCode == 401 || statusCode == 403) {
      _logoutUser();
      return ApiResponse(status: _400, response: jsonResponse);
    } else if (statusCode == 404) {
      return ApiResponse(status: _300, response: jsonResponse);
    } else if (statusCode == 422) {
      return ApiResponse(status: isSuccess ? _200 : _300, response: jsonResponse);
    } else {
      return ApiResponse(status: _500, response: null);
    }
  }

  void _logoutUser() {
    sl<AuthService>().removeStorageData();
    sl<Routes>().signInScreen().pushAndRemoveUntil();
    var context = navigatorKey.currentState?.context;
    if (context != null) Provider.of<GlobalViewModel>(context, listen: false).clearStates();
  }

  Map<String, String> _getHeader(Header header) => header == Header.http ? _getHttpHeaders() : _getAuthHeaders();

  Map<String, String> _getHttpHeaders() {
    Map<String, String> headers = <String, String>{};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    return headers;
  }

  Map<String, String> _getAuthHeaders() {
    Map<String, String> headers = <String, String>{};
    headers['Authorization'] = bearerToken;
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    return headers;
  }
}
