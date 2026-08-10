// Objective-C 公開介面

#ifndef InferenceHelper_h
#define InferenceHelper_h

#import <Foundation/Foundation.h>

/// iOS 推論幫助器（Objective-C 介面供 Swift 呼叫）
@interface InferenceHelper : NSObject

/// 單例
+ (InferenceHelper*)sharedInstance;

/// 載入模型
- (BOOL)loadModel:(NSString*)modelId
         modelPath:(NSString*)modelPath
      tokenizerPath:(NSString*)tokenizerPath
      tokenizerType:(NSString*)tokenizerType;

/// 執行推論（文本 → AI 機率）
- (double)classify:(NSString*)modelId
              text:(NSString*)text;

/// 檢查模型是否已載入
- (BOOL)isLoaded:(NSString*)modelId;

/// 卸載模型
- (void)unload:(NSString*)modelId;

/// 卸載所有模型
- (void)unloadAll;

@end

#endif /* InferenceHelper_h */
