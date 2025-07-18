import 'package:http/http.dart' as http;



abstract class ApiInterceptor {
  Future<ApiResponse> getRequest({required String endpoint, required Header header});
  Future<ApiResponse> postRequest({required String endpoint, required Header header, body});
  Future<ApiResponse> deleteRequest({required String endpoint, required Header header, body});
  Future<ApiResponse> putRequest({required String endpoint, required Header header, body});
  Future<ApiResponse> multipartRequest({required http.MultipartRequest request});
}
