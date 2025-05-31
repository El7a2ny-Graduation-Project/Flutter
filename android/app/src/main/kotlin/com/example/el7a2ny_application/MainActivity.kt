package com.example.el7a2ny_application

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "camera_stream_channel"
    private lateinit var cameraStreamService: CameraStreamService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        cameraStreamService = CameraStreamService(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStream" -> {
                    cameraStreamService.startStreaming()
                    result.success("Streaming started")
                }
                "stopStream" -> {
                    cameraStreamService.stopStreaming()
                    result.success("Streaming stopped")
                }
                else -> result.notImplemented()
            }
        }
    }
}