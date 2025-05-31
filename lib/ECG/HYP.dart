// lib/pages/hypertrophy_page.dart
import 'package:flutter/material.dart';

class HypertrophyPage extends StatelessWidget {
  const HypertrophyPage({Key? key}) : super(key: key);

  void _showInfo(BuildContext ctx, String title, String details) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: const TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
            child: Text(details, style: const TextStyle(fontSize: 16))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'icon': Icons.favorite,
        'title': 'Control Blood Pressure',
        'desc': 'Aim for < 130/80 mmHg with meds & diet.',
        'detail':
            'High BP is the main driver of LVH. Follow your prescription carefully.'
      },
      {
        'icon': Icons.image,
        'title': 'Get Echocardiogram',
        'desc': 'Ultrasound to measure wall thickness.',
        'detail': 'Helps track hypertrophy regression over time.'
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Exercise Safely',
        'desc': 'Moderate activity per doctor’s advice.',
        'detail': 'Brisk walking or light cardio; avoid heavy lifting.'
      },
      {
        'icon': Icons.event_note,
        'title': 'Regular Check-ups',
        'desc': 'Follow cardiologist schedule for testing.',
        'detail': 'Ensure labs (electrolytes, kidney) and ECG are up to date.'
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD84D8C), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.deepPurple,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Hypertrophy',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: tips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final t = tips[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade200,
                          child:
                              Icon(t['icon'] as IconData, color: Colors.white),
                        ),
                        title: Text(t['title'] as String,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(t['desc'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.deepPurple),
                          onPressed: () => _showInfo(
                              ctx, t['title'] as String, t['detail'] as String),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
