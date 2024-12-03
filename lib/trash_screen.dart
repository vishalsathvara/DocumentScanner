import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'pdf_view_screen.dart';

class TrashScreen extends StatefulWidget {
  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<FileSystemEntity> _trashFiles = [];
  List<bool> _selectedItems = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadTrashFiles();
  }

  Future<void> _loadTrashFiles() async {
    final directory = await getApplicationDocumentsDirectory();

    final trashDirectory = Directory(path.join(directory.path, 'Trash'));

    // If the Trash directory exists, list the files in it
    if (await trashDirectory.exists()) {
      final trashFiles = trashDirectory.listSync().toList();

      setState(() {
        _trashFiles = trashFiles;
        _selectedItems = List<bool>.filled(trashFiles.length, false); // Initialize selection list
      });
    }
  }

  // Function to open the file (in this case, view PDF or handle other file types)
  void _openFile(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: filePath),
      ),
    );
  }

  // Function to show confirmation dialog before restoring selected files
  Future<void> _showRestoreConfirmationDialog(List<FileSystemEntity> filesToRestore) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Restoration'),
          content: Text('Do you want to restore these files?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the restoration
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm restoration
              },
              child: Text('Restore'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Proceed with restoring files if user confirms
      await _restoreSelectedFiles(filesToRestore);
    }
  }

  // Function to restore selected files
  Future<void> _restoreSelectedFiles(List<FileSystemEntity> filesToRestore) async {
    final directory = await getApplicationDocumentsDirectory();
    final restoredFiles = <FileSystemEntity>[];

    for (int i = 0; i < _trashFiles.length; i++) {
      if (_selectedItems[i]) {
        final file = _trashFiles[i];
        final originalPath = path.join(directory.path, path.basename(file.path));
        await file.rename(originalPath); // Move the file back to the documents directory
        restoredFiles.add(file);
      }
    }

    // Update the UI after restoring
    setState(() {
      _trashFiles = _trashFiles.where((file) => !restoredFiles.contains(file)).toList();
      _selectedItems = List<bool>.filled(_trashFiles.length, false); // Clear selection
      _isSelectionMode = false; // Exit selection mode
    });
  }

  // Function to show the confirmation dialog before permanently deleting selected files
  Future<void> _showDeleteConfirmationDialog(List<FileSystemEntity> filesToDelete) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Do you want to permanently delete these files?'),
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
      // Proceed with deleting files if user confirms
      await _deleteSelectedFiles(filesToDelete);
    }
  }

  // Function to permanently delete selected files
  Future<void> _deleteSelectedFiles(List<FileSystemEntity> filesToDelete) async {
    // Delete the selected files permanently
    for (var file in filesToDelete) {
      await file.delete();  // Permanently delete the file
    }

    // Update the UI after deletion
    setState(() {
      _trashFiles = _trashFiles.where((file) => !filesToDelete.contains(file)).toList();
      _selectedItems = List<bool>.filled(_trashFiles.length, false); // Clear selection
      _isSelectionMode = false; // Exit selection mode
    });
  }

  // Toggle selection mode for multiple actions (restore or delete)
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        // Clear selections when exiting selection mode
        _selectedItems = List<bool>.filled(_trashFiles.length, false);
      }
    });
  }

  // Cancel selection mode and reset selection state
  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems = List<bool>.filled(_trashFiles.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xffff9724),
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelSelectionMode,
            ),
          if (_isSelectionMode && _selectedItems.contains(true))
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () {
                // Collect selected files to restore
                List<FileSystemEntity> filesToRestore = [];
                for (int i = 0; i < _trashFiles.length; i++) {
                  if (_selectedItems[i]) {
                    filesToRestore.add(_trashFiles[i]);
                  }
                }

                // Show the confirmation dialog before restoring
                _showRestoreConfirmationDialog(filesToRestore);
              },
            ),
          if (_isSelectionMode && _selectedItems.contains(true))
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Collect selected files to delete
                List<FileSystemEntity> filesToDelete = [];
                for (int i = 0; i < _trashFiles.length; i++) {
                  if (_selectedItems[i]) {
                    filesToDelete.add(_trashFiles[i]);
                  }
                }

                // Show the confirmation dialog before deleting
                _showDeleteConfirmationDialog(filesToDelete);
              },
            ),
        ],
      ),
      body: _trashFiles.isEmpty
          ?
      // const Center(child: Text('No files in trash.'))
      Center(
        child: Image.asset('assets/DocumentsImages/dustbin.png'),
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
          itemCount: _trashFiles.length,
          itemBuilder: (context, index) {
            final file = _trashFiles[index];
            bool isSelected = _selectedItems[index];

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
              child: InkWell(
                onTap: () {
                  if (_isSelectionMode) {
                    setState(() {
                      _selectedItems[index] = !_selectedItems[index]; // Toggle selection
                    });
                  } else {
                    _openFile(file.path); // Open the file if not in selection mode
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
    );
  }
}
