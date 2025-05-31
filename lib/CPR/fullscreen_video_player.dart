import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({Key? key, required this.controller})
      : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isPortrait = true;
  bool _isSliding = false;
  double _currentSliderValue = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Initialize slider value
    _currentSliderValue =
        widget.controller.value.position.inMilliseconds.toDouble();

    // Add listener to update slider as video plays
    widget.controller.addListener(_updateSlider);
    _startHideTimer();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    widget.controller.removeListener(_updateSlider);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _updateSlider() {
    if (!_isSliding && mounted) {
      setState(() {
        _currentSliderValue =
            widget.controller.value.position.inMilliseconds.toDouble();
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
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

  void _toggleOrientation() {
    if (_isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    setState(() {
      _isPortrait = !_isPortrait;
    });
    _startHideTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
          ),

          // Back button
          if (_showControls)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),

          // Video controls overlay
          if (_showControls)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(widget.controller.value.position),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white54,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6),
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: widget.controller.value.duration
                                        .inMilliseconds
                                        .toDouble(),
                                    value: _currentSliderValue,
                                    onChangeStart: (value) {
                                      setState(() {
                                        _isSliding = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _currentSliderValue = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      widget.controller.seekTo(Duration(
                                          milliseconds: value.toInt()));
                                      setState(() {
                                        _isSliding = false;
                                      });
                                      _startHideTimer();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(widget.controller.value.duration),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.controller.value.isPlaying
                                    ? widget.controller.pause()
                                    : widget.controller.play();
                              });
                              _startHideTimer();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _isPortrait
                                  ? Icons.fullscreen
                                  : Icons.fullscreen_exit,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _toggleOrientation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
