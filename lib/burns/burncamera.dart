import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef JsonMap = Map<String, dynamic>;

/// A rounded button matching the Home screen style,
/// now with explicit width & height parameters.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double width;
  final double height;

  const GradientButton({
    required this.text,
    required this.onTap,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: height * 0.4,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(221, 153, 40, 40),
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> getBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('base_url');
}

/// Pure-Dart resize + JPEG compress (~600×600 @ quality 50)
Future<File> _compressFile(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) return file;
  final resized = img.copyResize(image, width: 600);
  final jpg = img.encodeJpg(resized, quality: 50);
  final target = File(
    '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_cmp.jpg',
  );
  await target.writeAsBytes(jpg);
  return target;
}

Future<JsonMap?> _segmentBurn({
  required File patient,
  required File reference,
}) async {
  final baseUrl = await getBaseUrl();
  if (baseUrl == null || baseUrl.isEmpty) throw Exception('Base URL not set');
  print("Segmenting burn with base URL: $baseUrl");
  final uri = Uri.parse('$baseUrl/segment_burn');
  print("Request URI: $uri");
  final request = http.MultipartRequest('POST', uri);

  final cmpRef = await _compressFile(reference);
  final cmpPat = await _compressFile(patient);

  request.files.add(await http.MultipartFile.fromPath(
    'reference',
    cmpRef.path,
    contentType: MediaType('image', 'jpeg'),
  ));
  request.files.add(await http.MultipartFile.fromPath(
    'patient',
    cmpPat.path,
    contentType: MediaType('image', 'jpeg'),
  ));

  final streamed = await request.send().timeout(
        const Duration(seconds: 1200),
        onTimeout: () => throw TimeoutException('Upload timed out'),
      );
  final response = await http.Response.fromStream(streamed).timeout(
    const Duration(seconds: 600),
    onTimeout: () => throw TimeoutException('Response timed out'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body) as JsonMap;
  } else {
    throw Exception(
        'Segmentation error ${response.statusCode}: ${response.body}');
  }
}

Future<JsonMap?> _classifyBurn(File cleanCrop) async {
  final baseUrl = await getBaseUrl();
  if (baseUrl == null || baseUrl.isEmpty) return null;

  final uri = Uri.parse('$baseUrl/predict_burn');
  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    cleanCrop.path,
    contentType: MediaType('image', 'jpeg'),
  ));

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  if (response.statusCode == 200) {
    return json.decode(response.body) as JsonMap;
  } else {
    print('Classification error: ${response.statusCode}');
    return null;
  }
}

class SelfieSegmenterView extends StatefulWidget {
  @override
  State<SelfieSegmenterView> createState() => _SelfieSegmenterViewState();
}

class _SelfieSegmenterViewState extends State<SelfieSegmenterView> {
  final ImagePicker _picker = ImagePicker();
  File? _patientImage, _referenceImage;
  String? _cleanUrl, _debugUrl;
  bool _isLoading = false;

  Future<File?> _cropImage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Colors.red.shade400,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: false),
      ],
    );
    return cropped != null ? File(cropped.path) : null;
  }

  Future<void> _pickPatient(ImageSource src) async {
    final imgFile = await _picker.pickImage(
      source: src,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (!mounted || imgFile == null) return;
    final file = await _cropImage(imgFile.path);
    if (!mounted || file == null) return;
    setState(() {
      _patientImage = file;
      _referenceImage = null;
      _cleanUrl = _debugUrl = null;
    });
  }

  Future<void> _pickReference(ImageSource src) async {
    if (!mounted || _patientImage == null) return;
    final imgFile = await _picker.pickImage(
      source: src,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (!mounted || imgFile == null) return;
    final file = await _cropImage(imgFile.path);
    if (!mounted || file == null) return;
    setState(() => _referenceImage = file);
  }

  Future<void> _runSegmentation() async {
    if (_patientImage == null || _referenceImage == null) return;
    setState(() {
      _isLoading = true;
      _cleanUrl = _debugUrl = null;
    });

    try {
      final res = await _segmentBurn(
        patient: _patientImage!,
        reference: _referenceImage!,
      );
      if (!mounted) return;
      setState(() {
        _cleanUrl = res?['crop_clean_url'] as String?;
        _debugUrl = res?['crop_debug_url'] as String?;
      });
    } catch (e) {
      if (mounted) _showErrorDialog('Segmentation error:\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendToClassifier() async {
    if (_cleanUrl == null) return;
    final dir = await Directory.systemTemp.createTemp();
    final tempFile = File('${dir.path}/clean_crop.jpg');
    final resp = await http.get(Uri.parse(_cleanUrl!));
    if (!mounted) return;

    if (resp.statusCode == 200) {
      await tempFile.writeAsBytes(resp.bodyBytes);
      setState(() => _isLoading = true);
      try {
        final res = await _classifyBurn(tempFile);
        if (!mounted) return;
        final pred = res?['prediction'];
        if (pred == 'Zero Class')
          Navigator.pushNamed(context, '/firstdegree');
        else if (pred == 'First Class')
          Navigator.pushNamed(context, '/seconddegree');
        else
          Navigator.pushNamed(context, '/thirddegree');
      } catch (e) {
        if (mounted) _showErrorDialog('Classification error:\n$e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _showErrorDialog('Failed to fetch clean crop.');
    }
  }

  void _showErrorDialog(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imgSize = MediaQuery.of(context).size.width * 0.8;
    const double btnWidth = 120;
    const double btnHeight = 40;

    final bool hasResults = _cleanUrl != null && _debugUrl != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Burn Segmentation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
        child: _isLoading
            ? Center(
                child: ColorFiltered(
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child:
                      Lottie.asset('assets/animations/loadingIndicator.json'),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!hasResults) ...[
                        const Text(
                          'Patient Image',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        if (_patientImage != null)
                          Center(
                            child: SizedBox(
                              width: imgSize,
                              height: imgSize * 0.8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_patientImage!,
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GradientButton(
                              text: 'Camera',
                              width: btnWidth,
                              height: btnHeight,
                              onTap: () => _pickPatient(ImageSource.camera),
                            ),
                            GradientButton(
                              text: 'Gallery',
                              width: btnWidth,
                              height: btnHeight,
                              onTap: () => _pickPatient(ImageSource.gallery),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_patientImage != null) ...[
                          const Text(
                            'Reference Image',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          if (_referenceImage != null)
                            Center(
                              child: SizedBox(
                                width: imgSize,
                                height: imgSize * 0.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_referenceImage!,
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GradientButton(
                                text: 'Camera',
                                width: btnWidth,
                                height: btnHeight,
                                onTap: () => _pickReference(ImageSource.camera),
                              ),
                              GradientButton(
                                text: 'Gallery',
                                width: btnWidth,
                                height: btnHeight,
                                onTap: () =>
                                    _pickReference(ImageSource.gallery),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_referenceImage != null)
                            Center(
                              child: GradientButton(
                                text: 'Segment',
                                width: btnWidth,
                                height: btnHeight,
                                onTap: _runSegmentation,
                              ),
                            ),
                        ],
                      ],
                      if (hasResults) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Cropped Image',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: SizedBox(
                            width: imgSize,
                            height: imgSize * 0.8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  Image.network(_cleanUrl!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Detected Burn',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: SizedBox(
                            width: imgSize,
                            height: imgSize * 0.8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  Image.network(_debugUrl!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GradientButton(
                            text: 'Classify Burn',
                            width: btnWidth,
                            height: btnHeight,
                            onTap: _sendToClassifier,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
