import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'CPR/YoloUploadScreen.dart';
import 'CPR/pose_detector_view.dart';
import 'burns/burncamera.dart';
import 'burns/firstdegree.dart';
import 'burns/thirddegree.dart';
import 'burns/seconddegree.dart';
import 'ECG/selector.dart';
import 'ECG/normal.dart';
import 'ECG/abnormal.dart';
import 'CPR/cpr_mode_selector.dart';
import 'ECG/MI.dart';
import 'ECG/CD.dart';
import 'ECG/TachyA.dart';
import 'ECG/STTC.dart';
import 'ECG/AA.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
        '/firstdegree': (context) => FirstDegreeBurnHelpPage(),
        '/seconddegree': (context) => SecondDegreeBurnHelpPage(),
        '/thirddegree': (context) => ThirdDegreeBurnHelpPage(),
        '/normalecg': (context) => const NormalECGPage(),
        '/abnormalecg': (context) => const AbnormalECGPage(),
        '/mi': (context) => const MyocardialInfarctionPage(),
        '/cd': (context) => const ConductionAbnormalityPage(),
        '/Tachy': (context) => const TachyArrhythmiaPage(),
        '/sttc': (context) => const STTChangePage()
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showButtons = false;
  bool _showAppName = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        _showButtons = true;
      });
      Timer(Duration(seconds: 2), () {
        setState(() {
          _showAppName = true;
        });
      });
    });
  }

  Future<void> _showBaseUrlDialog() async {
    TextEditingController controller = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    controller.text = prefs.getString('base_url') ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Base API URL'),
          content: SingleChildScrollView(
            // Add scroll for keyboard
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'https://example.com/api'),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await prefs.setString('base_url', controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent screen resize when keyboard appears
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                height: constraints.maxHeight,
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
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.network_wifi, color: Colors.white),
                          onPressed: _showBaseUrlDialog,
                        ),
                      ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 3000),
                        curve: Curves.easeInOut,
                        top:
                            _showButtons ? 100 : constraints.maxHeight / 2 - 60,
                        child: Image.asset(
                          'assets/images/emergencytrucklogo.png',
                          height: 120,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: Duration(seconds: 3),
                        opacity: _showAppName ? 1.0 : 0.0,
                        child: Transform.translate(
                          offset: Offset(0, -100),
                          child: Text(
                            'El7a2ny',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'inter',
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(5, 5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: Duration(seconds: 4),
                        opacity: _showButtons ? 1.0 : 0.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 240),
                            CustomButton(
                              imagePath: 'assets/images/cpr.png',
                              text: 'CPR  ',
                              viewPage: CPRModeSelector(),
                            ),
                            SizedBox(height: 20),
                            CustomButton(
                              imagePath: 'assets/images/heart-rate.png',
                              text: 'ECG  ',
                              viewPage: Selector(),
                            ),
                            SizedBox(height: 20),
                            CustomButton(
                              imagePath: 'assets/images/burn.png',
                              text: 'Burns',
                              viewPage: SelfieSegmenterView(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Widget viewPage;

  const CustomButton({
    required this.imagePath,
    required this.text,
    required this.viewPage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => viewPage));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(221, 153, 40, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
