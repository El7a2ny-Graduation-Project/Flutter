import 'package:flutter/material.dart';

class AbnormalECGPage extends StatelessWidget {
  const AbnormalECGPage({super.key});

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
                      'Abnormal ECG Result',
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
                  children: const [
                    SizedBox(height: 10),
                    Text(
                      'Your ECG may be abnormal ⚠️',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Our analysis has detected a pattern that might be outside the normal range. While this doesn’t necessarily mean something serious, it does require further attention.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    _AlertCard(
                      icon: Icons.search,
                      title: 'Use the Diagnosis Section',
                      description:
                          'Head to the Diagnosis section of this app to review potential causes and get further insight.',
                    ),
                    _AlertCard(
                      icon: Icons.medical_services,
                      title: 'Contact Your Healthcare Provider',
                      description:
                          'Share your ECG result with your primary care doctor or cardiologist. They can perform a thorough evaluation and guide you further.',
                    ),
                    _AlertCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Seek Immediate Help if Necessary',
                      description:
                          'If you are experiencing chest pain, dizziness, fainting, or shortness of breath, seek emergency medical care right away.',
                    ),
                    SizedBox(height: 30),
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

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 225, 47, 47),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
