import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChunkListScreen extends StatelessWidget {
  final List<dynamic> chunks;
  final List<dynamic> warnings;

  const ChunkListScreen({
    super.key,
    required this.chunks,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chunk Analysis")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: chunks.length,
        itemBuilder: (context, index) {
          final chunk = chunks[index];
          double averageScore = chunk['depth'];

          return Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chunk ${index + 1} - Start: ${chunk['start']}s, End: ${chunk['end']}s',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  _buildRateAndDepth(chunk),
                  SizedBox(height: 10),
                  if (chunk['screenshot_url'] != null)
                    _buildImage(chunk['screenshot_url']),
                  SizedBox(height: 20),
                  _buildAnimationForScore(averageScore),
                  if (warnings.isNotEmpty) ..._buildWarnings(warnings),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRateAndDepth(dynamic chunk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rate: ${chunk['rate']} compressions/min",
            style: TextStyle(fontSize: 14)),
        Text("Depth: ${chunk['depth']} cm", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
      ),
    );
  }

  Widget _buildAnimationForScore(double averageScore) {
    return Lottie.asset(
      averageScore >= 4.0
          ? 'assets/animations/excellent.json'
          : averageScore >= 3.8
              ? 'assets/animations/good.json'
              : 'assets/animations/poor.json',
      width: 100,
      height: 100,
    );
  }

  List<Widget> _buildWarnings(List<dynamic> warnings) {
    return warnings.map((warning) {
      return Card(
        color: Colors.red.shade100,
        margin: EdgeInsets.only(top: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            warning['description'] ?? "Unknown Warning",
            style: TextStyle(
                color: Colors.red.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }
}
