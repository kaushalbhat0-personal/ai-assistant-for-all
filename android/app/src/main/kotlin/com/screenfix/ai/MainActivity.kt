package com.screenfix.ai

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var screenCaptureHandler: ScreenCaptureHandler? = null
    private var mediaProjectionPermissionHandler: MediaProjectionPermissionHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OverlayMethodCallHandler(this).register(flutterEngine)

        MediaProjectionPermissionHandler(this).also {
            it.register(flutterEngine)
            mediaProjectionPermissionHandler = it
        }

        ScreenCaptureHandler(this).also {
            it.register(flutterEngine)
            screenCaptureHandler = it
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        screenCaptureHandler?.dispose()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        Log.d("ScreenFixCapture", "MainActivity.onActivityResult: called requestCode=$requestCode resultCode=$resultCode")
        super.onActivityResult(requestCode, resultCode, data)
        mediaProjectionPermissionHandler?.onActivityResult(requestCode, resultCode, data)
    }
}
