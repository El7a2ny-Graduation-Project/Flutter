import 'package:flutter/material.dart';

class ConductionAbnormalityPage extends StatefulWidget {
  const ConductionAbnormalityPage({Key? key}) : super(key: key);

  @override
  _ConductionAbnormalityPageState createState() =>
      _ConductionAbnormalityPageState();
}

class _ConductionAbnormalityPageState extends State<ConductionAbnormalityPage> {
  final List<Map<String, String>> _steps = [
    {
      'icon': Icons.phone_in_talk.codePoint.toString(),
      'title': 'Call Emergency Services',
      'desc': 'Dial your local emergency number immediately.',
      'detail':
          'Conduction abnormalities (like high‐grade AV block or complete heart block) can lead to dangerously slow or irregular heartbeats. Do not wait—call for emergency help right away so rescuers can begin advanced monitoring and care.'
    },
    {
      'icon': Icons.bedtime.codePoint.toString(),
      'title': 'Lie Down & Rest',
      'desc': 'Sit or lie flat and remain still.',
      'detail':
          'Avoid any physical activity. Lying flat helps maintain blood flow to your brain and organs while rescue is on the way. Do not try to walk, stand, or drive yourself to the hospital.'
    },
    {
      'icon': Icons.warning.codePoint.toString(),
      'title': 'Monitor for Symptoms',
      'desc': 'Do not ignore dizziness, fainting, or chest tightness.',
      'detail':
          'If you experience severe lightheadedness, sudden fainting, shortness of breath, or chest discomfort, inform the dispatcher immediately. These signs indicate your heart is not effectively pumping blood.'
    },
    {
      'icon': Icons.medical_services.codePoint.toString(),
      'title': 'Follow Pacemaker Instructions',
      'desc': 'If you have a pacemaker, adhere to its emergency protocol.',
      'detail':
          'People with implanted pacemakers should keep their ID card or device information nearby. Tell the dispatcher and first responders that you have a pacemaker so they can verify that it is functioning correctly.'
    },
    {
      'icon': Icons.family_restroom.codePoint.toString(),
      'title': 'Inform a Caregiver',
      'desc': 'Have someone stay with you until help arrives.',
      'detail':
          'Ask a family member or friend to remain at your side. They can update emergency services on any changes and help you stay calm until medical personnel take over.'
    },
    {
      'icon': Icons.calendar_today.codePoint.toString(),
      'title': 'Hospital Evaluation & Treatment',
      'desc': 'You will need continuous ECG monitoring and possible pacing.',
      'detail':
          'At the hospital, providers will confirm the conduction block with an ECG. Treatment often includes temporary or permanent pacemaker placement to ensure a safe heart rate.'
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
                      'Conduction Abnormalities',
                      style: TextStyle(
                        fontSize: 22,
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
                      'Emergency Steps for Conduction Block',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Conduction abnormalities require immediate action. Follow these steps without delay:',
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
