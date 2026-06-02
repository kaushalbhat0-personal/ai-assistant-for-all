package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MediaProjectionPermissionHandler(private val activity: Activity) {
    private var pendingResult: MethodChannel.Result? = null

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CHECK_PERMISSION -> {
                    val granted = Companion.lastResultCode == Activity.RESULT_OK
                    Log.d(TAG, "checkPermission: lastResultCode=${Companion.lastResultCode} lastIntentData=${if (Companion.lastIntentData != null) "non-null" else "NULL"} -> $granted")
                    result.success(granted)
                }
                METHOD_REQUEST_PERMISSION -> requestPermission(result)
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun requestPermission(result: MethodChannel.Result) {
        Log.d(TAG, "requestPermission: started")
        pendingResult?.let {
            Log.d(TAG, "requestPermission: discarding stale pendingResult")
        }
        pendingResult = result
        val manager = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager
        val intent = manager.createScreenCaptureIntent()
        Log.d(TAG, "requestPermission: launching startActivityForResult code=$REQUEST_CODE")
        activity.startActivityForResult(intent, REQUEST_CODE)
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        Log.d(TAG, "onActivityResult: called requestCode=$requestCode resultCode=$resultCode data=${if (data != null) "non-null" else "NULL"}")
        if (requestCode == REQUEST_CODE) {
            Companion.lastResultCode = resultCode
            Companion.lastIntentData = data
            val granted = resultCode == Activity.RESULT_OK
            Log.d(TAG, "onActivityResult: stored lastResultCode=$resultCode lastIntentData=${if (data != null) "non-null" else "NULL"} granted=$granted")
            val pending = pendingResult
            pendingResult = null
            pending?.let {
                it.success(granted)
                Log.d(TAG, "onActivityResult: completed pendingResult with $granted")
            }
        }
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture_permission"
        private const val METHOD_CHECK_PERMISSION = "checkPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestPermission"
        const val REQUEST_CODE = 1001
        private const val TAG = "ScreenFixCapture"

        @JvmStatic
        var lastResultCode: Int = Activity.RESULT_CANCELED

        @JvmStatic
        var lastIntentData: Intent? = null
    }
}
