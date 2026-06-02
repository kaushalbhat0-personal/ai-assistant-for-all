package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MediaProjectionPermissionHandler(private val activity: Activity) {
    private var permissionCount = 0

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CHECK_PERMISSION -> {
                    result.success(
                        Companion.lastResultCode == Activity.RESULT_OK
                    )
                }
                METHOD_REQUEST_PERMISSION -> {
                    requestPermission()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun requestPermission() {
        permissionCount++
        val manager = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                as MediaProjectionManager
        val intent = manager.createScreenCaptureIntent()
        activity.startActivityForResult(intent, REQUEST_CODE)
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture_permission"
        private const val METHOD_CHECK_PERMISSION = "checkPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestPermission"
        const val REQUEST_CODE = 1001

        @JvmStatic
        var lastResultCode: Int = Activity.RESULT_CANCELED
            set

        @JvmStatic
        var lastIntentData: Intent? = null
            set
    }
}
