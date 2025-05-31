// lib/pages/conduction_disturbance_page.dart
import 'package:flutter/material.dart';

class ConductionDisturbancePage extends StatelessWidget {
  const ConductionDisturbancePage({Key? key}) : super(key: key);

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
    final blocks = [
      {
        'icon': Icons.filter_1,
        'title': 'First-Degree AV Block',
        'desc': 'PR > 200 ms; usually benign—monitor.',
        'detail':
            'No dropped beats. Follow up if symptoms like dizziness appear.'
      },
      {
        'icon': Icons.filter_2,
        'title': 'Mobitz I (Wenckebach)',
        'desc': 'Progressive PR lengthening → dropped beat.',
        'detail':
            'Often asymptomatic. Rarely needs intervention unless symptoms develop.'
      },
      {
        'icon': Icons.filter_3,
        'title': 'Mobitz II',
        'desc': 'Fixed PR → intermittent dropped beats.',
        'detail': 'Risk of progression. Report immediately; may need pacemaker.'
      },
      {
        'icon': Icons.cancel,
        'title': 'Third-Degree AV Block',
        'desc': 'Complete AV dissociation—emergency.',
        'detail':
            'Symptoms: fainting, severe fatigue. Call EMS and go to ER now.'
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
                      'Conduction Block',
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
                  itemCount: blocks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final b = blocks[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade200,
                          child:
                              Icon(b['icon'] as IconData, color: Colors.white),
                        ),
                        title: Text(b['title'] as String,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(b['desc'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.deepPurple),
                          onPressed: () => _showInfo(
                              ctx, b['title'] as String, b['detail'] as String),
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
