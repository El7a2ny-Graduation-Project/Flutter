package com.example.el7a2ny_application

import android.content.Context
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.hardware.camera2.*
import android.media.Image
import android.media.ImageReader
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import java.io.ByteArrayOutputStream
import java.io.OutputStream
import java.net.ServerSocket
import java.net.Socket
import java.util.concurrent.CopyOnWriteArrayList

class CameraStreamService(private val context: Context) {
    companion object 
    {
        private const val TAG = "CameraStreamService"
        private const val PORT = 8080
        private const val WIDTH = 640
        private const val HEIGHT = 480
        private const val JPEG_QUALITY = 100
    }

    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null
    private var serverSocket: ServerSocket? = null

    // Thread-safe list to hold all client sockets output streams
    private val clientOutputs = CopyOnWriteArrayList<OutputStream>()

    @Volatile
    private var isStreaming = false

    private lateinit var backgroundThread: HandlerThread
    private lateinit var backgroundHandler: Handler

    private lateinit var serverThread: Thread

    fun startStreaming() {
        if (isStreaming) return
        isStreaming = true

        startBackgroundThread()

        serverThread = Thread {
            try {
                Log.i(TAG, "Starting MJPEG server on port $PORT")
                serverSocket = ServerSocket(PORT)
                while (isStreaming) {
                    val socket = serverSocket!!.accept()
                    Log.i(TAG, "Client connected: ${socket.inetAddress.hostAddress}")
                    handleClient(socket)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in server thread", e)
                stopStreaming()
            }
        }
        serverThread.start()

        openCamera()
    }

    fun stopStreaming() {
        isStreaming = false

        try {
            serverSocket?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing server socket", e)
        }
        serverSocket = null

        // Close all client output streams
        for (output in clientOutputs) {
            try {
                output.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error closing client output", e)
            }
        }
        clientOutputs.clear()

        closeCamera()
        stopBackgroundThread()

        if (::serverThread.isInitialized) {
            serverThread.interrupt()
        }

        Log.i(TAG, "Streaming stopped")
    }

    private fun startBackgroundThread() {
        backgroundThread = HandlerThread("CameraBackground").also { it.start() }
        backgroundHandler = Handler(backgroundThread.looper)
    }

    private fun stopBackgroundThread() {
        try {
            backgroundThread.quitSafely()
            backgroundThread.join()
        } catch (e: InterruptedException) {
            Log.e(TAG, "Error stopping background thread", e)
        }
    }

    private fun handleClient(socket: Socket) {
        Thread {
            try {
                val output = socket.getOutputStream()
                // Send initial HTTP headers for MJPEG streaming
                output.write("HTTP/1.0 200 OK\r\n".toByteArray())
                output.write("Content-Type: multipart/x-mixed-replace; boundary=frame\r\n\r\n".toByteArray())
                output.flush()

                clientOutputs.add(output)

                // Keep socket open until client disconnects
                while (isStreaming && !socket.isClosed) {
                    try {
                        Thread.sleep(1000)
                    } catch (e: InterruptedException) {
                        break
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, "Client connection error", e)
            } finally {
                try {
                    clientOutputs.removeIf { it == socket.getOutputStream() }
                    socket.close()
                    Log.i(TAG, "Client disconnected")
                } catch (e: Exception) {
                    Log.e(TAG, "Error closing client socket", e)
                }
            }
        }.start()
    }

    private fun openCamera() {
        val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        try {
            // Choose the first back-facing camera
            val cameraId = manager.cameraIdList.firstOrNull { id ->
                val characteristics = manager.getCameraCharacteristics(id)
                val facing = characteristics.get(CameraCharacteristics.LENS_FACING)
                facing == CameraCharacteristics.LENS_FACING_BACK
            } ?: manager.cameraIdList[0]

            // Setup ImageReader
            imageReader = ImageReader.newInstance(WIDTH, HEIGHT, ImageFormat.YUV_420_888, 2)
            imageReader?.setOnImageAvailableListener({ reader ->
                val image = reader.acquireLatestImage() ?: return@setOnImageAvailableListener
                try {
                    val jpegData = yuvImageToJpeg(image)
                    image.close()

                    val frameHeader = "--frame\r\nContent-Type: image/jpeg\r\nContent-Length: ${jpegData.size}\r\n\r\n".toByteArray()

                    // Send frame to all clients
                    val deadClients = mutableListOf<OutputStream>()
                    for (output in clientOutputs) {
                        try {
                            output.write(frameHeader)
                            output.write(jpegData)
                            output.write("\r\n\r\n".toByteArray())
                            output.flush()
                        } catch (e: Exception) {
                            Log.e(TAG, "Error sending frame to client", e)
                            deadClients.add(output)
                        }
                    }
                    // Remove dead clients
                    clientOutputs.removeAll(deadClients)

                } catch (e: Exception) {
                    image.close()
                    Log.e(TAG, "Error processing image", e)
                }
            }, backgroundHandler)

            // Open camera device
            manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    Log.i(TAG, "Camera opened")
                    cameraDevice = camera
                    createCaptureSession()
                }

                override fun onDisconnected(camera: CameraDevice) {
                    Log.i(TAG, "Camera disconnected")
                    stopStreaming()
                }

                override fun onError(camera: CameraDevice, error: Int) {
                    Log.e(TAG, "Camera error: $error")
                    stopStreaming()
                }
            }, backgroundHandler)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to open camera", e)
            stopStreaming()
        }
    }

    private fun createCaptureSession() {
        val camera = cameraDevice ?: return
        val readerSurface = imageReader?.surface ?: return

        try {
            camera.createCaptureSession(
                listOf(readerSurface),
                object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(session: CameraCaptureSession) {
                        captureSession = session
                        try {
                            val captureRequestBuilder = camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
                            captureRequestBuilder.addTarget(readerSurface)
                            captureRequestBuilder.set(CaptureRequest.CONTROL_MODE, CaptureRequest.CONTROL_MODE_AUTO)
                            val request = captureRequestBuilder.build()

                            session.setRepeatingRequest(request, null, backgroundHandler)
                            Log.i(TAG, "Camera preview started")
                        } catch (e: CameraAccessException) {
                            Log.e(TAG, "Failed to start camera preview", e)
                        }
                    }

                    override fun onConfigureFailed(session: CameraCaptureSession) {
                        Log.e(TAG, "Camera configure failed")
                        stopStreaming()
                    }
                }, backgroundHandler
            )
        } catch (e: CameraAccessException) {
            Log.e(TAG, "Failed to create capture session", e)
        }
    }

    private fun closeCamera() {
        captureSession?.close()
        captureSession = null

        cameraDevice?.close()
        cameraDevice = null

        imageReader?.close()
        imageReader = null
    }

    private fun yuvImageToJpeg(image: Image): ByteArray {
        val nv21 = yuv420888ToNv21(image)
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, image.width, image.height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, image.width, image.height), JPEG_QUALITY, out)
        return out.toByteArray()
    }

    private fun yuv420888ToNv21(image: Image): ByteArray {
        val width = image.width
        val height = image.height
        val ySize = width * height
        val uvSize = width * height / 4

        val nv21 = ByteArray(ySize + uvSize * 2)

        val yBuffer = image.planes[0].buffer // Y
        val uBuffer = image.planes[1].buffer // U
        val vBuffer = image.planes[2].buffer // V

        // Copy Y
        yBuffer.get(nv21, 0, ySize)
        var pos = ySize

        val rowStride = image.planes[2].rowStride
        val pixelStride = image.planes[2].pixelStride

        val vBufferPos = vBuffer.position()
        val uBufferPos = uBuffer.position()

        for (row in 0 until height / 2) {
            for (col in 0 until width / 2) {
                val vIndex = row * rowStride + col * pixelStride
                val uIndex = row * image.planes[1].rowStride + col * image.planes[1].pixelStride
                nv21[pos++] = vBuffer.get(vIndex)
                nv21[pos++] = uBuffer.get(uIndex)
            }
        }

        vBuffer.position(vBufferPos)
        uBuffer.position(uBufferPos)

        return nv21
    }
}
