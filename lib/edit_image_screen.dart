import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'signature_screen.dart';

class FullImageScreen extends StatefulWidget {
  final String imagePath;

  FullImageScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _FullImageScreenState createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  Uint8List? _signature;
  Offset _signaturePosition = Offset(100, 100);
  bool _isDragging = false;
  bool _isLoading = false;  // Track loading state
  final GlobalKey _imageKey = GlobalKey();

  final ImagePicker _picker = ImagePicker(); // Initialize the ImagePicker

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Image'),
        backgroundColor:  Color(0xffff9724),

        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _signature != null && !_isLoading
                ? () {
              setState(() {
                _isLoading = true;  // Start loading
              });
              _saveMergedImage();  // Save the merged image
            }
                : null,  // Disable button during loading
          ),
        ],

      ),
      body: Center(
        child: Stack(
          children: [
            Image.file(
              File(widget.imagePath),
              key: _imageKey,
            ),
            if (_signature != null)
              Positioned(
                left: _signaturePosition.dx,
                top: _signaturePosition.dy,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    if (_isDragging) {
                      setState(() {
                        _signaturePosition += details.delta;
                      });
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: Image.memory(
                    _signature!,
                    height: 50,
                    width: 150,
                  ),
                ),
              ),
            // Show the loading indicator if the image is being processed
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final signature = await showDialog<Uint8List?>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Choose Signature Source'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final signature = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignatureScreen(),
                          ),
                        );
                        Navigator.pop(context, signature);
                      },
                      child: Text('Draw Signature'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          final image = await pickedFile.readAsBytes();
                          Navigator.pop(context, image);
                        } else {
                          Navigator.pop(context, null);
                        }
                      },
                      child: Text('Import Signature from Gallery'),
                    ),
                  ],
                ),
              );
            },
          );

          if (signature != null) {
            setState(() {
              _signature = signature;
            });
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<void> _saveMergedImage() async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    try {
      // Decode the original image
      final originalImage = img.decodeImage(File(widget.imagePath).readAsBytesSync());
      if (originalImage == null) throw Exception('Failed to decode the original image.');

      // Decode the signature
      final signatureImage = img.decodeImage(_signature!);
      if (signatureImage == null) throw Exception('Failed to decode the signature.');

      // Get rendered image dimensions
      final renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
      final displayedWidth = renderBox.size.width;
      final displayedHeight = renderBox.size.height;

      // Calculate scaling factors
      final double scaleX = originalImage.width / displayedWidth;
      final double scaleY = originalImage.height / displayedHeight;

      // Map signature position to original image dimensions
      final signatureX = (_signaturePosition.dx * scaleX).toInt();
      final signatureY = (_signaturePosition.dy * scaleY).toInt();

      // Scale signature dimensions
      final scaledSignatureWidth = (150 * scaleX).toInt();
      final scaledSignatureHeight = (50 * scaleY).toInt();
      final resizedSignature = img.copyResize(signatureImage,
          width: scaledSignatureWidth, height: scaledSignatureHeight);

      // Overlay the signature onto the original image
      img.compositeImage(originalImage, resizedSignature, dstX: signatureX, dstY: signatureY);

      // Save the merged image
      final directory = await getApplicationDocumentsDirectory();
      final mergedImagePath = '${directory.path}/merged_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final mergedImageFile = File(mergedImagePath);
      await mergedImageFile.writeAsBytes(img.encodePng(originalImage));

      _showSnackBarMessage('Image saved successfully', textColor: Colors.white, backgroundColor: Color(0xffcc6600));

      // Return the merged image file
      Navigator.pop(context, mergedImageFile);
    } catch (e) {

      _showSnackBarMessage('Error saving image: $e',textColor: Colors.white);
    } finally {
      setState(() {
        _isLoading = false;  // Hide loading indicator after processing
      });
    }
  }

  void _showSnackBarMessage(String message, {Color textColor = Colors.white, Color backgroundColor = Colors.red }) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold
              ),
            ),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: 3),
        )
    );
  }
}
