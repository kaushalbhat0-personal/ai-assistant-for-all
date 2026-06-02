package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class ScreenCaptureHandler(private val activity: Activity) {
    private val backgroundThread = HandlerThread("ScreenCaptureBg").apply { start() }
    private val backgroundHandler = Handler(backgroundThread.looper)

    private val listenerThread = HandlerThread("ImageListener").apply { start() }
    private val listenerHandler = Handler(listenerThread.looper)

    private var mediaProjection: MediaProjection? = null
    private var projectionCallback: MediaProjection.Callback? = null
    private var serviceIntent: Intent? = null
    private var currentVirtualDisplay: android.hardware.display.VirtualDisplay? = null
    private var sessionActive = false

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_START_SESSION -> startProjectionSession(result)
                METHOD_CAPTURE -> captureScreen(result)
                METHOD_STOP_SESSION -> stopProjectionSession(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startProjectionSession(result: MethodChannel.Result) {
        if (sessionActive) {
            result.success(true)
            return
        }
        val resultCode = MediaProjectionPermissionHandler.lastResultCode
        val intentData = MediaProjectionPermissionHandler.lastIntentData ?: run {
            result.error("PERMISSION_DENIED", "MediaProjection permission not granted", null)
            return
        }
        if (resultCode != Activity.RESULT_OK) {
            result.error("PERMISSION_DENIED", "MediaProjection permission not granted", null)
            return
        }

        MediaProjectionService.reset()
        val intent = Intent(activity, MediaProjectionService::class.java)
        serviceIntent = intent
        ContextCompat.startForegroundService(activity, intent)

        backgroundHandler.post {
            try {
                if (!MediaProjectionService.awaitReady(5000)) {
                    postResult(result) { it.error("SERVICE_FAILED", "Foreground service did not start in time", null) }
                    return@post
                }

                val manager = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                mediaProjection = manager.getMediaProjection(resultCode, intentData)
                if (mediaProjection == null) {
                    postResult(result) { it.error("PROJECTION_FAILED", "Failed to create media projection", null) }
                    return@post
                }

                projectionCallback = object : MediaProjection.Callback() {
                    @Suppress("OVERRIDE_DEPRECATION")
                    override fun onCapturedContentResize(width: Int, height: Int) {}
                    @Suppress("OVERRIDE_DEPRECATION")
                    override fun onCapturedContentVisibilityChanged(isVisible: Boolean) {}
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    mediaProjection!!.registerCallback(projectionCallback!!, backgroundHandler)
                }

                val metrics = activity.resources.displayMetrics
                currentVirtualDisplay = mediaProjection!!.createVirtualDisplay(
                    "ScreenFixCapture",
                    metrics.widthPixels, metrics.heightPixels, metrics.densityDpi,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    null, null, null
                )

                MediaProjectionPermissionHandler.lastResultCode = Activity.RESULT_CANCELED
                MediaProjectionPermissionHandler.lastIntentData = null

                sessionActive = true
                Log.d(TAG, "projection_session_created")
                postResult(result) { it.success(true) }
            } catch (e: Exception) {
                Log.e(TAG, "startProjectionSession: ${e.message}")
                postResult(result) { it.error("SESSION_FAILED", e.message, null) }
            }
        }
    }

    private fun captureScreen(result: MethodChannel.Result) {
        if (!sessionActive || mediaProjection == null) {
            result.error("SESSION_NOT_ACTIVE", "Call startProjectionSession first", null)
            return
        }

        backgroundHandler.post {
            var imageReader: ImageReader? = null
            var captureResultData: Map<String, Any>? = null
            var errorMsg: String? = null
            val captureSyncLatch = CountDownLatch(1)

            try {
                val metrics = activity.resources.displayMetrics
                val width = metrics.widthPixels
                val height = metrics.heightPixels

                imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)

                imageReader.setOnImageAvailableListener({ reader ->
                    try {
                        val image = reader.acquireLatestImage()
                        if (image != null) {
                            try {
                                val pngBytes = imageToPngBytes(image, width, height)
                                val map = HashMap<String, Any>()
                                map["width"] = width
                                map["height"] = height
                                map["bytes"] = pngBytes
                                captureResultData = map
                            } catch (e: Exception) {
                                errorMsg = e.message
                            } finally {
                                image.close()
                            }
                        } else {
                            errorMsg = "No image available from reader"
                        }
                    } finally {
                        try {
                            reader.close()
                        } catch (_: Exception) {}
                        captureSyncLatch.countDown()
                    }
                }, listenerHandler)

                if (currentVirtualDisplay == null) {
                    errorMsg = "VirtualDisplay not created at session start"
                } else {
                    currentVirtualDisplay!!.setSurface(imageReader.surface)
                    val latchReached = captureSyncLatch.await(5, TimeUnit.SECONDS)
                    if (!latchReached) {
                        errorMsg = "Image acquisition timed out after 5 seconds"
                    }
                }

                val finalResult = captureResultData
                val finalError = errorMsg
                postResult(result) {
                    if (finalResult != null) {
                        it.success(finalResult)
                    } else {
                        it.error("CAPTURE_FAILED", finalError ?: "Unknown error", null)
                    }
                }
            } catch (e: SecurityException) {
                val msg = e.message ?: ""
                Log.e(TAG, "captureScreen: SecurityException: $msg")
                if (msg.contains("re-use the resultData") || msg.contains("Reusing token")) {
                    Log.d(TAG, "TOKEN_EXPIRED: MediaProjection token reuse rejected")
                    MediaProjectionPermissionHandler.lastResultCode = Activity.RESULT_CANCELED
                    MediaProjectionPermissionHandler.lastIntentData = null
                    sessionActive = false
                    postResult(result) { it.error("TOKEN_EXPIRED", msg, null) }
                } else {
                    postResult(result) { it.error("SECURITY_EXCEPTION", msg, null) }
                }
            } catch (e: Exception) {
                Log.e(TAG, "captureScreen: ${e.message}")
                postResult(result) { it.error("CAPTURE_FAILED", e.message, null) }
            } finally {
                try {
                    imageReader?.close()
                } catch (_: Exception) {}
            }
        }
    }

    private fun stopProjectionSession(result: MethodChannel.Result) {
        backgroundHandler.post {
            try {
                currentVirtualDisplay?.release()
            } catch (_: Exception) {}
            currentVirtualDisplay = null
            try {
                projectionCallback?.let { cb ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        mediaProjection?.unregisterCallback(cb)
                    }
                }
            } catch (_: Exception) {}
            try {
                mediaProjection?.stop()
                Log.d(TAG, "projection_session_stopped")
            } catch (_: Exception) {}
            try {
                serviceIntent?.let { activity.stopService(it) }
            } catch (_: Exception) {}
            mediaProjection = null
            projectionCallback = null
            serviceIntent = null
            currentVirtualDisplay = null
            sessionActive = false
            postResult(result) { it.success(true) }
        }
    }

    private fun postResult(result: MethodChannel.Result, block: (MethodChannel.Result) -> Unit) {
        Handler(activity.mainLooper).post { block(result) }
    }

    private fun imageToPngBytes(image: android.media.Image, width: Int, height: Int): ByteArray {
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
        if (sessionActive) {
            try { currentVirtualDisplay?.release() } catch (_: Exception) {}
            try { mediaProjection?.stop() } catch (_: Exception) {}
            try { serviceIntent?.let { activity.stopService(it) } } catch (_: Exception) {}
        }
        listenerThread.quitSafely()
        backgroundThread.quitSafely()
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture"
        private const val METHOD_START_SESSION = "startProjectionSession"
        private const val METHOD_CAPTURE = "captureScreen"
        private const val METHOD_STOP_SESSION = "stopProjectionSession"
        private const val TAG = "ScreenFixCapture"
    }
}
