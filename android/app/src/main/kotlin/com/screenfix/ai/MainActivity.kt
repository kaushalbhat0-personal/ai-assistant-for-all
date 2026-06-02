package com.screenfix.ai

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var screenCaptureHandler: ScreenCaptureHandler? = null
    private var mediaProjectionPermissionHandler: MediaProjectionPermissionHandler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "activity_lifecycle: onCreate")
    }

    override fun onStart() {
        super.onStart()
        Log.d(TAG, "activity_lifecycle: onStart")
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "activity_lifecycle: onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "activity_lifecycle: onPause")
    }

    override fun onStop() {
        super.onStop()
        Log.d(TAG, "activity_lifecycle: onStop")
    }

    override fun onDestroy() {
        Log.d(TAG, "activity_lifecycle: onDestroy isFinishing=$isFinishing isChangingConfigurations=$isChangingConfigurations")
        super.onDestroy()
    }

    override fun finish() {
        Log.d(TAG, "activity_lifecycle: finish() called")
        super.finish()
    }

    override fun finishAffinity() {
        Log.d(TAG, "activity_lifecycle: finishAffinity() called")
        super.finishAffinity()
    }

    override fun moveTaskToBack(nonRoot: Boolean): Boolean {
        Log.d(TAG, "activity_lifecycle: moveTaskToBack($nonRoot)")
        return super.moveTaskToBack(nonRoot)
    }

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

    companion object {
        private const val TAG = "ScreenFixCapture"
    }
}
