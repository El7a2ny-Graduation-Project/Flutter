// lib/pages/myocardial_infarction_page.dart
import 'package:flutter/material.dart';

class MyocardialInfarctionPage extends StatelessWidget {
  const MyocardialInfarctionPage({Key? key}) : super(key: key);

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
    final steps = [
      {
        'icon': Icons.phone_in_talk,
        'title': 'Call Emergency Services',
        'desc':
            'Dial your local emergency number (e.g. 122 in Egypt) immediately.',
        'detail':
            'Give your exact location, describe your chest pain, and follow dispatcher instructions.'
      },
      {
        'icon': Icons.local_pharmacy,
        'title': 'Chew Aspirin',
        'desc': 'Chew one adult aspirin (325 mg) now, unless you’re allergic.',
        'detail':
            'Aspirin helps reduce blood-clotting. Chewing speeds absorption.'
      },
      {
        'icon': Icons.healing,
        'title': 'Take Nitroglycerin',
        'desc':
            'If prescribed, place one tablet under your tongue every 5 min (up to 3 doses).',
        'detail':
            'Do not use if your blood pressure is very low (< 90 mmHg systolic).'
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Rest & Stay Calm',
        'desc': 'Sit or lie down, unlock your door, and wait for help.',
        'detail': 'Minimizing movement reduces heart workload and risk.'
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
                      'Myocardial Infarction',
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
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final s = steps[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade200,
                          child:
                              Icon(s['icon'] as IconData, color: Colors.white),
                        ),
                        title: Text(s['title'] as String,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(s['desc'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.deepPurple),
                          onPressed: () => _showInfo(
                              ctx, s['title'] as String, s['detail'] as String),
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
