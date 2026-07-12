cmake_minimum_required(VERSION 3.16)
project(truthlens_llama_bridge CXX C)

# TruthLens llama.cpp 橋接層建置。
# 需要 llama.cpp 原始碼位於本目錄下的 ./llama.cpp（見 build_macos.sh 會自動 clone）。
#
#   cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
#   cmake --build build --target truthlens_llama -j8
#
# 產出 libtruthlens_llama + libllama/libggml* 一整套。

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)

if(APPLE AND NOT IOS)
    set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "" FORCE)
endif()

if(APPLE)
    # 每個 dylib 都能在自身所在目錄(app Frameworks/)找到兄弟庫。
    set(CMAKE_INSTALL_RPATH "@loader_path")
    set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
    set(CMAKE_INSTALL_NAME_DIR "@rpath")
    set(CMAKE_MACOSX_RPATH ON)
endif()

# llama.cpp：shared，關掉用不到的部分。
set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
if(APPLE)
    set(GGML_METAL ON CACHE BOOL "" FORCE)
    set(GGML_METAL_EMBED_LIBRARY ON CACHE BOOL "" FORCE)
else()
    set(GGML_METAL OFF CACHE BOOL "" FORCE)
endif()
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(LLAMA_CURL OFF CACHE BOOL "" FORCE)

add_subdirectory(llama.cpp)

add_library(truthlens_llama SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/truthlens_llama.cpp)
target_include_directories(truthlens_llama PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(truthlens_llama PRIVATE llama)

if(ANDROID)
    # Android 15+ devices may use 16 KB pages; align native outputs accordingly.
    target_link_options(truthlens_llama PRIVATE "-Wl,-z,max-page-size=16384")
endif()
