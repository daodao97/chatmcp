import 'package:dio/dio.dart';

class LLMClient {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';
  final Dio _dio;

  LLMClient({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              responseType: ResponseType.stream,
            ));
}
