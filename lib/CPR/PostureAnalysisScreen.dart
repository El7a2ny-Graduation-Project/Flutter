import 'package:flutter/material.dart';

class PostureAnalysisScreen extends StatelessWidget {
  const PostureAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of posture errors, including title, description, and image.
    final List<Map<String, String>> postureErrors = [
      {
        'title': 'One Arm Only',
        'description':
            'Using one arm reduces compression depth and effectiveness.',
        'image': 'assets/images/one-arm.png',
      },
      {
        'title': 'Bent Arms',
        'description':
            'Arms should be straight to apply proper chest compressions.',
        'image': 'assets/images/arms_bent.png',
      },
      {
        'title': 'Incorrect Hand Placement',
        'description':
            'Hands must be centered on the chest to avoid injury and ensure efficiency.',
        'image': 'assets/images/misplacement.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Analysis'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: postureErrors.length,
          itemBuilder: (context, index) {
            final error = postureErrors[index];

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.red[50],
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the posture error image without cropping
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        error['image']!,
                        height: 180, // Adjust this to fit the space you want
                        width: double.infinity,
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to avoid cropping
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display the title of the error
                    Text(
                      error['title']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    // Display the description of the error
                    Text(
                      error['description']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
