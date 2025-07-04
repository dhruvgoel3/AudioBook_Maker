import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../ConvertAudio/convert_audio_screen.dart';

class UploadPDFScreen extends StatefulWidget {
  const UploadPDFScreen({super.key});

  @override
  State<UploadPDFScreen> createState() => _UploadPDFScreenState();
}

class _UploadPDFScreenState extends State<UploadPDFScreen> {
  String? _pdfPath;
  String? _pdfText;
  String? _fileName;
  String? _pdfUrl;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> pickAndProcessPDF() async {
    setState(() {
      _isLoading = true;
      _pdfPath = null;
      _pdfText = null;
      _fileName = null;
      _pdfUrl = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final pickedFile = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileBytes = await pickedFile.readAsBytes();

      // Extract text using Syncfusion
      final document = PdfDocument(inputBytes: fileBytes);
      final extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      // Upload PDF to Supabase Storage
      final pdfRef = 'pdfs/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await supabase.storage.from('pdfs').uploadBinary(
        pdfRef,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final publicUrl = supabase.storage.from('pdfs').getPublicUrl(pdfRef);

      // Insert to Supabase table
      await supabase.from('audiobooks').insert({
        'user_id': supabase.auth.currentUser!.id,
        'title': fileName,
        'pdf_url': publicUrl,
        'extracted_text': extractedText,
      });

      // Save file locally to preview in PDFView
      final dir = await getApplicationDocumentsDirectory();
      final saved = File('${dir.path}/$fileName');
      await saved.writeAsBytes(fileBytes);

      // Debug logs
      print("✅ PDF saved to: ${saved.path}");
      print("✅ PDF text extracted: ${extractedText.substring(0, 100)}...");
      print("✅ Supabase public URL: $publicUrl");

      setState(() {
        _fileName = fileName;
        _pdfPath = saved.path;
        _pdfText = extractedText;
        _pdfUrl = publicUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload PDF")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickAndProcessPDF,
              icon: const Icon(Icons.upload_file),
              label: const Text("Pick PDF File"),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),

            if (_fileName != null) ...[
              Text(
                "📄 PDF: $_fileName",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],

            if (_pdfPath != null)
              SizedBox(
                height: 250,
                child: PDFView(
                  filePath: _pdfPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                ),
              ),

            const SizedBox(height: 12),

            if (_pdfText != null)
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    _pdfText!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else if (!_isLoading)
              const Text(
                "Please pick a PDF to extract and view its content.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 16),

            if (_pdfText != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text("Convert to Audio"),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => ConvertAudioScreen(
                  //       text: _pdfText!,
                  //       title: _fileName!,
                  //     ),
                  //   ),
                  // );
                },
              ),

            // Debug Button (optional)
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                print('🔍 Debug Values:');
                print('File Name: $_fileName');
                print('PDF Path: $_pdfPath');
                print('Text: ${_pdfText?.substring(0, 100)}...');
                print('PDF URL: $_pdfUrl');
              },
              child: const Text("Debug Print"),
            ),
          ],
        ),
      ),
    );
  }
}
