import 'package:flutter/material.dart';

class NormalECGPage extends StatelessWidget {
  const NormalECGPage({super.key});

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
                      color: Colors.white, // changed from deepPurple to white
                      iconSize: 28,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ECG Result',
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
                  children: const [
                    SizedBox(height: 10),
                    Text(
                      'Your ECG appears normal!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Great news! Your heart rhythm and electrical activity look healthy. Keep it up with the following habits:',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 30),
                    _TipCard(
                      number: 1,
                      title: 'Stay Active',
                      description:
                          'Aim for at least 30 minutes of moderate exercise most days of the week.',
                    ),
                    _TipCard(
                      number: 2,
                      title: 'Eat Heart-Smart',
                      description:
                          'Include more fruits, vegetables, whole grains, and healthy fats in your meals.',
                    ),
                    _TipCard(
                      number: 3,
                      title: 'Avoid Risky Habits',
                      description:
                          'Refrain from smoking and limit alcohol consumption.',
                    ),
                    _TipCard(
                      number: 4,
                      title: 'Prioritize Sleep',
                      description:
                          'Get 7–8 hours of restful sleep every night to support your heart health.',
                    ),
                    _TipCard(
                      number: 5,
                      title: 'Manage Stress',
                      description:
                          'Practice breathing, mindfulness, or other techniques to reduce stress daily.',
                    ),
                    SizedBox(height: 30),
                    ExpansionTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: Color.fromARGB(255, 225, 47, 47),
                      ),
                      title: Text(
                        'When to Repeat Your ECG',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Text(
                            '• No symptoms or history? An ECG every 1–2 months is usually enough.\n\n'
                            '• See a doctor if you notice chest pain, shortness of breath, or irregular heartbeat.',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
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

class _TipCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _TipCard({
    required this.number,
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
          child: Text(
            '$number',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
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
