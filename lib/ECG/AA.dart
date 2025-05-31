import 'package:flutter/material.dart';

class ArtialArrhythmiaPage extends StatefulWidget {
  const ArtialArrhythmiaPage({Key? key}) : super(key: key);

  @override
  _ArtialArrhythmiaPageState createState() => _ArtialArrhythmiaPageState();
}

class _ArtialArrhythmiaPageState extends State<ArtialArrhythmiaPage> {
  // Step definitions with icon codepoints, titles, descriptions, and details
  final List<Map<String, String>> _steps = [
    {
      'icon': Icons.phone_in_talk.codePoint.toString(),
      'title': 'Call Emergency Services',
      'desc': 'Dial your local emergency number immediately.',
      'detail':
          'Describe your symptoms (palpitations, dizziness, chest discomfort) and follow the dispatcher’s instructions.'
    },
    {
      'icon': Icons.medical_services.codePoint.toString(),
      'title': 'Take Prescribed Medications',
      'desc':
          'If you have been prescribed anticoagulants or rate-control meds, take them as directed.',
      'detail':
          'Do not skip doses. Medications like beta-blockers, calcium channel blockers or anticoagulants help control rate and prevent clots.'
    },
    {
      'icon': Icons.favorite.codePoint.toString(),
      'title': 'Rest & Monitor',
      'desc': 'Sit or lie down in a comfortable position.',
      'detail':
          'Keep a close eye on your heart rate and blood pressure if you have a home monitor. Note any worsening symptoms.'
    },
    {
      'icon': Icons.water_drop.codePoint.toString(),
      'title': 'Stay Hydrated',
      'desc': 'Drink small sips of water unless fluid-restricted.',
      'detail':
          'Dehydration can trigger or worsen arrhythmias. Avoid caffeine and alcohol.'
    },
    {
      'icon': Icons.calendar_today.codePoint.toString(),
      'title': 'Follow Up',
      'desc': 'Arrange a visit with your cardiologist as soon as possible.',
      'detail':
          'Further tests (ECG, echo) and medication adjustments may be needed to stabilize your rhythm.'
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
                      'Atrial Arrhythmia',
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
                      'What to Do in Atrial Arrhythmia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You are currently experience an Atrial Arrhythmia, Follow these steps immediately:',
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
