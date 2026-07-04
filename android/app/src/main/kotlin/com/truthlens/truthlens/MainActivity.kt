package com.truthlens.truthlens

import android.app.ActivityManager
import android.content.Context
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // OCR Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.truthlens/ocr").setMethodCallHandler { call, result ->
            when (call.method) {
                "ping" -> result.success(true)
                "recognize" -> {
                    val path = call.argument<String>("path")
                    val languages = call.argument<List<String>>("languages")
                    if (path == null) {
                        result.error("bad_args", "缺少 path", null)
                        return@setMethodCallHandler
                    }
                    recognizeText(path, languages, result)
                }
                else -> result.notImplemented()
            }
        }

        // Device Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.truthlens/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "physicalMemoryMb" -> {
                    val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val memInfo = ActivityManager.MemoryInfo()
                    actManager.getMemoryInfo(memInfo)
                    val totalMemMb = memInfo.totalMem / (1024 * 1024)
                    result.success(totalMemMb.toInt())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun recognizeText(path: String, languages: List<String>?, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("load_failed", "文件不存在", path)
                return
            }
            val image = InputImage.fromFilePath(this, Uri.fromFile(file))
            val recognizer = when {
                languages?.any { it.startsWith("zh") } == true -> 
                    TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
                languages?.any { it.startsWith("ja") } == true -> 
                    TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
                else -> 
                    TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            }

            recognizer.process(image)
                .addOnSuccessListener { visionText ->
                    result.success(visionText.text)
                }
                .addOnFailureListener { e ->
                    result.error("ocr_failed", e.localizedMessage ?: e.message, null)
                }
        } catch (e: Exception) {
            result.error("ocr_failed", e.localizedMessage ?: e.message, null)
        }
    }
}
