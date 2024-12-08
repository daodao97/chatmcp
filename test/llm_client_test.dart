import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:ChatMcp/llm/llm_client.dart';
import 'package:dotenv/dotenv.dart';

// 创建一个抽象类来模拟 Dio
abstract class DioClient extends Mock implements Dio {}

// 使用抽象类生成 Mock
@GenerateMocks([DioClient])
void main() {
  late DotEnv env;

  setUpAll(() {
    // 加载 .env 文件
    env = DotEnv(includePlatformEnvironment: true)..load();
  });

  group('LLMClient Tests', () {
    late LLMClient llmClient;

    setUp(() {
      final apiKey = env['OPENAI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception(
            'OPENAI_API_KEY is not set in the environment variables');
      }
      print('Using API Key: ${apiKey.substring(0, 5)}... (truncated)');
      llmClient = LLMClient(apiKey: apiKey);
    });

    test('streamChat should handle errors', () async {
      try {
        final stream = llmClient.streamChat('Test prompt');
        expect(stream, isA<Stream<String>>());

        await for (final response in stream) {
          print('LLM Response: $response');
        }
      } catch (e) {
        print('Test failed with error: $e');
        rethrow;
      }
    });

    test('streamChatMessages should handle errors', () async {
      final messages = [
        ChatMessage(
          role: MessageRole.system,
          content: '你是一个有帮助的助手。',
        ),
        ChatMessage(
          role: MessageRole.user,
          content: '你好！',
        ),
        ChatMessage(
          role: MessageRole.assistant,
          content: '你好！有什么我可以帮你的吗？',
        ),
        ChatMessage(
          role: MessageRole.user,
          content: '请介绍一下自己。',
        ),
      ];

      final stream = llmClient.streamChatMessages(messages);
      expect(stream, isA<Stream<String>>());

      await for (final response in stream) {
        print('LLM Response: $response');
      }
    });
  });
}
