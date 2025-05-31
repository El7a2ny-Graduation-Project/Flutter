import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
