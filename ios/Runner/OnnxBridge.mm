// Objective-C++ 橋接實裝
#import <Foundation/Foundation.h>
#include "TokenizerCore.hpp"
#include "OnnxRuntime.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;
using namespace TruthLens;

// ==================== C++ 實裝：Tokenizer ====================

namespace TruthLens {

// ---- WordPieceTokenizer 實裝 ----

bool WordPieceTokenizer::isCjk(uint32_t rune) {
  return (rune >= 0x4E00 && rune <= 0x9FFF) ||  // CJK Unified Ideographs
         (rune >= 0x3400 && rune <= 0x4DBF) ||  // CJK Extension A
         (rune >= 0x20000 && rune <= 0x2A6DF) || // CJK Extension B
         (rune >= 0x3040 && rune <= 0x309F) ||  // Hiragana
         (rune >= 0x30A0 && rune <= 0x30FF) ||  // Katakana
         (rune >= 0xAC00 && rune <= 0xD7AF);   // Hangul
}

bool WordPieceTokenizer::isControl(uint32_t rune) {
  if (rune <= 0x1F || (rune >= 0x7F && rune <= 0x9F)) return true;
  auto cat = u_charType(rune);
  return cat == U_CONTROL_CHAR || cat == U_FORMAT_CHAR;
}

bool WordPieceTokenizer::isWhitespace(uint32_t rune) {
  return rune == ' ' || rune == '\t' || rune == '\n' || rune == '\r';
}

bool WordPieceTokenizer::isPunct(uint32_t rune) {
  if ((rune >= 33 && rune <= 47) ||   // !"#$%&'()*+,-./
      (rune >= 58 && rune <= 64) ||   // :;<=>?@
      (rune >= 91 && rune <= 96) ||   // [\]^_`
      (rune >= 123 && rune <= 126)) { // {|}~
    return true;
  }
  return false;
}

std::string WordPieceTokenizer::cleanAndSpaceCjk(const std::string& text) {
  std::ostringstream buf;
  for (size_t i = 0; i < text.length();) {
    uint32_t rune = 0;
    size_t len = 0;

    // UTF-8 解碼
    unsigned char c = static_cast<unsigned char>(text[i]);
    if ((c & 0x80) == 0) {
      rune = c;
      len = 1;
    } else if ((c & 0xE0) == 0xC0 && i + 1 < text.length()) {
      rune = ((c & 0x1F) << 6) | (text[i + 1] & 0x3F);
      len = 2;
    } else if ((c & 0xF0) == 0xE0 && i + 2 < text.length()) {
      rune = ((c & 0x0F) << 12) | ((text[i + 1] & 0x3F) << 6) |
             (text[i + 2] & 0x3F);
      len = 3;
    } else if ((c & 0xF8) == 0xF0 && i + 3 < text.length()) {
      rune = ((c & 0x07) << 18) | ((text[i + 1] & 0x3F) << 12) |
             ((text[i + 2] & 0x3F) << 6) | (text[i + 3] & 0x3F);
      len = 4;
    }

    if (len == 0) {
      i++;
      continue;
    }

    if (isControl(rune) || rune == 0xFFFD) {
      // 跳過控制字符
    } else if (isWhitespace(rune)) {
      buf << " ";
    } else if (isCjk(rune)) {
      buf << " ";
      buf << text.substr(i, len);  // 追加原始 UTF-8 序列
      buf << " ";
    } else {
      buf << text.substr(i, len);
    }

    i += len;
  }
  return buf.str();
}

std::vector<std::string> WordPieceTokenizer::splitPunctuation(
    const std::string& token) {
  std::vector<std::string> out;
  std::ostringstream sb;

  for (size_t i = 0; i < token.length();) {
    uint32_t rune = 0;
    size_t len = 1;

    unsigned char c = static_cast<unsigned char>(token[i]);
    if ((c & 0x80) == 0) {
      rune = c;
      len = 1;
    } else if ((c & 0xE0) == 0xC0 && i + 1 < token.length()) {
      rune = ((c & 0x1F) << 6) | (token[i + 1] & 0x3F);
      len = 2;
    } else if ((c & 0xF0) == 0xE0 && i + 2 < token.length()) {
      rune = ((c & 0x0F) << 12) | ((token[i + 1] & 0x3F) << 6) |
             (token[i + 2] & 0x3F);
      len = 3;
    } else if ((c & 0xF8) == 0xF0 && i + 3 < token.length()) {
      rune = ((c & 0x07) << 18) | ((token[i + 1] & 0x3F) << 12) |
             ((token[i + 2] & 0x3F) << 6) | (token[i + 3] & 0x3F);
      len = 4;
    }

    if (isPunct(rune)) {
      if (sb.tellp() > 0) {
        out.push_back(sb.str());
        sb.str("");
        sb.clear();
      }
      out.push_back(token.substr(i, len));
    } else {
      sb << token.substr(i, len);
    }

    i += len;
  }

  if (sb.tellp() > 0) out.push_back(sb.str());
  return out;
}

std::vector<std::string> WordPieceTokenizer::basicTokenize(
    const std::string& text) {
  auto cleaned = cleanAndSpaceCjk(text);
  std::vector<std::string> tokens;

  // 按空白符分割
  std::istringstream iss(cleaned);
  std::string chunk;
  while (iss >> chunk) {
    auto piece = lowercase ? chunk : chunk;
    if (lowercase) {
      std::transform(piece.begin(), piece.end(), piece.begin(), ::tolower);
    }
    auto parts = splitPunctuation(piece);
    tokens.insert(tokens.end(), parts.begin(), parts.end());
  }

  return tokens;
}

std::vector<int64_t> WordPieceTokenizer::wordpiece(const std::string& token) {
  if (token.length() > maxCharsPerWord) return {unkId};

  std::vector<int64_t> ids;
  size_t start = 0;

  while (start < token.length()) {
    size_t end = token.length();
    int64_t curId = -1;

    while (start < end) {
      std::string sub = token.substr(start, end - start);
      if (start > 0) sub = "##" + sub;

      auto it = vocab.find(sub);
      if (it != vocab.end()) {
        curId = it->second;
        break;
      }
      end--;
    }

    if (curId == -1) {
      ids.push_back(unkId);
      start++;
    } else {
      ids.push_back(curId);
      start = end;
    }
  }

  return ids;
}

std::unique_ptr<WordPieceTokenizer> WordPieceTokenizer::fromJson(
    const json& model) {
  std::unordered_map<std::string, int64_t> vocab;

  if (model.contains("vocab") && model["vocab"].is_object()) {
    for (auto& [k, v] : model["vocab"].items()) {
      if (v.is_number()) {
        vocab[k] = v.get<int64_t>();
      }
    }
  }

  auto clsId = vocab.count("[CLS]") ? vocab["[CLS]"] : 101;
  auto sepId = vocab.count("[SEP]") ? vocab["[SEP]"] : 102;
  auto unkId = vocab.count("[UNK]") ? vocab["[UNK]"] : 100;
  auto padId = vocab.count("[PAD]") ? vocab["[PAD]"] : 0;

  return std::make_unique<WordPieceTokenizer>(vocab, false, clsId, sepId,
                                               unkId, padId);
}

EncodedTokens WordPieceTokenizer::encode(const std::string& text,
                                         int maxLen) {
  auto tokens = basicTokenize(text);
  std::vector<int64_t> pieces;

  for (const auto& token : tokens) {
    auto wp = wordpiece(token);
    pieces.insert(pieces.end(), wp.begin(), wp.end());
  }

  int limit = maxLen - 2;  // 保留 CLS / SEP
  std::vector<int64_t> content;
  if ((int)pieces.size() > limit) {
    content.assign(pieces.begin(), pieces.begin() + limit);
  } else {
    content = pieces;
  }

  std::vector<int64_t> ids = {clsId};
  ids.insert(ids.end(), content.begin(), content.end());
  ids.push_back(sepId);

  std::vector<int64_t> mask(ids.size(), 1);

  return {ids, mask};
}

// ---- BpeTokenizer 簡化實裝 ----

std::unique_ptr<BpeTokenizer> BpeTokenizer::fromJson(const json& model) {
  std::unordered_map<std::string, int64_t> vocab;

  if (model.contains("vocab") && model["vocab"].is_object()) {
    for (auto& [k, v] : model["vocab"].items()) {
      if (v.is_number()) {
        vocab[k] = v.get<int64_t>();
      }
    }
  }

  std::vector<std::pair<std::string, std::string>> merges;
  // 簡化：暫不實裝完整 BPE merges 邏輯

  return std::make_unique<BpeTokenizer>(vocab, merges);
}

std::vector<std::string> BpeTokenizer::bytePair(const std::string& text) {
  // 簡化實裝：逐字符轉換
  std::vector<std::string> result;
  for (char c : text) {
    result.push_back(std::string(1, c));
  }
  return result;
}

std::vector<std::string> BpeTokenizer::bpeEncode(
    const std::vector<std::string>& tokens) {
  // 簡化實裝：直接返回
  return tokens;
}

EncodedTokens BpeTokenizer::encode(const std::string& text, int maxLen) {
  auto bp = bytePair(text);
  auto encoded = bpeEncode(bp);

  std::vector<int64_t> ids = {bosId};
  for (const auto& token : encoded) {
    auto it = vocab.find(token);
    if (it != vocab.end()) {
      ids.push_back(it->second);
    } else {
      ids.push_back(unkId);
    }
  }
  ids.push_back(eosId);

  if ((int)ids.size() > maxLen) {
    ids.resize(maxLen);
  }

  std::vector<int64_t> mask(ids.size(), 1);
  return {ids, mask};
}

}  // namespace TruthLens

// ==================== C++ 實裝：ONNX Runtime ====================

namespace TruthLens {

OnnxSessionManager* OnnxSessionManager::instance = nullptr;

OnnxSession::OnnxSession(const std::string& modelId_)
    : modelId(modelId_),
      env(ORT_LOGGING_LEVEL_WARNING, "truthlens-ios") {
  // 配置會話選項
  sessionOptions.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);

  // iOS/Metal 加速（如可用）
  sessionOptions.AppendExecutionProvider_CoreML(nullptr);
  sessionOptions.AppendExecutionProvider_CPU();
}

OnnxSession::~OnnxSession() {}

bool OnnxSession::load(const std::string& modelPath,
                       const std::string& tokenizerJson,
                       const std::string& tokenizerType) {
  try {
    // 初始化 tokenizer
    tokenizer = buildTokenizer(tokenizerType, tokenizerJson);

    // 加載模型
    std::wstring modelPathW(modelPath.begin(), modelPath.end());
    session = std::make_unique<Ort::Session>(env, modelPathW.c_str(),
                                              sessionOptions);

    // 檢查模型配置
    inspectModel();

    NSLog(@"[OnnxSession] ✓ 模型已載入: %s", modelPath.c_str());
    return true;
  } catch (const std::exception& e) {
    NSLog(@"[OnnxSession] ✗ 載入失敗: %s", e.what());
    return false;
  }
}

void OnnxSession::inspectModel() {
  if (!session) return;

  Ort::AllocatorWithDefaultOptions allocator;
  size_t numInputs = session->GetInputCount();
  size_t numOutputs = session->GetOutputCount();

  NSLog(@"[OnnxSession] 模型配置: %zu 個輸入, %zu 個輸出", numInputs,
        numOutputs);

  for (size_t i = 0; i < numInputs; i++) {
    char* inputName = session->GetInputName(i, allocator);
    inputNames.push_back(inputName);

    auto inputInfo = session->GetInputTypeInfo(i);
    auto shape = inputInfo.GetTensorTypeAndShapeInfo().GetShape();
    inputShapes.push_back(std::vector<int64_t>(shape.begin(), shape.end()));

    NSLog(@"  輸入 %zu: %s (shape: [..., %lld])", i, inputName, shape.back());
  }

  for (size_t i = 0; i < numOutputs; i++) {
    char* outputName = session->GetOutputName(i, allocator);
    outputNames.push_back(outputName);
    NSLog(@"  輸出 %zu: %s", i, outputName);
  }
}

std::vector<Ort::Value> OnnxSession::prepareInputs(const std::string& text) {
  if (!tokenizer) throw std::runtime_error("Tokenizer 未初始化");

  auto encoded = tokenizer->encode(text, 192);

  std::vector<Ort::Value> inputs;
  Ort::MemoryInfo info("Cpu", OrtDeviceAllocator, 0, OrtMemTypeDefault);

  // input_ids
  auto inputIdsValue = Ort::Value::CreateTensor<int64_t>(
      info, encoded.inputIds.data(), encoded.inputIds.size(),
      inputShapes[0].data(), inputShapes[0].size());
  inputs.push_back(std::move(inputIdsValue));

  // attention_mask
  if (inputShapes.size() > 1) {
    auto maskValue = Ort::Value::CreateTensor<int64_t>(
        info, encoded.attentionMask.data(), encoded.attentionMask.size(),
        inputShapes[1].data(), inputShapes[1].size());
    inputs.push_back(std::move(maskValue));
  }

  return inputs;
}

double OnnxSession::extractProbability(
    const std::vector<Ort::Value>& outputs) {
  if (outputs.empty()) return 0.5;

  auto& output = outputs[0];
  auto info = output.GetTensorTypeAndShapeInfo();
  auto shape = info.GetShape();

  if (shape.size() < 2) return 0.5;

  auto data = output.GetTensorData<float>();
  if (!data) return 0.5;

  // 假設輸出為 [batch_size, num_classes]，取第 1 個類別（AI 機率）
  // 通常 num_classes = 2，[class_0, class_1] → class_1 = AI
  float aiProb = data[1];

  // Softmax 已在模型中完成，直接返回
  return static_cast<double>(std::max(0.0f, std::min(1.0f, aiProb)));
}

double OnnxSession::classify(const std::string& text) {
  if (!session || !tokenizer) return 0.5;

  try {
    auto inputs = prepareInputs(text);
    std::vector<const char*> inputNamesCStr;
    for (const auto& name : inputNames) {
      inputNamesCStr.push_back(name);
    }
    std::vector<const char*> outputNamesCStr;
    for (const auto& name : outputNames) {
      outputNamesCStr.push_back(name);
    }

    auto outputs = session->Run(
        Ort::RunOptions{nullptr}, inputNamesCStr.data(), inputs.data(),
        inputs.size(), outputNamesCStr.data(), outputNamesCStr.size());

    return extractProbability(outputs);
  } catch (const std::exception& e) {
    NSLog(@"[OnnxSession] 推論失敗: %s", e.what());
    return 0.5;
  }
}

OnnxSessionManager& OnnxSessionManager::getInstance() {
  if (!instance) {
    instance = new OnnxSessionManager();
  }
  return *instance;
}

bool OnnxSessionManager::loadModel(const std::string& modelId,
                                    const std::string& modelPath,
                                    const std::string& tokenizerJson,
                                    const std::string& tokenizerType) {
  auto session = std::make_unique<OnnxSession>(modelId);
  bool success = session->load(modelPath, tokenizerJson, tokenizerType);
  if (success) {
    sessions[modelId] = std::move(session);
  }
  return success;
}

double OnnxSessionManager::classify(const std::string& modelId,
                                     const std::string& text) {
  auto it = sessions.find(modelId);
  if (it == sessions.end()) return 0.5;
  return it->second->classify(text);
}

bool OnnxSessionManager::isLoaded(const std::string& modelId) const {
  return sessions.find(modelId) != sessions.end();
}

void OnnxSessionManager::unload(const std::string& modelId) {
  sessions.erase(modelId);
}

void OnnxSessionManager::unloadAll() {
  sessions.clear();
}

}  // namespace TruthLens
