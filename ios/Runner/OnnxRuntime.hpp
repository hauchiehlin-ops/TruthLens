#pragma once

#include <string>
#include <vector>
#include <memory>
#include <onnxruntime/ort_cxx_api.h>
#include "TokenizerCore.hpp"

namespace TruthLens {

/// ONNX Runtime 推論會話包裝
class OnnxSession {
 private:
  Ort::Env env;
  Ort::SessionOptions sessionOptions;
  std::unique_ptr<Ort::Session> session;
  std::unique_ptr<Tokenizer> tokenizer;
  std::string modelId;

  // 模型輸入/輸出配置
  std::vector<const char*> inputNames;
  std::vector<const char*> outputNames;
  std::vector<std::vector<int64_t>> inputShapes;

 public:
  OnnxSession(const std::string& modelId_);
  ~OnnxSession();

  /// 載入模型和 tokenizer
  bool load(const std::string& modelPath,
            const std::string& tokenizerJson,
            const std::string& tokenizerType);

  /// 執行推論
  /// @return 輸出張量的 AI 機率 (0.0 ~ 1.0)
  double classify(const std::string& text);

  /// 取得模型 ID
  const std::string& getModelId() const { return modelId; }

  /// 檢查會話是否有效
  bool isValid() const { return session != nullptr && tokenizer != nullptr; }

 private:
  /// 解析模型的輸入/輸出配置
  void inspectModel();

  /// 將文本編碼為模型輸入
  std::vector<Ort::Value> prepareInputs(const std::string& text);

  /// 從模型輸出提取 AI 機率
  double extractProbability(const std::vector<Ort::Value>& outputs);
};

/// ONNX Runtime 全局管理器
class OnnxSessionManager {
 private:
  std::unordered_map<std::string, std::unique_ptr<OnnxSession>> sessions;
  static OnnxSessionManager* instance;

 public:
  static OnnxSessionManager& getInstance();

  /// 載入模型
  bool loadModel(const std::string& modelId,
                 const std::string& modelPath,
                 const std::string& tokenizerJson,
                 const std::string& tokenizerType);

  /// 執行推論
  double classify(const std::string& modelId, const std::string& text);

  /// 檢查模型是否已載入
  bool isLoaded(const std::string& modelId) const;

  /// 卸載模型
  void unload(const std::string& modelId);

  /// 卸載所有模型
  void unloadAll();
};

}  // namespace TruthLens
