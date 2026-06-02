package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
import android.media.projection.MediaProjectionManager
import android.os.Handler
import android.os.HandlerThread
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class ScreenCaptureHandler(private val activity: Activity) {
    private val backgroundThread = HandlerThread("ScreenCaptureBg").apply { start() }
    private val backgroundHandler = Handler(backgroundThread.looper)

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CAPTURE -> captureScreen(result)
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun captureScreen(result: MethodChannel.Result) {
        val resultCode = MediaProjectionPermissionHandler.lastResultCode
        val intentData = MediaProjectionPermissionHandler.lastIntentData

        if (intentData == null || resultCode != Activity.RESULT_OK) {
            result.error(
                "PERMISSION_DENIED",
                "MediaProjection permission not granted",
                null
            )
            return
        }

        val manager =
            activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                    as MediaProjectionManager
        val mediaProjection = manager.getMediaProjection(resultCode, intentData) ?: run {
            result.error(
                "PROJECTION_FAILED",
                "Failed to create media projection",
                null
            )
            return
        }

        val metrics = activity.resources.displayMetrics
        val width = metrics.widthPixels
        val height = metrics.heightPixels
        val density = metrics.densityDpi

        val imageReader = ImageReader.newInstance(
            width, height, PixelFormat.RGBA_8888, 2
        )

        val virtualDisplay = mediaProjection.createVirtualDisplay(
            "ScreenFixCapture",
            width, height, density,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader.surface, null, null
        )

        if (virtualDisplay == null) {
            result.error(
                "DISPLAY_FAILED",
                "Failed to create virtual display",
                null
            )
            mediaProjection.stop()
            imageReader.close()
            return
        }

        imageReader.setOnImageAvailableListener({ reader ->
            val image = reader.acquireLatestImage()
            if (image != null) {
                try {
                    val pngBytes = imageToPngBytes(image, width, height)
                    val map = HashMap<String, Any>()
                    map["width"] = width
                    map["height"] = height
                    map["bytes"] = pngBytes
                    result.success(map)
                } catch (e: Exception) {
                    result.error("CAPTURE_FAILED", e.message, null)
                } finally {
                    image.close()
                }
            } else {
                result.error("NO_IMAGE", "No image available from reader", null)
            }

            virtualDisplay.release()
            mediaProjection.stop()
        }, backgroundHandler)
    }

    private fun imageToPngBytes(
        image: android.media.Image,
        width: Int,
        height: Int
    ): ByteArray {
        val buffer = image.planes[0].buffer
        buffer.rewind()

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.copyPixelsFromBuffer(buffer)

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    fun dispose() {
        backgroundThread.quitSafely()
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture"
        private const val METHOD_CAPTURE = "captureScreen"
    }
}
