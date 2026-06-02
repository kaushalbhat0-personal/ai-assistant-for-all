package com.screenfix.ai

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
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

    private fun captureScreen(result: MethodChannel.Result) {
        Log.d(TAG, "captureScreen: start")
        val resultCode = MediaProjectionPermissionHandler.lastResultCode
        val intentData = MediaProjectionPermissionHandler.lastIntentData
        Log.d(TAG, "captureScreen: resultCode=$resultCode intentData=${if (intentData != null) "non-null" else "NULL"}")

        // Clear static fields so they cannot be reused on subsequent captures
        MediaProjectionPermissionHandler.lastResultCode = Activity.RESULT_CANCELED
        MediaProjectionPermissionHandler.lastIntentData = null

        if (intentData == null || resultCode != Activity.RESULT_OK) {
            Log.d(TAG, "captureScreen: permission check -> NULL")
            result.error(
                "PERMISSION_DENIED",
                "MediaProjection permission not granted",
                null
            )
            return
        }
        Log.d(TAG, "captureScreen: permission check -> SUCCESS")

        // Start foreground service (required for Android 14+ MediaProjection)
        Log.d(TAG, "captureScreen: starting foreground service")
        MediaProjectionService.reset()
        val serviceIntent = Intent(activity, MediaProjectionService::class.java)
        ContextCompat.startForegroundService(activity, serviceIntent)

        // Move capture to background thread (awaitReady blocks)
        backgroundHandler.post {
            var mediaProjection: android.media.projection.MediaProjection? = null
            var imageReader: ImageReader? = null
            var virtualDisplay: android.hardware.display.VirtualDisplay? = null
            var projectionCallback: android.media.projection.MediaProjection.Callback? = null
            var captureResult: Map<String, Any>? = null
            var errorCode: String? = null
            var errorMessage: String? = null
            try {
                Log.d(TAG, "captureScreen: awaiting foreground service ready")
                if (!MediaProjectionService.awaitReady(5000)) {
                    Log.d(TAG, "captureScreen: foreground service timeout")
                    errorCode = "SERVICE_FAILED"
                    errorMessage = "Foreground service did not start in time"
                    return@post
                }
                Log.d(TAG, "captureScreen: foreground service ready")

                val manager =
                    activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                            as MediaProjectionManager
                mediaProjection = manager.getMediaProjection(resultCode, intentData)
                Log.d(TAG, "projection_created -> ${if (mediaProjection != null) "SUCCESS" else "NULL"}")

                if (mediaProjection == null) {
                    errorCode = "PROJECTION_FAILED"
                    errorMessage = "Failed to create media projection"
                    return@post
                }

                Log.d(TAG, "captureScreen: registering MediaProjection.Callback")
                projectionCallback = object : android.media.projection.MediaProjection.Callback() {
                    override fun onStop() {
                        Log.d(TAG, "MediaProjection.Callback.onStop invoked isRunning=${mediaProjection != null}")
                    }
                    @Suppress("OVERRIDE_DEPRECATION")
                    override fun onCapturedContentResize(width: Int, height: Int) {
                        Log.d(TAG, "captureScreen: MediaProjection.Callback.onCapturedContentResize width=$width height=$height")
                    }
                    @Suppress("OVERRIDE_DEPRECATION")
                    override fun onCapturedContentVisibilityChanged(isVisible: Boolean) {
                        Log.d(TAG, "captureScreen: MediaProjection.Callback.onCapturedContentVisibilityChanged visible=$isVisible")
                    }
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    mediaProjection.registerCallback(projectionCallback, backgroundHandler)
                }

                val metrics = activity.resources.displayMetrics
                val width = metrics.widthPixels
                val height = metrics.heightPixels
                val density = metrics.densityDpi
                Log.d(TAG, "capture_width=$width")
                Log.d(TAG, "capture_height=$height")
                Log.d(TAG, "capture_density=$density")

                imageReader = ImageReader.newInstance(
                    width, height, PixelFormat.RGBA_8888, 2
                )
                Log.d(TAG, "image_reader_created width=$width height=$height format=RGBA_8888")

                // Use a separate handler to avoid deadlock:
                // backgroundHandler blocks on latch.await() 
                // listenerHandler is free to dispatch ImageReader callbacks
                val captureSyncLatch = CountDownLatch(1)
                var internalCaptureResult: Map<String, Any>? = null
                var internalCaptureError: String? = null

                imageReader.setOnImageAvailableListener({ reader ->
                    try {
                        val image = reader.acquireLatestImage()
                        val got = if (image != null) "SUCCESS" else "NULL"
                        Log.d(TAG, "first_frame_received=$got")
                        Log.d(TAG, "image_acquired -> $got")

                        if (image != null) {
                            try {
                                val pngBytes = imageToPngBytes(image, width, height)
                                val map = HashMap<String, Any>()
                                map["width"] = width
                                map["height"] = height
                                map["bytes"] = pngBytes
                                Log.d(TAG, "captureScreen: SUCCESS width=$width height=$height bytes=${pngBytes.size}")
                                internalCaptureResult = map
                            } catch (e: Exception) {
                                Log.d(TAG, "captureScreen: imageToPngBytes exception: ${e.message}")
                                internalCaptureError = e.message
                            } finally {
                                image.close()
                            }
                        } else {
                            Log.d(TAG, "captureScreen: acquireLatestImage -> NULL")
                            internalCaptureError = "No image available from reader"
                        }
                    } finally {
                        captureSyncLatch.countDown()
                    }
                }, listenerHandler)
                Log.d(TAG, "listener_registered")

                virtualDisplay = mediaProjection.createVirtualDisplay(
                    "ScreenFixCapture",
                    width, height, density,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    imageReader.surface, null, null
                )
                Log.d(TAG, "virtual_display_created -> ${if (virtualDisplay != null) "SUCCESS" else "NULL"}")

                if (virtualDisplay == null) {
                    Log.d(TAG, "captureScreen: virtual display is NULL")
                    errorCode = "DISPLAY_FAILED"
                    errorMessage = "Failed to create virtual display"
                    return@post
                }

                val latchReached = captureSyncLatch.await(5, TimeUnit.SECONDS)
                if (!latchReached) {
                    Log.d(TAG, "captureScreen: captureSyncLatch timed out after 5s")
                    internalCaptureError = "Image acquisition timed out after 5 seconds"
                }

                captureResult = internalCaptureResult
                if (captureResult != null) {
                    Log.d(TAG, "capture_success")
                } else {
                    errorCode = "CAPTURE_FAILED"
                    errorMessage = internalCaptureError ?: "Unknown capture error"
                }
            } catch (e: SecurityException) {
                Log.d(TAG, "captureScreen: SecurityException: ${e.message}")
                errorCode = "SECURITY_EXCEPTION"
                errorMessage = e.message
            } catch (e: Exception) {
                Log.d(TAG, "captureScreen: exception: ${e.message}")
                errorCode = "CAPTURE_FAILED"
                errorMessage = e.message
            } finally {
                // Post result + cleanup to main thread (required by Flutter and Android framework APIs)
                val finalCode = errorCode
                val finalMessage = errorMessage
                Handler(activity.mainLooper).post {
                    try {
                        if (captureResult != null) {
                            result.success(captureResult)
                        } else {
                            result.error(finalCode ?: "UNKNOWN", finalMessage ?: "Unknown error", null)
                        }
                    } finally {
                        Log.d(TAG, "projection_cleanup: start")
                        try {
                            projectionCallback?.let { cb ->
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                    mediaProjection?.unregisterCallback(cb)
                                }
                            }
                        } catch (e: Exception) {
                            Log.d(TAG, "projection_cleanup: unregisterCallback exception: ${e.message}")
                        }
                        try {
                            virtualDisplay?.release()
                        } catch (e: Exception) {
                            Log.d(TAG, "projection_cleanup: virtualDisplay.release exception: ${e.message}")
                        }
                        Log.d(TAG, "captureScreen: virtualDisplay released")
                        try {
                            imageReader?.close()
                        } catch (e: Exception) {
                            Log.d(TAG, "projection_cleanup: imageReader.close exception: ${e.message}")
                        }
                        Log.d(TAG, "captureScreen: imageReader closed")
                        Log.d(TAG, "before_projection_stop")
                        try {
                            mediaProjection?.stop()
                        } catch (e: Exception) {
                            Log.d(TAG, "projection_cleanup: mediaProjection.stop exception: ${e.message}")
                        }
                        Log.d(TAG, "after_projection_stop")
                        Log.d(TAG, "before_service_stop")
                        try {
                            activity.stopService(serviceIntent)
                        } catch (e: Exception) {
                            Log.d(TAG, "service_stop: exception: ${e.message}")
                        }
                        Log.d(TAG, "after_service_stop")
                        Log.d(TAG, "captureScreen: cleanup complete")
                    }
                }
            }
        }
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
        listenerThread.quitSafely()
        backgroundThread.quitSafely()
    }

    companion object {
        private const val CHANNEL_NAME = "screenfix_ai/screen_capture"
        private const val METHOD_CAPTURE = "captureScreen"
        private const val TAG = "ScreenFixCapture"
    }
}
