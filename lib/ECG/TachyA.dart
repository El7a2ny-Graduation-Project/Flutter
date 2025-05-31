import 'package:flutter/material.dart';

class TachyArrhythmiaPage extends StatefulWidget {
  const TachyArrhythmiaPage({Key? key}) : super(key: key);

  @override
  _TachyArrhythmiaPageState createState() => _TachyArrhythmiaPageState();
}

class _TachyArrhythmiaPageState extends State<TachyArrhythmiaPage> {
  // Step definitions for non‐emergent tachyarrhythmia guidance
  final List<Map<String, String>> _steps = [
    {
      'icon': Icons.visibility.codePoint.toString(),
      'title': 'Recognize Symptoms',
      'desc': 'Notice if your heart feels unusually fast or fluttering.',
      'detail':
          'Pay attention to how you feel. Mild palpitations, slight lightheadedness, or a racing sensation may occur. If you remain stable without severe discomfort, proceed with self‐monitoring.'
    },
    {
      'icon': Icons.home_repair_service.codePoint.toString(),
      'title': 'Check Your Pulse',
      'desc': 'Use your wrist or neck to count your heart rate.',
      'detail':
          'Count beats for 30 seconds and multiply by 2. If your rate is above your normal resting range (usually 60–100 bpm) but you feel okay, rest and keep monitoring. If it rises above 120–130 bpm or you feel worse, consider contacting your provider.'
    },
    {
      'icon': Icons.bedtime.codePoint.toString(),
      'title': 'Rest & Relax',
      'desc': 'Sit or lie down in a calm, seated position.',
      'detail':
          'Deep breathing exercises can help. Try inhaling slowly through your nose and exhaling through pursed lips. This may help slow your heart rate if the tachyarrhythmia is benign.'
    },
    {
      'icon': Icons.local_drink.codePoint.toString(),
      'title': 'Stay Hydrated',
      'desc': 'Drink water unless you have fluid restrictions.',
      'detail':
          'Dehydration can trigger or worsen a fast heart rate. Sip water gradually. Avoid stimulants like caffeine, nicotine, or energy drinks which can exacerbate tachyarrhythmia.'
    },
    {
      'icon': Icons.medical_services.codePoint.toString(),
      'title': 'Take Prescribed Medications',
      'desc':
          'Continue any rate‐control or anticoagulant medications as instructed.',
      'detail':
          'Maintain your dosing schedule for medications such as beta‐blockers or calcium channel blockers. Do not skip doses—consistent medication levels help keep your heart rate manageable.'
    },
    {
      'icon': Icons.calendar_today.codePoint.toString(),
      'title': 'Schedule a Check‐In',
      'desc': 'Arrange a follow‐up with your healthcare provider soon.',
      'detail':
          'If symptoms persist or worsen (e.g., dizziness, chest discomfort), call your provider within 24–48 hours. They may order an ECG or adjust your medication to stabilize your rhythm.'
    },
  ];

  void _showInfo(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(255, 225, 47, 47),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            details,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color.fromARGB(255, 225, 47, 47),
                fontSize: 18,
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
      // Gradient background matching the ECG page design
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
          child: Column(
            children: [
              // Custom AppBar style
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      iconSize: 28,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Tachyarrhythmia',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Managing Rapid Heart Rate',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You are experiencing a fast heart rhythm. Follow these non‐emergent steps to keep it under control:',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    // Step cards
                    ..._steps.map(
                      (step) => StepCard(
                        iconCode: int.parse(step['icon']!),
                        title: step['title']!,
                        description: step['desc']!,
                        onTap: () => _showInfo(
                          context,
                          step['title']!,
                          step['detail']!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable step card styled like the ECG tip cards
class StepCard extends StatelessWidget {
  final int iconCode;
  final String title;
  final String description;
  final VoidCallback onTap;

  const StepCard({
    required this.iconCode,
    required this.title,
    required this.description,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 225, 47, 47),
          child: Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        trailing: const Icon(
          Icons.info_outline,
          color: Color.fromARGB(255, 225, 47, 47),
        ),
        onTap: onTap,
      ),
    );
  }
}
