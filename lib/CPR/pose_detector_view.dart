import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraNativeScreen extends StatefulWidget {
  const CameraNativeScreen({Key? key}) : super(key: key);

  @override
  State<CameraNativeScreen> createState() => _CameraNativeScreenState();
}

class _CameraNativeScreenState extends State<CameraNativeScreen> {
  static const platform = MethodChannel('camera_stream_channel');
  bool _isStreaming = false;
  bool _cameraGranted = false;
  bool _showUI = false;
  bool _showIntroImage = false;

  String? _deviceIp;
  String get streamUrl => 'http://${_deviceIp ?? '192.168.1.16'}:8080/video';

  String _latestMessage = '';
  ReceivePort? _receivePort;
  Isolate? _isolate;

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _introPlayer = AudioPlayer();
  final AudioPlayer _beatPlayer = AudioPlayer();

  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _getDeviceIp();
    _startSequence();
  }

  @override
  void dispose() {
    _resetAll();
    super.dispose();
  }

  Future<String?> _getDeviceIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('eth')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
              return addr.address;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting IP address: $e');
      return null;
    }
  }

  Future<void> _getDeviceIp() async {
    final ip = await _getDeviceIpAddress();
    setState(() {
      _deviceIp = ip;
    });
  }

  Future<void> _startSequence() async {
    await _requestCameraPermission();
    if (_cameraGranted) {
      setState(() => _showIntroImage = true);
      await _playIntroAudio();
      setState(() => _showIntroImage = false);
      await _showCountdownAndStart();
      await _playBeatAudio();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _cameraGranted = true);
    }
  }

  Future<void> _playIntroAudio() async {
    try {
      await _introPlayer.setAsset('assets/audio/RealTimeBegin.mp3');
      await _introPlayer.play();
      await _introPlayer.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed);
    } catch (e) {
      print('Intro audio error: $e');
    }
  }

  Future<void> _showCountdownAndStart() async {
    for (var i = 3; i >= 1; i--) {
      setState(() => _latestMessage = '$i');
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => _latestMessage = '');
    await _startNativeStream();
    await _startWebSocketListener();
    setState(() => _showUI = true);
  }

  Future<void> _startNativeStream() async {
    try {
      await platform.invokeMethod('startStream');
      setState(() => _isStreaming = true);
    } on PlatformException catch (e) {
      print("Failed to start stream: '${e.message}'");
    }
  }

  Future<void> _stopNativeStream() async {
    try {
      await platform.invokeMethod('stopStream');
      setState(() => _isStreaming = false);
      await _beatPlayer.stop();
      _isolate?.kill(priority: Isolate.immediate);
      _receivePort?.close();
    } on PlatformException catch (e) {
      print("Failed to stop stream: '${e.message}'");
    }
  }

  Future<void> _playBeatAudio() async {
    try {
      await _beatPlayer.setAsset('assets/audio/cpr_beat_110bpm_click.wav');
      _beatPlayer.setLoopMode(LoopMode.one);
      await _beatPlayer.play();
    } catch (e) {
      print('Beat audio error: $e');
    }
  }

  Future<void> _pauseBeat() async {
    if (_beatPlayer.playing) await _beatPlayer.pause();
  }

  Future<void> _resumeBeat() async {
    if (!_beatPlayer.playing && !_isSpeaking) await _beatPlayer.play();
  }

  Future<void> _speakInstruction(String text) async {
    _isSpeaking = true;
    await _pauseBeat();
    await _flutterTts.speak(text);
    await _flutterTts.awaitSpeakCompletion(true);
    _isSpeaking = false;
    await _resumeBeat();
  }

  Future<void> _startWebSocketListener() async {
    _receivePort = ReceivePort();
    final token = RootIsolateToken.instance!;

    _isolate = await Isolate.spawn(
      _webSocketIsolate,
      [
        _receivePort!.sendPort,
        token,
        streamUrl
      ], // Pass streamUrl as third parameter
      debugName: 'WebSocketIsolate',
    );

    _receivePort!.listen((data) async {
      print('WebSocket message received: $data');
      try {
        final Map<String, dynamic> msg = json.decode(data.toString());

        List<String> parseWarnings(dynamic val) {
          if (val == null) return [];
          if (val is List) return val.whereType<String>().toList();
          if (val is String) {
            final trimmed = val.trim();
            if (trimmed.isEmpty || trimmed == '[]') return [];
            final clean = trimmed.replaceAll(RegExp(r'[\[\]]'), '');
            return clean
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return [];
        }

        final postureWarnings = parseWarnings(msg['posture_warnings']);
        final rateDepthWarnings = parseWarnings(msg['rate_and_depth_warnings']);

        final allWarnings = [...postureWarnings, ...rateDepthWarnings];

        final displayMessage =
            allWarnings.isEmpty ? 'OK' : 'Warning: ' + allWarnings.join(' ');

        setState(() {
          _latestMessage = displayMessage;
        });

        if (postureWarnings.isNotEmpty) {
          await _speakInstruction(postureWarnings.join(' '));
        }
        if (rateDepthWarnings.isNotEmpty) {
          await _speakInstruction(rateDepthWarnings.join(' '));
        }
      } catch (e) {
        print('WebSocket parse error: $e');
      }
    });
  }

  static void _webSocketIsolate(List<dynamic> args) async {
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken;
    final streamUrl = args[2] as String; // Get the stream URL

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('base_url') ?? '192.168.1.113:8000';

    final cleanUrl = baseUrl.replaceAll(RegExp(r'^https?://'), '');
    final wsUrl = 'ws://$cleanUrl/ws/real';

    print('Connecting to WebSocket at $wsUrl');
    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Send the stream URL as the first message
      channel.sink.add(streamUrl);

      await for (final message in channel.stream) {
        sendPort.send(message);
      }
    } catch (e) {
      sendPort.send("WebSocket error: $e");
    }
  }

  Future<void> _resetAll() async {
    print('Resetting all...');
    try {
      await _beatPlayer.stop();
      await _introPlayer.stop();
      await _flutterTts.stop();
      await _stopNativeStream();
      _latestMessage = '';
      _isStreaming = false;
      _showUI = false;
      _showIntroImage = false;
      setState(() {});
    } catch (e) {
      print('Error resetting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _resetAll();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 47, 47),
                Color.fromARGB(255, 231, 131, 131),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: _cameraGranted
                ? _showUI
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: Icon(
                                _isStreaming ? Icons.stop : Icons.play_arrow),
                            label: Text(_isStreaming
                                ? 'Stop Live CPR'
                                : 'Start Live CPR'),
                            onPressed: _isStreaming
                                ? _stopNativeStream
                                : () async {
                                    await _startNativeStream();
                                    await _startWebSocketListener();
                                  },
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                backgroundColor:
                                    _isStreaming ? Colors.red : Colors.green,
                                foregroundColor: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _latestMessage,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          _isStreaming
                              ? Expanded(
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: MJPEGStreamScreen(
                                      streamUrl: streamUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                      showLiveIcon: false,
                                    ),
                                  ),
                                )
                              : const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Camera is not streaming.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                        ],
                      )
                    : _showIntroImage
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Position yourself like this and start performing the CPR',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Image.asset(
                                'assets/images/CPR_Start_New.png',
                                width: MediaQuery.of(context).size.width * 0.9,
                                fit: BoxFit.contain,
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              _latestMessage,
                              style: const TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          )
                : const Center(
                    child: Text(
                      'Camera permission denied. Please enable it in settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
