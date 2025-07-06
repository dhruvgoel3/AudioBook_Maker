import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final supabase = Supabase.instance.client;

  String? pdfPath;
  String? pdfText;
  String? fileName;
  String? pdfUrl;
  bool isLoading = false;

  Future<void> pickAndProcessPDF() async {
    setState(() {
      isLoading = true;
      pdfPath = null;
      pdfText = null;
      fileName = null;
      pdfUrl = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final pickedFile = File(result.files.single.path!);
      final _fileName = result.files.single.name;
      final fileBytes = await pickedFile.readAsBytes();

      // Extract text using Syncfusion
      final document = PdfDocument(inputBytes: fileBytes);
      final extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      // Upload PDF to Supabase Storage
      final pdfRef = 'pdfs/${DateTime.now().millisecondsSinceEpoch}_$_fileName';
      await supabase.storage
          .from('pdfs')
          .uploadBinary(
        pdfRef,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final publicUrl = supabase.storage.from('pdfs').getPublicUrl(pdfRef);

      // Insert to Supabase table
      await supabase.from('audiobooks').insert({
        'user_id': supabase.auth.currentUser!.id,
        'title': _fileName,
        'pdf_url': publicUrl,
        'extracted_text': extractedText,
      });

      // Save file locally to preview in PDFView
      final dir = await getApplicationDocumentsDirectory();
      final saved = File('${dir.path}/$_fileName');
      await saved.writeAsBytes(fileBytes);

      setState(() {
        fileName = _fileName;
        pdfPath = saved.path;
        pdfText = extractedText;
        pdfUrl = publicUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "AudioBook App",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: pickAndProcessPDF,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  "Pick PDF File",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),

            if (fileName != null) ...[
              Text(
                "PDF: $fileName",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],

            if (pdfPath != null)
              SizedBox(
                height: 250,
                child: PDFView(
                  filePath: pdfPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                ),
              ),

            const SizedBox(height: 12),

            if (pdfText != null)
              Flexible(
                child: SingleChildScrollView(
                  child: Text(pdfText!, style: const TextStyle(fontSize: 16)),
                ),
              )
            else if (!isLoading)
              const Text(
                "Please pick a PDF to extract and view its content.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 16),

            if (pdfText != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text("Convert to Audio"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConvertAudioScreen(
                        text: pdfText!,
                        title: fileName!,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
