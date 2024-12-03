import 'package:flutter/material.dart';

class ScanDataProvider extends ChangeNotifier {
  List<String> _scannedImages = [];

  List<String> get scannedImages => _scannedImages;

  void addScannedImages(List<String> images) {
    _scannedImages.addAll(images);
    notifyListeners();
  }

  void clearScannedImages() {
    _scannedImages.clear();
    notifyListeners();
  }
}
