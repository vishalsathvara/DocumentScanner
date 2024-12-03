import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:path_provider/path_provider.dart'; // To get temporary directory
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For rendering PDF
import 'dart:io';
import 'dart:typed_data';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  Future<String>? _loadPdfFuture;
  int _currentPage = 1; // Start from page 1
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdfFuture = _loadPdf();
  }
  @override
  void dispose() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/BroadsyprivacyPolicy.pdf');
    if (file.existsSync()) {
      try {
        file.deleteSync(); // Try deleting the file
      } catch (e) {
        print("Error deleting the file: $e");
      }
    }

    // Always call the superclass dispose() to ensure proper cleanup
    super.dispose();
  }


  // Function to load the PDF from assets and save it as a temporary file
  Future<String> _loadPdf() async {
    // Load PDF file from assets as bytes
    ByteData data = await rootBundle.load('assets/BroadsyprivacyPolicy.pdf');
    final buffer = data.buffer.asUint8List();

    // Get the temporary directory
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/BroadsyprivacyPolicy.pdf');

    // Write the file to the temporary directory
    await file.writeAsBytes(buffer);

    return file.path;
  }

  // Callback function to handle page changes
  void _onPageChanged(int? page, int? total) {
    setState(() {
      // Safely handle nullable values with the null-aware operator
      _currentPage = (page ?? 0) + 1;  // Add 1 to make page number start from 1
      _totalPages = total ?? 0;  // Default to 0 if total is null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy & Policy",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor:  Color(0xffff9724),
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _loadPdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading PDF: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                // PDF viewer widget to render the PDF
                Expanded(
                  child: PDFView(
                    filePath: snapshot.data!,
                    onPageChanged: _onPageChanged, // Track page changes
                    onViewCreated: (PDFViewController pdfViewController) async {
                      // Get total pages once the view is created
                      int totalPages = await pdfViewController.getPageCount() ?? 0; // Handle null value
                      setState(() {
                        _totalPages = totalPages;
                      });
                    },
                  ),
                ),
                // Display current page and total pages at the bottom of the screen
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Page $_currentPage/$_totalPages',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No PDF found.'));
          }
        },
      ),
    );
  }
}
