import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import 'package:video_player/video_player.dart';
import 'CPRGuidelinesScreen.dart';
import 'fullscreen_video_player.dart';

class CustomButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Widget viewPage;
  final double width;

  const CustomButton({
    required this.imagePath,
    required this.text,
    required this.viewPage,
    this.width = 320,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => viewPage));
      },
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 Center the Row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 254, 254, 254),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              // 👈 Make text take remaining space
              child: Text(
                text,
                textAlign: TextAlign.center, // 👈 Center the text itself
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(221, 153, 40, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final List<dynamic> chunks;
  final List<dynamic> warnings;
  final String videoUrl;
  final String graphURL;

  const ResultScreen({
    super.key,
    required this.chunks,
    required this.warnings,
    required this.videoUrl,
    required this.graphURL,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CPR Analysis Results"),
        backgroundColor: Colors.red.shade400,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Recommended Standards"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("✔️ Depth: 5–6 cm"),
                      Text("✔️ Rate: 100–120 compressions/min"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text("OK", style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text("Go to Detailed View",
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CPRGuidelinesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 47, 47),
                Color.fromARGB(255, 231, 131, 131)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                imagePath: 'assets/images/summary.png',
                text: 'Process Chunks',
                viewPage: ChunkListScreen(
                  chunks: chunks,
                  warnings: warnings,
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                imagePath: 'assets/images/analysis.png',
                text: 'View Video',
                viewPage: FullscreenVideoWrapper(videoUrl: videoUrl),
              ),
              SizedBox(height: 20),
              CustomButton(
                imagePath: 'assets/images/graph.png',
                text: 'Check Graph',
                viewPage: GraphViewerScreen(graphUrl: graphURL),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChunkListScreen extends StatefulWidget {
  final List<dynamic> chunks;
  final List<dynamic> warnings;

  const ChunkListScreen(
      {super.key, required this.chunks, required this.warnings});

  @override
  State<ChunkListScreen> createState() => _ChunkListScreenState();
}

class _ChunkListScreenState extends State<ChunkListScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chunk and Warning Details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("⚙️ Chunk Segments:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              // Display each chunk as a ListTile
              ...widget.chunks.asMap().entries.map((entry) {
                int index = entry.key;
                var chunk = entry.value;
                return GestureDetector(
                  onTap: () {
                    // Navigate to ChunkDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChunkDetailsScreen(chunk: {
                          'index': index,
                          'start': chunk['start'],
                          'end': chunk['end'],
                          'rate': chunk['rate'],
                          'depth': chunk['depth'],
                        }),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text("Chunk ${index + 1}"),
                      subtitle: Text(
                          "Start: ${chunk['start']}s, End: ${chunk['end']}s"),
                    ),
                  ),
                );
              }).toList(),

              SizedBox(height: 30),
              // Posture warnings section
              Text("❌ Posture Warnings:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              // If no warnings, display a message
              if (widget.warnings.isEmpty)
                Text("No warnings found.")
              else
                // Display each warning with image and description
                ...widget.warnings.map((warning) {
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Display warning image if available
                        if (warning['image_url'] != null)
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              warning['image_url'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.9,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            warning['description'] ?? "Unknown Warning",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChunkDetailsScreen extends StatelessWidget {
  final dynamic chunk;

  const ChunkDetailsScreen({super.key, required this.chunk});

  @override
  Widget build(BuildContext context) {
    double rate = chunk['rate'].toDouble(); // compressions per minute
    double depth = chunk['depth'].toDouble(); // depth in cm

    // Rate scoring logic
    double rateScore;
    if (rate >= 100 && rate <= 120) {
      rateScore = 100;
    } else if (rate >= 90 && rate <= 130) {
      rateScore = 90;
    } else {
      rateScore = 40;
    }

    // Depth scoring logic
    double depthScore;
    if (depth >= 5 && depth <= 6) {
      depthScore = 100;
    } else if (depth >= 4.8 && depth <= 6.5) {
      depthScore = 90;
    } else {
      depthScore = 40;
    }

    double averageScore = (rateScore + depthScore) / 2;

    String animationPath;
    if (averageScore > 80) {
      animationPath = 'assets/animations/star.json';
    } else if (averageScore > 50) {
      animationPath = 'assets/animations/good.json';
    } else {
      animationPath = 'assets/animations/poor.json';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chunk Details'),
        backgroundColor: Colors.red.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Lottie.asset(animationPath, height: 200)),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Average Score: ${averageScore.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Rate: ${rate.toStringAsFixed(2)} compressions/min',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Depth: ${depth.toStringAsFixed(2)} cm',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GraphViewerScreen extends StatelessWidget {
  final String graphUrl;

  const GraphViewerScreen({super.key, required this.graphUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graph Analysis'),
        backgroundColor: Colors.red.shade400,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            graphUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) =>
                Text('Failed to load graph image'),
          ),
        ),
      ),
    );
  }
}

class FullscreenVideoWrapper extends StatefulWidget {
  final String videoUrl;

  const FullscreenVideoWrapper({super.key, required this.videoUrl});

  @override
  State<FullscreenVideoWrapper> createState() => _FullscreenVideoWrapperState();
}

class _FullscreenVideoWrapperState extends State<FullscreenVideoWrapper> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? FullScreenVideoPlayer(controller: _controller)
        : Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
  }
}
