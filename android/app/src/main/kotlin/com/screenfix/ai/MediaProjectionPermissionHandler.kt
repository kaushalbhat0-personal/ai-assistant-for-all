package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
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
                            && Companion.lastIntentData != null
                    result.success(granted)
                }
                METHOD_REQUEST_PERMISSION -> requestPermission(result)
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun requestPermission(result: MethodChannel.Result) {
        pendingResult = result
        val manager = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager
        val intent = manager.createScreenCaptureIntent()
        activity.startActivityForResult(intent, REQUEST_CODE)
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE) {
            Companion.lastResultCode = resultCode
            Companion.lastIntentData = data
            val granted = resultCode == Activity.RESULT_OK
            val pending = pendingResult
            pendingResult = null
            pending?.let {
                it.success(granted)
            }
        }
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture_permission"
        private const val METHOD_CHECK_PERMISSION = "checkPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestPermission"
        const val REQUEST_CODE = 1001

        @JvmStatic
        var lastResultCode: Int = Activity.RESULT_CANCELED

        @JvmStatic
        var lastIntentData: Intent? = null
    }
}
