import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SecondDegreeBurnHelpPage extends StatelessWidget {
  const SecondDegreeBurnHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      appBar: AppBar(
        title: const Text('Second-Degree Burn Care'),
        backgroundColor: Colors.red.shade600,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Lottie.asset(
            'assets/animations/5.json',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'What is a Second-Degree Burn?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A second-degree burn affects both the outer layer (epidermis) and the underlying layer (dermis) of the skin. '
            'It usually causes redness, swelling, blistering, and intense pain.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _StepCard(
            number: 1,
            title: 'Cool the Burn Gently',
            description:
                'Place the burn under cool (not cold) running water for 15–20 minutes. Avoid ice or extremely cold water.',
            lottie: 'assets/animations/2.json',
          ),
          _StepCard(
            number: 2,
            title: 'Do Not Pop Blisters',
            description:
                'Blisters protect the underlying skin and help prevent infection. Let them heal naturally.',
            lottie: 'assets/animations/4.json',
          ),
          _StepCard(
            number: 3,
            title: 'Cover the Burn',
            description:
                'Loosely cover with a sterile, non-stick bandage. Change the dressing daily and keep the area clean.',
            lottie: 'assets/animations/1.json',
          ),
          _StepCard(
            number: 4,
            title: 'Apply Antibiotic Ointment',
            description:
                'Use antibiotic ointments  to prevent infection and aid healing.',
            lottie: 'assets/animations/3.json',
          ),
          _StepCard(
            number: 5,
            title: 'Monitor for Infection',
            description:
                'Watch for signs like increased redness, swelling, pus, or fever. Seek medical attention if these occur.',
            lottie: 'assets/animations/Bacteria.json',
          ),
          const SizedBox(height: 30),
          ExpansionTile(
            leading: Icon(Icons.lightbulb, color: Colors.amber.shade700),
            title: const Text('Extra Tip: When to seek medical advice'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'If the burn is larger than 3 inches, on the face, hands, feet, or genitals, or if you are unsure about its severity, consult a healthcare provider.',
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
              backgroundColor: Colors.orange.shade300,
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
