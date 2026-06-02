package com.screenfix.ai

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var screenCaptureHandler: ScreenCaptureHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OverlayMethodCallHandler(this).register(flutterEngine)
        MediaProjectionPermissionHandler(this).register(flutterEngine)
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
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == MediaProjectionPermissionHandler.REQUEST_CODE) {
            MediaProjectionPermissionHandler.lastResultCode = resultCode
            MediaProjectionPermissionHandler.lastIntentData = data
        }
    }
}
