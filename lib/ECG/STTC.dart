// lib/pages/stt_change_page.dart
import 'package:flutter/material.dart';

class STTChangePage extends StatelessWidget {
  const STTChangePage({Key? key}) : super(key: key);

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
    final changes = [
      {
        'icon': Icons.show_chart,
        'title': 'ST Elevation',
        'desc': '>1 mm elevation in two contiguous leads → call EMS.',
        'detail':
            'Elevation indicates acute full-thickness ischemia; needs immediate reperfusion therapy.'
      },
      {
        'icon': Icons.swap_vert,
        'title': 'ST Depression',
        'desc': '≥0.5 mm depression → possible NSTEMI; contact doctor.',
        'detail':
            'Depression suggests subendocardial ischemia; correlate with symptoms and troponin.'
      },
      {
        'icon': Icons.invert_colors,
        'title': 'T-Wave Inversion',
        'desc': 'New inversion ≥1 mm → repeat ECG and labs.',
        'detail':
            'Can reflect ischemia or electrolyte issues. Compare with prior ECGs if available.'
      },
      {
        'icon': Icons.medical_services,
        'title': 'Share with Provider',
        'desc': 'Send ECG and symptoms to your cardiologist ASAP.',
        'detail':
            'Include timing, intensity of pain, and any medications taken.'
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
                      'ST/T Changes',
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
                  itemCount: changes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final c = changes[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade200,
                          child:
                              Icon(c['icon'] as IconData, color: Colors.white),
                        ),
                        title: Text(c['title'] as String,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(c['desc'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.deepPurple),
                          onPressed: () => _showInfo(
                              ctx, c['title'] as String, c['detail'] as String),
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
