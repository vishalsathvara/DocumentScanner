import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:   Color(0xffff9724),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            FaqItem(
              question: 'What is the purpose of this document scanner app?',
              // answer: 'This app allows you to scan and digitize physical documents using your phone’s camera. You can then store, view, and share scanned documents in formats like PDF and JPEG.',
              answer: 'This app allows you to scan and digitize physical documents using your phone’s camera. You can then store, view, and share scanned documents in formats like PDF.',
            ),

            FaqItem(
              question: 'What types of documents can I scan?',
              answer: 'You can scan a wide variety of documents, such as receipts, business cards, contracts, invoices, notes, photos, whiteboards, and more.',
            ),

            // FaqItem(
            //   question: 'How much does the app cost?',
            //   answer: 'The app is free to use with essential features. Some advanced features like OCR, document editing, and cloud backup may require a subscription or in-app purchase.',
            // ),
            // FaqItem(
            //   question: 'Does this app have Optical Character Recognition (OCR)?',
            //   answer: 'Yes! Our app uses advanced OCR technology to extract text from scanned documents, making it easy to copy and search the text within your scanned files.',
            // ),

            FaqItem(
              question: 'Can I scan multiple pages into a single document?',
              answer: 'Yes, you can scan multiple pages in a sequence and save them as a single PDF document or multi-page file.',
            ),

            //check Once
            FaqItem(
              question: 'Does the app offer cloud storage integration?',
              answer: 'Yes, you can back up your scanned documents directly to cloud services like Google Drive, Dropbox, or OneDrive to ensure your files are safely stored and accessible anywhere.',
            ),


            FaqItem(
              question: 'Can I edit my scanned documents?',
              // answer: 'Absolutely! You can crop, rotate, adjust brightness/contrast, and even delete pages within a multi-page scan. For text documents, OCR also allows you to edit text directly.',
              answer: 'Absolutely! You can crop, rotate, adjust  and even delete pages within a multi-page scan.',
            ),
            // FaqItem(
            //   question: 'What file formats can I export my scanned documents in?',
            //   answer: 'You can export your scanned documents as PDF, JPEG, PNG, and text files (for OCR-supported documents).',
            // ),
            // FaqItem(
            //   question: 'How secure are my scanned documents?',
            //   answer: 'Your documents are securely stored on your device, and if cloud storage is enabled, we use advanced encryption protocols to keep your data safe and private.',
            // ),

            FaqItem(
              question: 'How do I scan a document?',
              answer: 'Simply tap the "Scan" button, position your camera over the document, and let the app automatically capture the image. You can also manually take the image if preferred.',
            ),

            FaqItem(
              question: 'Can I share my scanned documents directly from the app?',
              answer: 'Yes, you can easily share your scanned files via email, social media, messaging apps, or directly to cloud services like Google Drive or Dropbox.',
            ),

            //check once
            FaqItem(
              question: 'How do I organize my scanned documents?',
              answer: 'You can organize your scans into folders, add tags for easy categorization, and search by document name or tags to quickly find your files.',
            ),

            FaqItem(
              question: 'Why is my scan quality low?',
              answer: 'To improve scan quality, ensure good lighting and a clear, non-obstructed view of the document. You can also adjust the brightness and contrast for better results.',
            ),

            // FaqItem(
            //   question: 'OCR is not recognizing the text correctly. What should I do?',
            //   answer: 'OCR accuracy depends on the quality of the scan. Ensure the document is well-lit, free of shadows, and the text is clear. Higher resolution scans typically provide better OCR results.',
            // ),

            FaqItem(
              question: 'I cannot save or share my scanned document. What do I do?',
              answer: 'Make sure your device has enough storage space and that the app has the necessary permissions for saving or sharing files. Check your internet connection if you\'re trying to upload or share via the drive.',
            ),
          ],
        ),
      ),
    );
  }
}

//Class FaqItem
class FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
