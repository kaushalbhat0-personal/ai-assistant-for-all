package com.screenfix.ai

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class OverlayMethodCallHandler(private val activity: Activity) {

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CHECK_PERMISSION -> {
                    val granted = checkOverlayPermission()
                    result.success(granted)
                }
                METHOD_REQUEST_PERMISSION -> {
                    requestOverlayPermission()
                    result.success(checkOverlayPermission())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkOverlayPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return Settings.canDrawOverlays(activity)
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        if (Settings.canDrawOverlays(activity)) return

        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${activity.packageName}")
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/overlay"
        private const val METHOD_CHECK_PERMISSION = "checkOverlayPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestOverlayPermission"
    }
}
