import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThirdDegreeBurnHelpPage extends StatelessWidget {
  const ThirdDegreeBurnHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade200,
      appBar: AppBar(
        title: const Text('Third-Degree Burn Care'),
        backgroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Lottie.asset(
            'assets/animations/fire.json', // Replace with suitable Lottie
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'What is a Third-Degree Burn?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A third-degree burn affects all layers of the skin and may extend into fat, muscle, or bone. '
            'The area may appear white, charred, or leathery and may be numb due to nerve damage. Immediate medical care is crucial.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _StepCard(
            number: 1,
            title: 'Call Emergency Services',
            description:
                'Dial emergency services immediately. Third-degree burns are life-threatening and require urgent medical attention.',
            lottie: 'assets/animations/hospital.json',
          ),
          _StepCard(
            number: 2,
            title: 'Ensure Safety',
            description:
                'Remove the person from the source of the burn (e.g., fire, chemical, or hot surface) if it is safe to do so.',
            lottie: 'assets/animations/betterfire.json',
          ),
          _StepCard(
            number: 3,
            title: 'Protect the Burn Area',
            description: ' Do not apply water, ointments, or ice.',
            lottie: 'assets/animations/dont.json',
          ),
          _StepCard(
            number: 4,
            title: 'Prevent Shock',
            description:
                'Lay the person flat, elevate legs, and keep them warm and calm while waiting for help.',
            lottie: 'assets/animations/legs_up.json',
          ),
          const SizedBox(height: 30),
          ExpansionTile(
            leading: Icon(Icons.warning_amber, color: Colors.amber.shade800),
            title: const Text('Important: What NOT to Do'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  '• Do NOT remove burned clothing stuck to skin.\n'
                  '• Do not give the person anything to eat or drink if surgery may be needed.\n'
                  '• Do NOT apply creams, oils, or ice.\n'
                  '• Do NOT touch or break blisters.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String lottie;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.lottie,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade700,
              child: Text('$number',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            title: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(description, style: const TextStyle(fontSize: 16)),
            ),
          ),
          Lottie.asset(
            lottie,
            height: 120,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
