package com.amanah.amanah

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.amanah.amanah/incoming"
    private var channel: MethodChannel? = null
    private var pendingPath: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
        handleIncoming(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIncoming(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "takePending") {
                val path = pendingPath
                pendingPath = null
                result.success(path)
            } else {
                result.notImplemented()
            }
        }
        pendingPath?.let { path ->
            channel?.invokeMethod("onFile", path)
        }
    }

    private fun handleIncoming(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return
        if (action == Intent.ACTION_MAIN) return
        val uri = extractUri(intent) ?: return
        val path = copyToCache(uri) ?: return
        pendingPath = path
        channel?.invokeMethod("onFile", path)
    }

    private fun extractUri(intent: Intent): Uri? {
        when (intent.action) {
            Intent.ACTION_VIEW, Intent.ACTION_EDIT -> {
                intent.data?.let { return it }
            }
            Intent.ACTION_SEND -> {
                streamExtra(intent)?.let { return it }
                intent.clipData?.takeIf { it.itemCount > 0 }?.getItemAt(0)?.uri?.let { return it }
                intent.data?.let { return it }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                streamList(intent)?.firstOrNull()?.let { return it }
                intent.clipData?.takeIf { it.itemCount > 0 }?.getItemAt(0)?.uri?.let { return it }
            }
        }
        return intent.data
    }

    private fun streamExtra(intent: Intent): Uri? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
    }

    private fun streamList(intent: Intent): List<Uri>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
        }
    }

    private fun copyToCache(uri: Uri): String? {
        return try {
            val dir = File(cacheDir, "incoming")
            if (!dir.exists()) dir.mkdirs()
            val dest = File(dir, "amanah-${System.currentTimeMillis()}.amanahbak")
            contentResolver.openInputStream(uri)?.use { input ->
                dest.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
            if (!dest.exists() || dest.length() == 0L) return null
            dest.absolutePath
        } catch (_: Exception) {
            null
        }
    }
}
