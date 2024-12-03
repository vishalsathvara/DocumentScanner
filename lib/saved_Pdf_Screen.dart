import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'pdf_view_screen.dart';

class SavedPdfScreen extends StatefulWidget {
  @override
  _SavedPdfScreenState createState() => _SavedPdfScreenState();
}

class _SavedPdfScreenState extends State<SavedPdfScreen> {
  List<FileSystemEntity> _savedPdfs = [];
  List<bool> _selectedItems = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedPdfs();
  }

  Future<void> _loadSavedPdfs() async {
    final directory = await getApplicationDocumentsDirectory();

    // Get all files with `.pdf` extension
    final savedPdfs = Directory(directory.path).listSync().where((item) {
      return item.path.endsWith(".pdf");
    }).toList();

    // Sort by creation time (newest first)
    savedPdfs.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified); // Newest first
    });

    // Update the state
    setState(() {
      _savedPdfs = savedPdfs;
      _selectedItems = List<bool>.filled(savedPdfs.length, false);
    });
  }


  // Function to open the PDF file
  void _openPdf(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: filePath),
      ),
    );
  }

  // Function to show confirmation dialog before deleting the PDF
  Future<void> _showDeleteConfirmationDialog(List<FileSystemEntity> filesToTrash) async {
    // Show dialog to confirm deletion
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Do you want to delete these PDFs and move them to trash?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Proceed with moving PDFs to trash if user confirms
      await _moveToTrashConfirmed(filesToTrash);
    }
  }

  // Function to move selected PDFs to the trash folder after confirmation
  Future<void> _moveToTrashConfirmed(List<FileSystemEntity> filesToTrash) async {
    final directory = await getApplicationDocumentsDirectory();
    final trashDirectory = Directory(path.join(directory.path, 'Trash'));

    // Create the trash directory if it doesn't exist
    if (!await trashDirectory.exists()) {
      await trashDirectory.create();
    }

    // Move selected files to the Trash folder
    for (var file in filesToTrash) {
      final newPath = path.join(trashDirectory.path, path.basename(file.path));
      await file.rename(newPath); // Rename (move) the file to Trash folder
    }

    // After moving to trash, update the lists
    setState(() {
      // Remove trashed files from the list
      _savedPdfs = _savedPdfs.where((file) => !filesToTrash.contains(file)).toList();
      _selectedItems = List<bool>.filled(_savedPdfs.length, false); // Clear selection
      _isSelectionMode = false; // Exit selection mode immediately
    });

    // Show Snackbar message after moving files to trash
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected PDFs have been moved to trash'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        // If we exit selection mode, clear all selections
        _selectedItems = List<bool>.filled(_savedPdfs.length, false);
      }
    });
  }

  // Function to cancel selection mode and reset
  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;  // Exit selection mode
      _selectedItems = List<bool>.filled(_savedPdfs.length, false); // Deselect all
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Allow the back button to work normally
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Saved PDFs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          ),

          backgroundColor:  Color(0xffff9724),
          elevation: 4,
          actions: [
            if (!_isSelectionMode)
              IconButton(
                icon: const Icon(Icons.select_all, color: Colors.white),
                onPressed: _toggleSelectionMode,
              ),
            if (_isSelectionMode)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white),
                onPressed: _cancelSelectionMode,
              ),
            if (_isSelectionMode && _selectedItems.contains(true))
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareSelectedPdfs,
              ),
            if (_isSelectionMode && _selectedItems.contains(true))
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  List<FileSystemEntity> filesToTrash = [];
                  for (int i = 0; i < _savedPdfs.length; i++) {
                    if (_selectedItems[i]) {
                      filesToTrash.add(_savedPdfs[i]);
                    }
                  }
                  _showDeleteConfirmationDialog(filesToTrash);
                },
              ),
          ],
        ),
        body: _savedPdfs.isEmpty
            ? 
        // const Center(child: Text('No PDFs saved yet.'))
         Center(
          child: Image.asset('assets/DocumentsImages/NoDocumentFound.png'),
        )
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Adjust the number of columns in the grid
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: _savedPdfs.length,
            itemBuilder: (context, index) {
              final file = _savedPdfs[index];

              // Check if the item is selected
              bool isSelected = _selectedItems[index];

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white, // Background color when selected
                child: InkWell(
                  onTap: () {
                    if (_isSelectionMode) {
                      setState(() {
                        _selectedItems[index] = !_selectedItems[index]; // Toggle selection
                      });
                    } else {
                      _openPdf(file.path); // Open the PDF if not in selection mode
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade400,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        path.basename(file.path),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Function to share the selected PDFs
  void _shareSelectedPdfs() {
    List<String> selectedFiles = [];

    for (int i = 0; i < _savedPdfs.length; i++) {
      if (_selectedItems[i]) {
        selectedFiles.add(_savedPdfs[i].path);
      }
    }

    if (selectedFiles.isNotEmpty) {
      List<XFile> xFiles = selectedFiles.map((filePath) {
        String fileName = path.basename(filePath);
        return XFile(filePath, name: fileName);
      }).toList();

      Share.shareXFiles(xFiles, text: 'Here are your selected PDFs!');
    }
  }
}
