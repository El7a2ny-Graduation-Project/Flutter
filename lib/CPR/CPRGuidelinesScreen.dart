import 'PostureAnalysisScreen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'YoloUploadScreen.dart';
import 'fullscreen_video_player.dart';

class CPRGuidelinesScreen extends StatefulWidget {
  @override
  _CPRGuidelinesScreenState createState() => _CPRGuidelinesScreenState();
}

class _CPRGuidelinesScreenState extends State<CPRGuidelinesScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/CPR_Instructions.mp4')
          ..initialize().then((_) {
            setState(() {});
          });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  Widget buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.red, size: 28),
        label: Text(
          label,
          style: TextStyle(
            color: Color.fromARGB(255, 153, 40, 40),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(70),
          padding: EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showDetailsDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            fontSize: 30,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CPR Educate',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Watch CPR Instructions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _controller.value.isInitialized
                          ? GestureDetector(
                              onTap: _toggleControls,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: VideoPlayer(_controller),
                                    ),
                                  ),
                                  if (_showControls)
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  _formatDuration(_controller
                                                      .value.position),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: SliderTheme(
                                                      data: SliderTheme.of(
                                                              context)
                                                          .copyWith(
                                                        activeTrackColor:
                                                            Colors.white,
                                                        inactiveTrackColor:
                                                            Colors.white54,
                                                        thumbColor:
                                                            Colors.white,
                                                        thumbShape:
                                                            RoundSliderThumbShape(
                                                                enabledThumbRadius:
                                                                    6),
                                                        trackHeight: 2,
                                                      ),
                                                      child: Slider(
                                                        min: 0.0,
                                                        max: _controller
                                                            .value
                                                            .duration
                                                            .inMilliseconds
                                                            .toDouble(),
                                                        value: _controller
                                                            .value
                                                            .position
                                                            .inMilliseconds
                                                            .clamp(
                                                              0,
                                                              _controller
                                                                  .value
                                                                  .duration
                                                                  .inMilliseconds,
                                                            )
                                                            .toDouble(),
                                                        onChanged: (value) {
                                                          _controller.seekTo(
                                                              Duration(
                                                                  milliseconds:
                                                                      value
                                                                          .toInt()));
                                                          _startHideTimer();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _formatDuration(_controller
                                                      .value.duration),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  _controller.value.isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _controller.value.isPlaying
                                                        ? _controller.pause()
                                                        : _controller.play();
                                                  });
                                                  _startHideTimer();
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _isFullScreen
                                                      ? Icons.fullscreen_exit
                                                      : Icons.fullscreen,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  _toggleFullScreen();
                                                  if (_isFullScreen) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FullScreenVideoPlayer(
                                                          controller:
                                                              _controller,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Container(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                    ),
                    buildActionButton("Compression Rate", Icons.favorite, () {
                      _showDetailsDialog("Compression Rate",
                          "Perform chest compressions at a rate of 100 to 120 per minute.");
                    }),
                    buildActionButton("Compression Depth", Icons.height, () {
                      _showDetailsDialog("Compression Depth",
                          "Compress the chest at least 2 inches (5 cm) deep.");
                    }),
                    buildActionButton("Posture Common Errors", Icons.warning,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostureAnalysisScreen(),
                        ),
                      );
                    }),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YoloUploadScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.upload, color: Colors.white),
                    label: Text(
                      'Upload CPR Video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
