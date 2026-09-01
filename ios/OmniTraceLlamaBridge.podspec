Pod::Spec.new do |s|
  s.name = 'OmniTraceLlamaBridge'
  s.version = '1.0.0'
  s.summary = 'OmniTrace llama.cpp C ABI bridge'
  s.description = 'Builds the OmniTrace tl_llama_* bridge and links the bundled llama.xcframework.'
  s.homepage = 'https://github.com/hauchiehlin-ops/OmniTrace'
  s.license = { :type => 'Proprietary' }
  s.author = { 'OmniTrace' => 'omnitrace@example.invalid' }
  s.source = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.source_files = 'OmniTraceLlamaBridge/**/*.{h,cpp}'
  s.vendored_frameworks = 'Libs/llama.xcframework'
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/../native/llama_bridge $(PODS_TARGET_SRCROOT)/Libs/llama.xcframework/ios-arm64/llama.framework/Headers $(PODS_TARGET_SRCROOT)/Libs/llama.xcframework/ios-arm64_x86_64-simulator/llama.framework/Headers',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_XCFRAMEWORKS_BUILD_DIR)/OmniTraceLlamaBridge',
    'OTHER_LDFLAGS' => '$(inherited) -framework llama'
  }
end
