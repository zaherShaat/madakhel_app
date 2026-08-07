package com.zaher.madakhel

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "madakhel_app/document_storage",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openDocument") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path.isNullOrBlank()) {
                result.error("INVALID", "Missing path", null)
                return@setMethodCallHandler
            }
            try {
                openPdf(path)
                result.success(null)
            } catch (e: Exception) {
                result.error("OPEN_FAILED", e.message, null)
            }
        }
    }

    private fun openPdf(path: String) {
        val file = File(path)
        if (!file.exists()) {
            throw IllegalArgumentException("File not found")
        }
        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(intent, null))
    }
}
