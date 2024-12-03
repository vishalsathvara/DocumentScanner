import 'dart:async';
import 'package:document_scan/FAQs.dart';
import 'package:document_scan/UpdateScreen.dart';
import 'package:document_scan/mellotippet_firebase_RemoteConfig.dart';
import 'package:document_scan/privacy_policy.dart';
import 'package:document_scan/scan_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'saved_Pdf_Screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'trash_screen.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'edit_image_screen.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late DocumentScanner _scanner;
  bool _isLoading = false;
  String _appVersion = "Loading...";

  late List<bool> _selectedImages;
  late String _buttonText;

  final _controller = TextEditingController();
  String? errorMessage;

  // Getter to access scanned images from ScanDataProvider
  List<String> get scannedImages =>
      Provider.of<ScanDataProvider>(context, listen: false).scannedImages;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    // _checkPermissionsAndStartScanning();
    _getAppVersion();
    _initScanner();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(_animationController);

    // Use the getter to initialize _selectedImages
    _selectedImages = List<bool>.filled(scannedImages.length, false);
    _buttonText = 'Share All';
  }

  Future<void> _checkPermissionsAndStartScanning() async {    //1.
    var status = await Permission.camera.status;
    if (status.isGranted) {
      _initScanner();
      _scanDocument();
    } else if (status.isDenied) {
      _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  Future<void> _checkForUpdate() async {
    final remoteConfigService = RemoteConfigService(); // Create an instance of RemoteConfigService
    await remoteConfigService.initialize();

    final updateRequired = await remoteConfigService.isUpdateRequired();
    if (updateRequired) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UpdateScreen()),
      );
    }
  }


  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Camera Permission"),
          content: const Text("Please grant camera permission to scan documents."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.camera.request();
                _checkPermissionsAndStartScanning();
              },
              child: const Text("Grant"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Camera Permission Denied"),
          content: const Text("Please go to settings and enable camera permission."),
          // content: const Text("Flutter show only specif screen on app start without rendering previous screen."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text("Settings"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }



  void _initScanner() {
    _scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.filter,
        pageLimit: 10,
        isGalleryImport: true,
      ),
    );
  }

  @override
  void dispose() {
    // Check if _scanner is initialized before calling close()
    if (_scanner != null) {
      _scanner.close();
    }

    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version; // Set the app version
      });
      print("App Version: $_appVersion"); // Debugging line to check if the version is retrieved
    } catch (e) {
      print("Error retrieving version: $e"); // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannedImages = Provider.of<ScanDataProvider>(context).scannedImages; // Fetch dynamically
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'BTScan',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
              color: isDarkMode ? Colors.black : Colors.black
          ),
          elevation: 0,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  // color: Colors.orangeAccent,
                    color: Color(0xffF47A00)
                ),
                child: Text(
                  'BTScan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('PDF History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedPdfScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Trash'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrashScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('FAQs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaqScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact Us'),
                onTap: () {
                  Navigator.pop(context);
                  _showContactUsDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy & Policy'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyView(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: Text(_appVersion),  // Display the version here
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
            ],
          ),
        ),
        body:
        scannedImages.isEmpty ?

        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/home_girl_scan_cleanup.jpg"),
              fit: BoxFit.cover,
              opacity: 0.4,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 1.0 - _animationController.value,
                          child: Container(
                            width: 100 + (100 * _animationController.value),
                            height: 100 + (100 * _animationController.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrange.withOpacity(0.4),
                            ),
                          ),
                        );
                      },
                    ),

                    //Scan Button
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          _initScanner();
                          _scanDocument();
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'Scan',
                            style: TextStyle(fontSize: 26, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )

            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  // itemCount: scannedImages.length,
                  itemCount: scannedImages.isEmpty ? 0 : scannedImages.length,
                  itemBuilder: (context, index) {
                    if (index >= scannedImages.length || index >= _selectedImages.length) {
                      return SizedBox(); // Return an empty widget
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages[index] = !_selectedImages[index];
                          _updateButtonText();
                        });
                      },
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullImageScreen(imagePath: scannedImages[index]),
                          ),
                        ).then((result) {
                          if (result != null && result is File) {
                            setState(() {
                              // widget.scannedImages[index] = result.path;
                              scannedImages[index] = result.path;
                            });
                          }
                        });
                      },
                      child: Stack(
                        children: [
                            Container(
                              decoration: BoxDecoration(
                                color:  Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(scannedImages[index]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          // ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: _selectedImages[index]
                                  ? Colors.green.withOpacity(0.8)
                                  : Colors.grey.withOpacity(0.8),
                              child: Icon(
                                _selectedImages[index]
                                    ? Icons.check
                                    : Icons.circle_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        extendBody: true,
        floatingActionButton: scannedImages.isNotEmpty ?

        FloatingActionButton(
          onPressed: () {
            _initScanner();
            _scanDocument();
          },
          // backgroundColor: Colors.orange,
          backgroundColor: Color(0xffcc6600),
          child: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.white),
          shape: const CircleBorder(),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar:
        // scannedImages.isEmpty ? null :
        scannedImages.isEmpty ? null :
        BottomAppBar(
            color: Color(0xffff9933),
            shape: const CircularNotchedRectangle(), // Adds a notch for the centered button
            notchMargin: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  onPressed: _deleteSelectedImages,
                  icon: const Icon(Icons.delete,color: Colors.white ,size: 40,),
                ),

                IconButton(
                  onPressed: _handleButtonPress,
                  icon: const Icon(Icons.share, color: Colors.white,size: 40,),
                ),
              ],
            )
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Do you want to exit the App'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false); //Will not exit the App
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Navigator.of(context).pop(true); //Will exit the App
                SystemNavigator.pop();

              },
            )
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _scanDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _scanner.scanDocument();

      if (result != null && result.images.isNotEmpty) {
        // Use the provider to store scanned images
        final scanDataProvider =
        Provider.of<ScanDataProvider>(context, listen: false);
        scanDataProvider.addScannedImages(result.images);

        // Update the selected images list dynamically
        setState(() {
          _selectedImages = List<bool>.filled(scanDataProvider.scannedImages.length, false);
          _isLoading = false;
        });
      } else {
        _showError('No images found. Please try again.',textColor: Colors.white);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Scan Failed. Please try again later.',textColor: Colors.white);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message, {Color textColor = Colors.white, Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor, // Customize background color
        duration: Duration(seconds: 3), // Optional: Duration for how long the SnackBar is visible
      ),
    );
  }

  // Method to show contact details
  void _showContactUsDialog() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      // path: 'smith@example.com',
      path: 'info@broadsytechnologies.com',
      query: encodeQueryParameters(<String, String>{
        // 'subject': 'Example Subject & Symbols are allowed!',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      launchUrl(emailLaunchUri);
    } else {
      throw Exception('could not launch $emailLaunchUri');
    }
  }

  void _updateButtonText() {
    int selectedCount = _selectedImages.where((isSelected) => isSelected).length;
    setState(() {
      _buttonText = selectedCount == 0 ? 'Share All' : 'Selected Image $selectedCount';
    });
  }

  void _handleButtonPress() {
    if (_selectedImages.contains(true)) {
      _shareSelectedImages();
    } else {
      _shareAllImages();
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final directory = await getTemporaryDirectory();
    final newPath = path.join(directory.path, 'compressed_${imageFile.uri.pathSegments.last}');

    final Uint8List? compressedData = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 75,
    );

    if (compressedData != null) {
      final compressedFile = File(newPath);
      await compressedFile.writeAsBytes(compressedData);
      return compressedFile;
    } else {
      throw Exception('Image compression failed');
    }
  }

  Future<File> _generatePdfFromImages(List<String> imagePaths, String pdfName) async {
    final pdf = pw.Document();

    for (var imagePath in imagePaths) {
      final originalImage = File(imagePath);
      final compressedImage = await _compressImage(originalImage);

      final image = pw.MemoryImage(compressedImage.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final outputFile = File("${outputDir.path}/$pdfName.pdf");
    await outputFile.writeAsBytes(await pdf.save());
    return outputFile;
  }

  void _shareAllImages() async {
    // Access scanned images from ScanDataProvider
    final scannedImages =
        Provider.of<ScanDataProvider>(context, listen: false).scannedImages;

    if (scannedImages.isNotEmpty) {
      _showPdfNameDialog(scannedImages);
    } else {
      _showSnackbar('No images to share');
    }
  }

  //share selected images
  void _shareSelectedImages() async {
    try {
      List<String> selectedImages = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        if (_selectedImages[i]) {
          selectedImages.add(scannedImages[i]);
        }
      }

      if (selectedImages.isNotEmpty) {
        _showPdfNameDialog(selectedImages);
      } else {
        _showSnackbar('No selected images to share.');
      }
    } catch (e) {
      _showSnackbar('Error sharing PDF: $e');
    }
  }

  //pdf name dialog
  void _showPdfNameDialog([List<String>? selectedImages]) {
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter PDF Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "PDF Name",
                      errorText: errorMessage.isEmpty ? null : errorMessage,
                    ),
                    onChanged: (value) {
                      setState(() {
                        errorMessage = value.trim().isEmpty ? 'PDF Name cannot be empty' : '';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) {
                      setState(() {
                        errorMessage = 'PDF Name cannot be empty';
                      });
                      return;
                    }

                    String pdfName = _controller.text.trim();
                    Navigator.of(context).pop(); // Close dialog

                    // Share Only Logic
                    File pdfFile;
                    if (selectedImages != null) {
                      pdfFile = await _generatePdfFromImages(selectedImages, pdfName);
                    } else {
                      pdfFile = await _generatePdfFromImages(scannedImages, pdfName);
                    }

                    bool fileExists = await _doesPdfExist(pdfFile.uri.pathSegments.last);

                    if (!fileExists) {
                      _sharePdf(pdfFile, showDuplicateSnackbar: false); // Share without saving
                    } else {
                      _showSnackbar('A PDF with the same name already exists. Cannot share this file.');
                    }
                  },
                  child: const Text('Share Only'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) {
                      setState(() {
                        errorMessage = 'PDF Name cannot be empty';
                      });
                      return;
                    }

                    String pdfName = _controller.text.trim();
                    Navigator.of(context).pop(); // Close dialog

                    try {
                      // Save & Share Logic
                      File pdfFile;
                      if (selectedImages != null) {
                        pdfFile = await _generatePdfFromImages(selectedImages, pdfName);
                      } else {
                        pdfFile = await _generatePdfFromImages(scannedImages, pdfName);
                      }

                      bool fileExists = await _doesPdfExist(pdfFile.uri.pathSegments.last);

                      if (!fileExists) {
                        // Save the PDF locally
                        await _savePdfLocally(pdfFile, showDuplicateSnackbar: false);

                        // Automatically share the saved PDF
                        _sharePdf(pdfFile, showDuplicateSnackbar: false);
                      } else {
                        // Show duplicate warning if the file already exists
                        _showSnackbar('A PDF with the same name already exists. Cannot save or share this file.');
                      }
                    } catch (e) {
                      // Handle unexpected errors
                      _showSnackbar('An error occurred while saving or sharing: $e');
                    }
                  },
                  child: const Text('Save & Share'),
                ),

              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _doesPdfExist(String pdfName) async {
    final directory = await getApplicationDocumentsDirectory();
    final localPath = path.join(directory.path, pdfName);
    final existingFile = File(localPath);
    return await existingFile.exists();
  }

  Future<void> _savePdfLocally(File pdfFile, {bool showDuplicateSnackbar = true}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = path.join(directory.path, pdfFile.uri.pathSegments.last);

      if (await _doesPdfExist(pdfFile.uri.pathSegments.last)) {
        if (showDuplicateSnackbar) {
          _showSnackbar('A PDF with the same name already exists.');
        }
        return; // Exit without saving
      }

      await pdfFile.copy(localPath);
      // _showSnackbar('PDF saved locally at $localPath');
      _showSnackbar('PDF Saved successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavedPdfScreen()),
      );
    } catch (e) {
      print("Error saving PDF: $e");
      _showSnackbar('Error saving PDF');
    }
  }

  void _sharePdf(File pdfFile, {bool showDuplicateSnackbar = true}) async {
    try {
      if (await _doesPdfExist(pdfFile.uri.pathSegments.last)) {
        if (showDuplicateSnackbar) {
          _showSnackbar('A PDF with the same name already exists.');
        }
        return; // Exit without sharing
      }

      Share.shareXFiles([XFile(pdfFile.path)], text: 'Here is your scanned PDF');
    } catch (e) {
      print("Error sharing PDF: $e");
      _showSnackbar('Error sharing PDF');
    }
  }

  void _deleteSelectedImages() {
    if (_selectedImages.contains(true)) {
      setState(() {
        // widget.scannedImage.removeWhere((image) => _selectedImages[widget.scannedImage.indexOf(image)]);
        scannedImages.removeWhere((image) => _selectedImages[scannedImages.indexOf(image)]);
        _selectedImages = List<bool>.filled(scannedImages.length, false);
        _updateButtonText();
      });
    } else {
      _showSnackbar("Please select at least one image to delete");
    }
  }


  void _showSnackbar(String message,) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

}


