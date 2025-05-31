import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ResultScreen.dart';

class YoloUploadScreen extends StatefulWidget {
  @override
  State<YoloUploadScreen> createState() => _YoloUploadScreenState();
}

class _YoloUploadScreenState extends State<YoloUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedVideo;
  bool _isLoading = false;
  VideoPlayerController? _videoPlayerController;
  bool _videoReady = false;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUrl = prefs.getString('base_url');
    if (storedUrl != null && storedUrl.isNotEmpty) {
      setState(() {
        _baseUrl = storedUrl;
      });
    }
  }

  Future<Map<String, dynamic>?> _sendVideoToBackend(File videoFile) async {
    if (_baseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Base URL not set. Please configure it from home screen.'),
      ));
      return null;
    }

    final uri = Uri.parse('$_baseUrl/process_video');
    print('Sending video to: $uri');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      videoFile.path,
      contentType: MediaType('video', 'mp4'),
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _isLoading = true;
        _videoReady = false;
      });

      final response = await _sendVideoToBackend(_selectedVideo!);

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {
              _videoReady = true;
            });
          });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              chunks: response['chunks'],
              videoUrl: response['videoURL'],
              graphURL: response['graphURL'],
              warnings: response['warnings'],
            ),
          ),
        );
      }

      print('Selected video path: ${_selectedVideo!.path}');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Upload'),
        backgroundColor: Colors.red.shade400,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_videoReady &&
                        _videoPlayerController != null &&
                        _videoPlayerController!.value.isInitialized)
                      GestureDetector(
                        onTap: () {
                          if (_videoPlayerController!.value.isPlaying) {
                            _videoPlayerController!.pause();
                          } else {
                            _videoPlayerController!.play();
                          }
                          setState(() {});
                        },
                        child: AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickVideo(ImageSource.camera),
                            icon: Icon(Icons.videocam, color: Colors.white),
                            label: Text(
                              'Capture Video',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade300,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickVideo(ImageSource.gallery),
                            icon:
                                Icon(Icons.video_library, color: Colors.white),
                            label: Text(
                              'Choose from Gallery',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade300,
                            ),
                          ),
                        ],
                      ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Center(
                          child: Lottie.asset(
                              'assets/animations/loadingIndicator.json'),
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
