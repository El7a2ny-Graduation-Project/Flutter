import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FirstDegreeBurnHelpPage extends StatelessWidget {
  const FirstDegreeBurnHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('First-Degree Burn Care'),
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
            'What is a First-Degree Burn?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A first-degree burn affects only the outer layer of the skin. '
            'It usually causes redness, mild pain, and swelling but no blisters.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _StepCard(
            number: 1,
            title: 'Cool the Burn',
            description:
                'Immediately hold the burn under cool (not cold) running water for 10 minutes.',
            lottie: 'assets/animations/2.json',
          ),
          _StepCard(
            number: 2,
            title: 'Protect the Area',
            description:
                'Use a sterile, non-adhesive bandage to cover the burn and prevent infection.',
            lottie: 'assets/animations/1.json',
          ),
          _StepCard(
            number: 3,
            title: 'Soothe the Skin',
            description:
                'Apply aloe vera gel or a burn ointment to ease pain and promote healing.',
            lottie: 'assets/animations/aloevera.json',
          ),
          _StepCard(
            number: 4,
            title: 'Avoid Breaking Skin',
            description: 'Do not peel the skin. Let it heal naturally.',
            lottie: 'assets/animations/4.json',
          ),
          const SizedBox(height: 30),
          ExpansionTile(
            leading: Icon(Icons.lightbulb, color: Colors.amber.shade700),
            title: const Text('Extra Tip: Pain Relief'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Over-the-counter medications like ibuprofen can help reduce pain and inflammation.',
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
              backgroundColor: Colors.red.shade300,
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
