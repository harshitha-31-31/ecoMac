import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';

class ExportService {
  static final ExportService instance = ExportService._init();

  ExportService._init();

  // Export and share via WhatsApp
  Future<void> shareToWhatsApp() async {
    try {
      final text = await DatabaseService.instance.exportToText();

      await Share.share(
        text,
        subject: 'Ecomac AI Chat Export',
      );
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
      throw Exception('Failed to share: $e');
    }
  }

  // Request storage permissions
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 10+ (API 29+), use MANAGE_EXTERNAL_STORAGE for full access
      // or use scoped storage approach
      var storageStatus = await Permission.storage.status;
      var manageExternalStatus = await Permission.manageExternalStorage.status;

      if (storageStatus.isGranted || manageExternalStatus.isGranted) {
        return true;
      }

      // Request storage permission first
      storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // If storage permission denied, try manage external storage
      manageExternalStatus = await Permission.manageExternalStorage.request();
      if (manageExternalStatus.isGranted) {
        return true;
      }

      // Check if permanently denied
      if (storageStatus.isPermanentlyDenied || manageExternalStatus.isPermanentlyDenied) {
        throw Exception('Storage permission permanently denied. Please enable in app settings.');
      }

      return false;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app documents
      return true;
    }
    return false;
  }

  // Save to device storage (Downloads folder)
  Future<String> saveToDevice() async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final text = await DatabaseService.instance.exportToText();
      final csv = await DatabaseService.instance.exportToCSV();

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Save text file
      final textFile = File('${directory.path}/ecomac_chat_$timestamp.txt');
      await textFile.writeAsString(text);

      // Save CSV file
      final csvFile = File('${directory.path}/ecomac_chat_$timestamp.csv');
      await csvFile.writeAsString(csv);

      // Also try to save to Downloads folder
      final downloadsPath = await _saveToDownloads(text, csv, timestamp);

      if (downloadsPath != null) {
        return 'Chat saved successfully!\nDownloads: $downloadsPath';
      }

      return 'Chat saved successfully!\nLocation: ${directory.path}';
    } catch (e) {
      debugPrint('Error saving to device: $e');
      throw Exception('Failed to save: $e');
    }
  }

  // Try to save to Downloads folder
  Future<String?> _saveToDownloads(String text, String csv, int timestamp) async {
    try {
      if (Platform.isAndroid) {
        // Try multiple possible download paths
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/sdcard/Download',
          '/storage/emulated/0/Downloads',
        ];

        for (final path in possiblePaths) {
          final downloadsDir = Directory(path);
          try {
            if (downloadsDir.existsSync()) {
              final textFile = File('${downloadsDir.path}/EcomacChat_$timestamp.txt');
              await textFile.writeAsString(text);

              final csvFile = File('${downloadsDir.path}/EcomacChat_$timestamp.csv');
              await csvFile.writeAsString(csv);

              return downloadsDir.path;
            }
          } catch (e) {
            debugPrint('Could not save to $path: $e');
            continue;
          }
        }
      } else if (Platform.isIOS) {
        // On iOS, files are saved to app documents and can be accessed via Files app
        final directory = await getApplicationDocumentsDirectory();
        final textFile = File('${directory.path}/EcomacChat_$timestamp.txt');
        await textFile.writeAsString(text);
        return directory.path;
      }
    } catch (e) {
      debugPrint('Could not save to Downloads: $e');
    }
    return null;
  }

  // Share files directly (opens system share sheet)
  Future<void> shareFiles() async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Export data
      final text = await DatabaseService.instance.exportToText();
      final csv = await DatabaseService.instance.exportToCSV();

      // Create temporary files
      final textFile = File('${directory.path}/ecomac_chat_$timestamp.txt');
      await textFile.writeAsString(text);

      final csvFile = File('${directory.path}/ecomac_chat_$timestamp.csv');
      await csvFile.writeAsString(csv);

      // Share the files
      await Share.shareXFiles(
        [
          XFile(textFile.path),
          XFile(csvFile.path),
        ],
        subject: 'Ecomac AI Chat Export',
        text: 'Here is my chat with Ecomac AI',
      );
    } catch (e) {
      debugPrint('Error sharing files: $e');
      throw Exception('Failed to share files: $e');
    }
  }

  // Get chat statistics
  Future<Map<String, dynamic>> getChatStatistics() async {
    final messages = await DatabaseService.instance.getAllMessages();

    final userMessages = messages.where((m) => m.isUser).toList();
    final aiMessages = messages.where((m) => !m.isUser).toList();

    return {
      'total': messages.length,
      'user': userMessages.length,
      'ai': aiMessages.length,
    };
  }
}
