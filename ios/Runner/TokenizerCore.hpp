#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <memory>
#include <regex>
#include <algorithm>
#include <cstring>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

/// BERT/RoBERTa Tokenizer C++ 實裝
/// 支援 WordPiece (BERT) 和 Byte-Pair Encoding (RoBERTa)
namespace TruthLens {

/// 編碼結果：token ID 序列與 attention mask
struct EncodedTokens {
  std::vector<int64_t> inputIds;
  std::vector<int64_t> attentionMask;
};

/// 抽象 Tokenizer 介面
class Tokenizer {
 public:
  virtual ~Tokenizer() = default;
  virtual EncodedTokens encode(const std::string& text, int maxLen = 192) = 0;
};

/// BERT WordPiece Tokenizer
class WordPieceTokenizer : public Tokenizer {
 private:
  std::unordered_map<std::string, int64_t> vocab;
  bool lowercase;
  int64_t clsId, sepId, unkId, padId;
  static constexpr int maxCharsPerWord = 100;

 public:
  WordPieceTokenizer(const std::unordered_map<std::string, int64_t>& vocab_,
                     bool lowercase_ = false,
                     int64_t clsId_ = 101, int64_t sepId_ = 102,
                     int64_t unkId_ = 100, int64_t padId_ = 0)
      : vocab(vocab_), lowercase(lowercase_), clsId(clsId_), sepId(sepId_),
        unkId(unkId_), padId(padId_) {}

  /// 從 HuggingFace tokenizer.json 建構
  static std::unique_ptr<WordPieceTokenizer> fromJson(const json& config);

  EncodedTokens encode(const std::string& text, int maxLen = 192) override;

 private:
  std::vector<std::string> basicTokenize(const std::string& text);
  std::string cleanAndSpaceCjk(const std::string& text);
  std::vector<std::string> splitPunctuation(const std::string& token);
  std::vector<int64_t> wordpiece(const std::string& token);

  bool isCjk(uint32_t rune);
  bool isControl(uint32_t rune);
  bool isWhitespace(uint32_t rune);
  bool isPunct(uint32_t rune);
};

/// RoBERTa Byte-Pair Encoding Tokenizer
class BpeTokenizer : public Tokenizer {
 private:
  std::unordered_map<std::string, int64_t> vocab;
  std::vector<std::pair<std::string, std::string>> merges;
  int64_t bosId, eosId, unkId, padId;

 public:
  BpeTokenizer(const std::unordered_map<std::string, int64_t>& vocab_,
               const std::vector<std::pair<std::string, std::string>>& merges_,
               int64_t bosId_ = 0, int64_t eosId_ = 2,
               int64_t unkId_ = 3, int64_t padId_ = 1)
      : vocab(vocab_), merges(merges_), bosId(bosId_), eosId(eosId_),
        unkId(unkId_), padId(padId_) {}

  /// 從 HuggingFace tokenizer.json 建構
  static std::unique_ptr<BpeTokenizer> fromJson(const json& config);

  EncodedTokens encode(const std::string& text, int maxLen = 192) override;

 private:
  std::vector<std::string> bytePair(const std::string& text);
  std::vector<std::string> bpeEncode(const std::vector<std::string>& tokens);
};

/// Tokenizer 工廠函數
inline std::unique_ptr<Tokenizer> buildTokenizer(const std::string& type,
                                                   const std::string& jsonStr) {
  try {
    auto config = json::parse(jsonStr);
    auto model = config.at("model");

    if (type == "roberta-bpe") {
      return BpeTokenizer::fromJson(model);
    } else {
      // 默認 BERT WordPiece
      return WordPieceTokenizer::fromJson(model);
    }
  } catch (const std::exception& e) {
    throw std::runtime_error(std::string("Tokenizer 初始化失敗: ") + e.what());
  }
}

}  // namespace TruthLens
