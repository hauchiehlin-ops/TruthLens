Pod::Spec.new do |s|
  s.name = 'TruthLensLlamaBridge'
  s.version = '1.0.0'
  s.summary = 'TruthLens llama.cpp C ABI bridge'
  s.description = 'Builds the TruthLens tl_llama_* bridge and links the bundled llama.xcframework.'
  s.homepage = 'https://github.com/hauchiehlin-ops/TruthLens'
  s.license = { :type => 'Proprietary' }
  s.author = { 'TruthLens' => 'truthlens@example.invalid' }
  s.source = { :path => '.' }
  s.ios.deployment_target = '13.0'
  s.source_files = 'TruthLensLlamaBridge/**/*.{h,cpp}'
  s.vendored_frameworks = 'Libs/llama.xcframework'
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/../native/llama_bridge $(PODS_TARGET_SRCROOT)/Libs/llama.xcframework/ios-arm64/llama.framework/Headers $(PODS_TARGET_SRCROOT)/Libs/llama.xcframework/ios-arm64_x86_64-simulator/llama.framework/Headers',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_XCFRAMEWORKS_BUILD_DIR)/TruthLensLlamaBridge',
    'OTHER_LDFLAGS' => '$(inherited) -framework llama'
  }
end
