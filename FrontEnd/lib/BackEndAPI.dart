import 'package:dio/dio.dart';

const String baseUrl = 'http://localhost:8080';
final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

// 날짜 포맷: yyyy-MM-dd
String formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

// 기본 에러 처리 래퍼
Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw Exception(e.response?.data?.toString() ?? e.message);
  } catch (e) {
    throw Exception(e.toString());
  }
}

// uid 포함 GET 요청
Future<Response> getWithUid(String path, int uid, {Map<String, dynamic>? query}) {
  final params = {'uid': uid, ...?query};
  return safeRequest(() => dio.get(path, queryParameters: params));
}

// uid 포함 POST 요청
Future<Response> postWithUid(String path, int uid, {dynamic data}) {
  final body = {'uid': uid, ...?data};
  return safeRequest(() => dio.post(path, data: body));
}