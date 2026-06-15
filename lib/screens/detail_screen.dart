import 'dart:io';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';

class DetailScreen extends StatelessWidget {
  final File imageFile;
  final ClassificationResult result;

  const DetailScreen({super.key, required this.imageFile, required this.result});

  @override
  Widget build(BuildContext context) {
    final pest = result.pestInfo;
    final confidence = (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar با تصویر
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.green.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(imageFile, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pest.commonName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          pest.name,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // محتوای اصلی
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // کارت اطمینان
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('نتیجه تشخیص', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(
                                'اطمینان: $confidence%',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // بخش‌های اطلاعاتی
                  _buildInfoSection(Icons.category, 'راسته', pest.order, Colors.blue),
                  _buildInfoSection(Icons.public, 'پراکنش جغرافیایی', pest.distribution, Colors.orange),
                  _buildInfoSection(Icons.eco, 'گیاهان میزبان', pest.hosts, Colors.green),
                  _buildInfoSection(Icons.warning_amber, 'نوع خسارت', pest.damage, Colors.red),
                  _buildInfoSection(Icons.visibility, 'علائم خسارت', pest.symptoms, Colors.purple),
                  _buildInfoSection(Icons.shield, 'روش‌های کنترل', pest.controlMethods, Colors.teal),
                  _buildInfoSection(Icons.gavel, 'وضعیت قرنطینه', pest.quarantineStatus, Colors.brown),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(IconData icon, String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}