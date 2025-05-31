import 'package:flutter/material.dart';
import 'CPRGuidelinesScreen.dart';
import 'pose_detector_view.dart';
import 'YoloUploadScreen.dart';
import 'CPRGuidelinesScreen.dart';
import 'package:video_player/video_player.dart';

class CPRModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              // Main content column
              Column(
                children: [
                  SizedBox(height: 50),
                  // Logo
                  Image.asset(
                    'assets/images/emergencytrucklogo.png',
                    height: 100,
                  ),
                  SizedBox(height: 20, width: 50),
                  Text(
                    "CPR Mode",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'inter',
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(3, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80),
                  CustomModeButton(
                    imagePath: 'assets/images/book.png',
                    text: 'Education Mode',
                    targetScreen: CPRGuidelinesScreen(),
                  ),
                  SizedBox(height: 30, width: 50),
                  CustomModeButton(
                    imagePath: 'assets/images/live.png',
                    text: 'Live Mode',
                    targetScreen: CameraNativeScreen(),
                  ),
                ],
              ),

              // Back button positioned at the top left
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32.0,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomModeButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Widget targetScreen;

  const CustomModeButton({
    required this.imagePath,
    required this.text,
    required this.targetScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => targetScreen));
      },
      child: Container(
        width: double.infinity, // Make the button stretch to the full width
        margin: EdgeInsets.symmetric(
            horizontal: 40, vertical: 10), // Add margin for spacing
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => targetScreen));
          },
          icon: Image.asset(
            imagePath,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
          ),
          label: Text(
            text,
            style: TextStyle(
              color: Color.fromARGB(255, 153, 40, 40),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(70), // Increase the height
            padding: EdgeInsets.symmetric(vertical: 20), // Adjust padding
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),
    );
  }
}
