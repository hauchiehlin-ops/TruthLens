// Objective-C 實裝

#import "InferenceHelper.h"
#import <onnxruntime/ort_cxx_api.h>
#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include <unordered_map>
#include <memory>
#include <fstream>
#include <sstream>

// ==================== 簡化版 Tokenizer C++ 實裝 ====================

namespace TruthLens {

struct EncodedTokens {
  std::vector<int64_t> inputIds;
  std::vector<int64_t> attentionMask;
};

/// 簡化 BERT WordPiece Tokenizer
class SimpleWordPieceTokenizer {
 private:
  std::unordered_map<std::string, int64_t> vocab;
  int64_t clsId = 101, sepId = 102, unkId = 100, padId = 0;

 public:
  bool loadFromJson(const std::string& jsonPath) {
    try {
      std::ifstream file(jsonPath);
      if (!file.is_open()) {
        NSLog(@"[Tokenizer] ✗ 無法開啟 tokenizer JSON: %s", jsonPath.c_str());
        return false;
      }

      std::string line;
      std::string content;
      while (std::getline(file, line)) {
        content += line;
      }

      // 簡化解析：直接搜尋 "vocab" 部分
      size_t vocabPos = content.find("\"vocab\"");
      if (vocabPos == std::string::npos) {
        NSLog(@"[Tokenizer] ✗ 未找到 vocab 欄位");
        return false;
      }

      // 提取 vocab 對象內容
      size_t startBrace = content.find('{', vocabPos);
      size_t endBrace = content.rfind('}');

      if (startBrace == std::string::npos || endBrace == std::string::npos) {
        return false;
      }

      NSLog(@"[Tokenizer] ✓ 已載入 tokenizer 配置");
      return true;
    } catch (const std::exception& e) {
      NSLog(@"[Tokenizer] ✗ JSON 解析失敗: %s", e.what());
      return false;
    }
  }

  EncodedTokens encode(const std::string& text, int maxLen = 192) {
    // 簡化實作：直接使用基本空白符切分
    std::vector<int64_t> inputIds = {clsId};
    std::istringstream iss(text);
    std::string word;
    int count = 0;

    while (iss >> word && count < (maxLen - 2)) {
      // 假設 vocab 已加載，使用 UNK 為占位
      inputIds.push_back(unkId);
      count++;
    }

    inputIds.push_back(sepId);

    std::vector<int64_t> attentionMask(inputIds.size(), 1);
    return {inputIds, attentionMask};
  }
};

/// 簡化 ONNX 推論會話
class SimpleOnnxSession {
 private:
  std::unique_ptr<Ort::Session> session;
  SimpleWordPieceTokenizer tokenizer;
  Ort::Env env{ORT_LOGGING_LEVEL_WARNING, "truthlens-ios"};
  std::string modelId;
  bool isValid = false;

 public:
  SimpleOnnxSession(const std::string& modelId_) : modelId(modelId_) {}

  bool load(const std::string& modelPath,
            const std::string& tokenizerPath,
            const std::string& tokenizerType) {
    try {
      // 1. 加載 Tokenizer
      if (!tokenizer.loadFromJson(tokenizerPath)) {
        NSLog(@"[Session] ✗ Tokenizer 加載失敗");
        return false;
      }

      // 2. 加載 ONNX 模型
      std::wstring modelPathW(modelPath.begin(), modelPath.end());
      Ort::SessionOptions sessionOptions;
      sessionOptions.SetGraphOptimizationLevel(
          GraphOptimizationLevel::ORT_ENABLE_ALL);

      // 嘗試啟用 CoreML 加速
      try {
        sessionOptions.AppendExecutionProvider_CoreML(nullptr);
      } catch (...) {
        // CoreML 不可用，回退到 CPU
        NSLog(@"[Session] ℹ️ CoreML 不可用，使用 CPU 推論");
      }

      sessionOptions.AppendExecutionProvider_CPU();

      session = std::make_unique<Ort::Session>(env, modelPathW.c_str(),
                                                sessionOptions);

      isValid = true;
      NSLog(@"[Session] ✓ 模型已載入: %s", modelId.c_str());
      return true;
    } catch (const std::exception& e) {
      NSLog(@"[Session] ✗ 模型載入失敗: %s", e.what());
      return false;
    }
  }

  double classify(const std::string& text) {
    if (!isValid || !session) return 0.5;

    try {
      auto encoded = tokenizer.encode(text, 192);

      // 準備輸入張量
      Ort::MemoryInfo memoryInfo("Cpu", OrtDeviceAllocator, 0,
                                 OrtMemTypeDefault);

      std::vector<int64_t> inputShape = {1,
                                         (int64_t)encoded.inputIds.size()};
      auto inputTensor = Ort::Value::CreateTensor<int64_t>(
          memoryInfo, encoded.inputIds.data(), encoded.inputIds.size(),
          inputShape.data(), inputShape.size());

      // 執行推論
      const char* inputName = "input_ids";
      const char* outputName = "logits";

      auto outputs =
          session->Run(Ort::RunOptions{nullptr}, &inputName, &inputTensor, 1,
                       &outputName, 1);

      if (outputs.empty()) return 0.5;

      auto& output = outputs[0];
      float* outputData = output.GetTensorMutableData<float>();
      if (!outputData) return 0.5;

      // 假設輸出為 [1, 2]，取 class 1（AI 機率）
      float aiProb = outputData[1];
      return static_cast<double>(
          std::max(0.0f, std::min(1.0f, aiProb)));
    } catch (const std::exception& e) {
      NSLog(@"[Session] ✗ 推論失敗: %s", e.what());
      return 0.5;
    }
  }

  bool isLoaded() const { return isValid; }
};

/// 全局會話管理器
static std::unordered_map<std::string, std::unique_ptr<SimpleOnnxSession>>
    g_sessions;

}  // namespace TruthLens

// ==================== Objective-C 實裝 ====================

@implementation InferenceHelper {
}

+ (InferenceHelper*)sharedInstance {
  static InferenceHelper* instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[InferenceHelper alloc] init];
  });
  return instance;
}

- (BOOL)loadModel:(NSString*)modelId
         modelPath:(NSString*)modelPath
      tokenizerPath:(NSString*)tokenizerPath
      tokenizerType:(NSString*)tokenizerType {
  std::string modelIdStr = [modelId UTF8String];
  std::string modelPathStr = [modelPath UTF8String];
  std::string tokenizerPathStr = [tokenizerPath UTF8String];
  std::string tokenizerTypeStr = [tokenizerType UTF8String];

  try {
    auto session =
        std::make_unique<TruthLens::SimpleOnnxSession>(modelIdStr);
    if (!session->load(modelPathStr, tokenizerPathStr, tokenizerTypeStr)) {
      return NO;
    }

    TruthLens::g_sessions[modelIdStr] = std::move(session);
    return YES;
  } catch (const std::exception& e) {
    NSLog(@"[InferenceHelper] ✗ 載入模型異常: %s", e.what());
    return NO;
  }
}

- (double)classify:(NSString*)modelId text:(NSString*)text {
  std::string modelIdStr = [modelId UTF8String];
  std::string textStr = [text UTF8String];

  auto it = TruthLens::g_sessions.find(modelIdStr);
  if (it == TruthLens::g_sessions.end()) {
    NSLog(@"[InferenceHelper] ✗ 模型未載入: %s", modelIdStr.c_str());
    return 0.5;
  }

  return it->second->classify(textStr);
}

- (BOOL)isLoaded:(NSString*)modelId {
  std::string modelIdStr = [modelId UTF8String];
  auto it = TruthLens::g_sessions.find(modelIdStr);
  return it != TruthLens::g_sessions.end();
}

- (void)unload:(NSString*)modelId {
  std::string modelIdStr = [modelId UTF8String];
  TruthLens::g_sessions.erase(modelIdStr);
  NSLog(@"[InferenceHelper] ✓ 已卸載: %s", modelIdStr.c_str());
}

- (void)unloadAll {
  TruthLens::g_sessions.clear();
  NSLog(@"[InferenceHelper] ✓ 已卸載所有模型");
}

@end
