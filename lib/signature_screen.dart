
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import 'dart:ui'; // To use ImageByteFormat


class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late SignatureController _controller;

  double _penWidth = 5;
  Color _penColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // Initialize SignatureController
    _controller = SignatureController(
      penStrokeWidth: _penWidth,
      penColor: _penColor,
      exportBackgroundColor: Colors.transparent,
    );
  }

  // Function to update pen width dynamically
  void _updatePenWidth(double newWidth) {
    setState(() {
      _penWidth = newWidth;
      _controller = SignatureController(
        penStrokeWidth: _penWidth,
        penColor: _penColor,
        exportBackgroundColor: Colors.transparent,
        points: _controller.points  //if use this then change the width for existing Width
      );
    });
  }

  // Function to update pen color dynamically
  void _updatePenColor(Color newColor) {
    setState(() {
      _penColor = newColor;

      _controller = SignatureController(
        penStrokeWidth: _penWidth,
        penColor: _penColor,
        exportBackgroundColor: Colors.transparent,
        points: _controller.points      //if use this then change the color for existing color
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Signature', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor:  isDarkMode ? Colors.black : Color(0xffff9724),
        iconTheme: IconThemeData(
          color:  Colors.white,
        ),
      ),


      // backgroundColor: Colors.orangeAccent[100],
      backgroundColor: Color(0xfffee0bf),
      body: Column(

        children: [
          Expanded(
            child: Signature(
              controller: _controller,
              height: 300,
              backgroundColor: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(

                onPressed: () {
                  _controller.clear(); // Clear the signature if needed
                },

                child: const Text('Clear'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  // Capture the signature as an image (if there is a signature drawn)
                  if (_controller.isNotEmpty) {
                    final signatureImage = await _controller.toImage();

                    if (signatureImage != null) {
                      final byteData = await signatureImage.toByteData(format: ImageByteFormat.png);
                      final uint8List = byteData!.buffer.asUint8List();

                      // Return the signature as Uint8List to the FullImageScreen
                      Navigator.pop(context, uint8List);

                      // Show success message
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Signature saved successfully!')),
                      // );
                      _showSnackBarMessage('Signature saved successfully!', textColor: Colors.white,backgroundColor: Color(0xffF47A00));
                      
                    } else {
                      // Handle the case where the signature is empty or invalid
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Signature is empty!')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No signature drawn yet!')),
                    );
                  }
                },
                child: const Text('Save Signature'),
              ),
            ],
          ),
          // Pen Settings Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Pen Width Slider
                Row(
                  children: [
                    Text("Pen Width: $_penWidth"),
                    Expanded(
                      child: Slider(
                        value: _penWidth,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) {
                          _updatePenWidth(value); // Dynamically update pen width
                        },
                      ),
                    ),
                  ],
                ),
                // Pen Color Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pen Color:"),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.black),
                      onPressed: () {
                        _updatePenColor(Colors.black); // Change to black
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.red),
                      onPressed: () {
                        _updatePenColor(Colors.red); // Change to red
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.blue),
                      onPressed: () {
                        _updatePenColor(Colors.blue); // Change to blue
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.circle, color: Colors.green),
                      onPressed: () {
                        _updatePenColor(Colors.green); // Change to green
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBarMessage(String message ,{Color textColor = Colors.white, backgroundColor = Colors.red }) {
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

