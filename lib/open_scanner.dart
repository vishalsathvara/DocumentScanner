import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'scan_data_provider.dart';
import 'document_scanner_screen.dart';

class OpenScanner extends StatefulWidget {
  const OpenScanner({super.key});

  @override
  State<OpenScanner> createState() => _OpenScannerState();
}

class _OpenScannerState extends State<OpenScanner> {
  late DocumentScanner _scanner;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show spinner during loading
            : const Text("Initializing scanner..."), // Placeholder
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initScanner(); // Ensure scanner is initialized
    _checkPermissionsAndStartScanning();
    print('initState is called');
  }

  void _initScanner() {
    try {
      _scanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.filter,
          pageLimit: 10,
          isGalleryImport: true,
        ),
      );
    } catch (e) {
      _showError('Failed to initialize scanner: $e');
    }
  }

  Future<void> _checkPermissionsAndStartScanning() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _scanDocument();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(); // Show dialog for permanently denied permissions
    } else {
      await Permission.camera.request();
      final newStatus = await Permission.camera.status;
      if (newStatus.isGranted) {
        _scanDocument();
      } else {
        _showError("Camera permission is required to scan documents.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentScannerScreen(),
          ),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Camera Permission Required"),
          content: const Text(
              "Camera access is required to scan documents. Please enable it in settings."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings(); // Redirect to app settings
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _scanner.scanDocument();

      if (result != null && result.images.isNotEmpty) {
        // Use ScanDataProvider to add images
        final scanData = Provider.of<ScanDataProvider>(context, listen: false);
        scanData.addScannedImages(result.images);

        // Navigate to ImagePreviewScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => ImagePreviewScreen(),
            builder: (context) => DocumentScannerScreen(),
          ),
        );
      } else {
        _showError('No images found. Please try again.');
      }
    } catch (e) {
      _showError('Scan Failed. Returning to main screen.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DocumentScannerScreen(),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_scanner != null) {
      _scanner.close();
    }
    super.dispose();
  }
}
