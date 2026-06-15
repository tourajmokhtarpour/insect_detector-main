import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClassifierService _classifier = ClassifierService();
  File? _imageFile;
  bool _isProcessing = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _classifier.loadModel();
      setState(() => _modelLoaded = true);
    } catch (e) {
      _showError('خطا در بارگذاری مدل: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_modelLoaded) {
      _showError('مدل هنوز آماده نیست. لطفاً صبر کنید.');
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 95);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isProcessing = true;
      });

      try {
        final result = await _classifier.classifyImage(_imageFile!);
        if (!mounted) return;

        if (result != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                imageFile: _imageFile!,
                result: result,
              ),
            ),
          );
        } else {
          _showError('تشخیص ممکن نبود. لطفاً تصویر بهتری انتخاب کنید.');
        }
      } catch (e) {
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'تشخیص حشرات قرنطینه‌ای',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _imageFile != null
                                ? Image.file(_imageFile!, height: 280, width: double.infinity, fit: BoxFit.cover)
                                : Container(
                                    height: 280,
                                    color: Colors.green.shade50,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bug_report_outlined, size: 100, color: Colors.green.shade300),
                                        const SizedBox(height: 16),
                                        Text('تصویر حشره را انتخاب کنید', style: TextStyle(color: Colors.green.shade700)),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isProcessing || !_modelLoaded ? null : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 20),
                              label: const Text('دوربین'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _isProcessing || !_modelLoaded ? null : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library, size: 20),
                              label: const Text('گالری'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade300, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('💡 نکته مهم:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'برای تشخیص دقیق‌تر، از حشره با کیفیت بالا و نور مناسب عکس بگیرید. حشره باید واضح و در مرکز تصویر باشد.',
                                      style: TextStyle(fontSize: 13, color: Colors.amber.shade800, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isProcessing) ...[
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(color: Colors.green),
                          const SizedBox(height: 12),
                          const Text('در حال تحلیل تصویر...', style: TextStyle(fontSize: 16, color: Colors.green)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}