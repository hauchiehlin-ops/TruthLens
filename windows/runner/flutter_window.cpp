#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Media.Ocr.h>
#include <winrt/Windows.Graphics.Imaging.h>
#include <winrt/Windows.Storage.h>
#include <winrt/Windows.Storage.Streams.h>
#include <winrt/Windows.Globalization.h>
#include <string>
#include <vector>
#include <windows.h>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  // OCR and Device Method Channels
  auto messenger = flutter_controller_->engine()->messenger();

  auto ocr_channel = std::make_unique<flutter::MethodChannel<>>(
      messenger, "com.truthlens/ocr",
      &flutter::StandardMethodCodec::GetInstance());

  ocr_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "ping") {
          result->Success(flutter::EncodableValue(true));
        } else if (call.method_name() == "recognize") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!arguments) {
            result->Error("bad_args", "Arguments must be a map");
            return;
          }
          auto path_it = arguments->find(flutter::EncodableValue("path"));
          if (path_it == arguments->end() || !std::holds_alternative<std::string>(path_it->second)) {
            result->Error("bad_args", "缺少 path");
            return;
          }
          std::string path_utf8 = std::get<std::string>(path_it->second);

          // Convert path to wstring
          int size_needed = MultiByteToWideChar(CP_UTF8, 0, &path_utf8[0], (int)path_utf8.size(), NULL, 0);
          std::wstring path_wide(size_needed, 0);
          MultiByteToWideChar(CP_UTF8, 0, &path_utf8[0], (int)path_utf8.size(), &path_wide[0], size_needed);

          try {
            // Load file and run OCR using WinRT synchronously (.get())
            auto file = winrt::Windows::Storage::StorageFile::GetFileFromPathAsync(path_wide).get();
            auto stream = file.OpenAsync(winrt::Windows::Storage::FileAccessMode::Read).get();
            auto decoder = winrt::Windows::Graphics::Imaging::BitmapDecoder::CreateAsync(stream).get();
            auto bitmap = decoder.GetSoftwareBitmapAsync().get();

            auto engine = winrt::Windows::Media::Ocr::OcrEngine::TryCreateFromUserProfileLanguages();
            if (!engine) {
              engine = winrt::Windows::Media::Ocr::OcrEngine::TryCreateFromLanguage(
                  winrt::Windows::Globalization::Language(L"en-US"));
            }

            if (!engine) {
              result->Error("ocr_failed", "Cannot create OCR Engine");
              return;
            }

            auto ocrResult = engine.RecognizeAsync(bitmap).get();
            std::wstring recognized_text = ocrResult.Text().c_str();

            // Convert recognized text back to UTF-8
            int output_size = WideCharToMultiByte(CP_UTF8, 0, &recognized_text[0], (int)recognized_text.size(), NULL, 0, NULL, NULL);
            std::string text_utf8(output_size, 0);
            WideCharToMultiByte(CP_UTF8, 0, &recognized_text[0], (int)recognized_text.size(), &text_utf8[0], output_size, NULL, NULL);

            result->Success(flutter::EncodableValue(text_utf8));
          } catch (const winrt::hresult_error& ex) {
            std::wstring err_msg = ex.message().c_str();
            int err_size = WideCharToMultiByte(CP_UTF8, 0, &err_msg[0], (int)err_msg.size(), NULL, 0, NULL, NULL);
            std::string err_utf8(err_size, 0);
            WideCharToMultiByte(CP_UTF8, 0, &err_msg[0], (int)err_msg.size(), &err_utf8[0], err_size, NULL, NULL);
            result->Error("ocr_failed", err_utf8);
          } catch (const std::exception& e) {
            result->Error("ocr_failed", e.what());
          } catch (...) {
            result->Error("ocr_failed", "Unknown native error during OCR");
          }
        } else {
          result->NotImplemented();
        }
      });

  auto device_channel = std::make_unique<flutter::MethodChannel<>>(
      messenger, "com.truthlens/device",
      &flutter::StandardMethodCodec::GetInstance());

  device_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "physicalMemoryMb") {
          ULONGLONG memKb = 0;
          if (GetPhysicallyInstalledSystemMemory(&memKb)) {
            int memMb = static_cast<int>(memKb / 1024);
            result->Success(flutter::EncodableValue(memMb));
          } else {
            MEMORYSTATUSEX statex;
            statex.dwLength = sizeof(statex);
            if (GlobalMemoryStatusEx(&statex)) {
              int memMb = static_cast<int>(statex.ullTotalPhys / (1024 * 1024));
              result->Success(flutter::EncodableValue(memMb));
            } else {
              result->Success(flutter::EncodableValue(8192)); // default fallback
            }
          }
        } else {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
