import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'af.dart'; // Import your AF page widget

class Selector extends StatefulWidget {
  const Selector({super.key});

  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  File? _selectedFile;
  bool _isLoading = false; // Loading state
  String? baseUrl;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = prefs.getString('base_url') ??
          'https://husseinhadidy-deploy-el7a2ny-application.hf.space';
    });
  }

  /// Sends the selected PDF to the classify-ecg endpoint
  Future<String> fetchECGClassification(File file) async {
    if (baseUrl == null) {
      throw Exception('Base URL not loaded yet');
    }
    final uri = Uri.parse('$baseUrl/classify-ecg');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('application', 'pdf'),
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body) as Map<String, dynamic>;
      return data['result'] as String;
    } else {
      throw Exception('Failed to classify ECG (status ${response.statusCode})');
    }
  }

  /// Sends the selected PDF to the diagnose-ecg endpoint (mock, not used)
  Future<String> fetchECGDiagnosis(File file) async {
    if (baseUrl == null) {
      throw Exception('Base URL not loaded yet');
    }
    final uri = Uri.parse('$baseUrl/diagnose-ecg');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('application', 'pdf'),
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body) as Map<String, dynamic>;
      return data['result'] as String;
    } else {
      throw Exception('Failed to diagnose ECG (status ${response.statusCode})');
    }
  }

  /// Let the user pick exactly one PDF file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 225, 47, 47),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child:
                        Lottie.asset('assets/animations/loadingIndicator.json'),
                  ),
                )
              : Stack(
                  children: [
                    // Main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'ECG Mode',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Lottie.asset(
                            'assets/animations/Heartbeat.json',
                            height: 250,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Pick PDF button
                        ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 18),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Pick ECG PDF',
                            style: TextStyle(
                              color: Color.fromARGB(255, 153, 40, 40),
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_selectedFile != null)
                          Text(
                            'Selected: ${_selectedFile!.path.split('/').last}',
                            style: const TextStyle(fontSize: 16),
                          ),

                        const SizedBox(height: 32),

                        // Check-up (classification) button
                        ElevatedButton(
                          onPressed: () async {
                            if (_selectedFile == null) {
                              _showSnack('Please pick a PDF first');
                              return;
                            }
                            setState(() => _isLoading = true);
                            try {
                              final status =
                                  await fetchECGClassification(_selectedFile!);
                              setState(() => _isLoading = false);
                              if (status == 'Normal') {
                                Navigator.pushNamed(context, '/normalecg');
                              } else if (status == 'Abnormal') {
                                Navigator.pushNamed(context, '/abnormalecg');
                              } else {
                                _showSnack('Unexpected status: $status');
                              }
                            } catch (e) {
                              setState(() => _isLoading = false);
                              _showSnack('Error: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 18),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Check-up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 153, 40, 40),
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Diagnosis button now routes directly to AF page
                        ElevatedButton(
                          onPressed: () async {
                            if (_selectedFile == null) {
                              _showSnack('Please pick a PDF first');
                              return;
                            }
                            setState(() => _isLoading = true);
                            // Simulate loading delay
                            await Future.delayed(const Duration(seconds: 2));
                            setState(() => _isLoading = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AtrialFibrillationPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 18),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Diagnosis',
                            style: TextStyle(
                              color: Color.fromARGB(255, 153, 40, 40),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Back button (now in white)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 32.0,
                        color: Colors.white, // changed from deepPurple to white
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
