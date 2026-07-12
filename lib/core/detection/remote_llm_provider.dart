import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// 支援多個遠程 LLM API 提供商（Ollama、Groq、Together AI 等）
abstract class RemoteLlmProvider {
  /// 生成文本回應
  Future<String> generate(String prompt, {int maxTokens = 256});

  /// 檢查連接與模型可用性
  Future<bool> healthCheck();
}

/// Ollama 本地伺服器（推薦開發環境）
/// 啟動：ollama run gemma:2b-it-q4
class OllamaProvider implements RemoteLlmProvider {
  final String baseUrl;
  final String model;

  OllamaProvider({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'gemma:2b-it-q4',
  });

  @override
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
          }
        }),
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return (json['response'] as String).trim();
      }
      throw Exception('Ollama API error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Ollama generation failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tags'),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Groq API（快速推論雲服務）
/// 需要：export GROQ_API_KEY="gsk_..."
class GroqProvider implements RemoteLlmProvider {
  final String apiKey;
  final String model;
  static const String baseUrl = 'https://api.groq.com/openai/v1';

  GroqProvider({
    required this.apiKey,
    this.model = 'gemma-7b-it',
  });

  @override
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      throw Exception('Groq API error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Groq generation failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Together AI API（多模型選擇）
/// 需要：export TOGETHER_API_KEY="..."
class TogetherAiProvider implements RemoteLlmProvider {
  final String apiKey;
  final String model;
  static const String baseUrl = 'https://api.together.xyz/v1';

  TogetherAiProvider({
    required this.apiKey,
    this.model = 'mistralai/Mistral-7B-Instruct-v0.1',
  });

  @override
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      throw Exception('Together AI API error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Together AI generation failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Anthropic Claude API
/// 需要：export ANTHROPIC_API_KEY="sk-ant-..."
class AnthropicProvider implements RemoteLlmProvider {
  final String apiKey;
  final String model;
  static const String baseUrl = 'https://api.anthropic.com/v1';

  AnthropicProvider({
    required this.apiKey,
    this.model = 'claude-3-haiku-20240307',
  });

  @override
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['content'] as List;
        if (content.isNotEmpty) {
          return (content[0]['text'] as String).trim();
        }
      }
      throw Exception('Anthropic API error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Anthropic generation failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 1,
          'messages': [{'role': 'user', 'content': 'ping'}]
        }),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
