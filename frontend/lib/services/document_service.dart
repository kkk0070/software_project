import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'storage_service.dart';

class DocumentService {
  // Helper function to get MIME type from file extension
  static String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Upload document
  static Future<Map<String, dynamic>> uploadDocument({
    required File file,
    required String documentType,
    String? description,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        if (kDebugMode) {
          print('[ERROR] Document Upload: No authentication token found');
        }
        return {'success': false, 'message': 'No authentication token found'};
      }

      if (kDebugMode) {
        print('🔵 Document Upload: Starting upload...');
        print('   - File: ${file.path}');
        print('   - Type: $documentType');
        print('   - URL: ${ApiConfig.documentsUrl}/upload');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.documentsUrl}/upload'),
      );

      // Add headers
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
          contentType: MediaType.parse(_getMimeType(file.path)),
        ),
      );

      // Add fields
      request.fields['document_type'] = documentType;
      if (description != null) {
        request.fields['description'] = description;
      }

      if (kDebugMode) {
        print('🔵 Document Upload: Sending request...');
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('🔵 Document Upload: Response received');
        print('   - Status Code: ${response.statusCode}');
        print('   - Body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        if (kDebugMode) {
          print('[SUCCESS] Document Upload: Success!');
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Document uploaded successfully',
          'document': data['data'],
        };
      } else {
        if (kDebugMode) {
          print('[ERROR] Document Upload: Failed - ${data['message']}');
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload document',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] Document Upload: Exception - ${e.toString()}');
      }
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // Upload document from bytes (used for web, but works on any platform)
  static Future<Map<String, dynamic>> uploadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    required String documentType,
    String? description,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        if (kDebugMode) {
          print('[ERROR] Document Upload: No authentication token found');
        }
        return {'success': false, 'message': 'No authentication token found'};
      }

      if (kDebugMode) {
        print('🔵 Document Upload (Web): Starting upload...');
        print('   - File: $fileName');
        print('   - Type: $documentType');
        print('   - Size: ${bytes.length} bytes');
        print('   - URL: ${ApiConfig.documentsUrl}/upload');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.documentsUrl}/upload'),
      );

      // Add headers
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add file from bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'document',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(_getMimeType(fileName)),
        ),
      );

      // Add fields
      request.fields['document_type'] = documentType;
      if (description != null) {
        request.fields['description'] = description;
      }

      if (kDebugMode) {
        print('🔵 Document Upload (Web): Sending request...');
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('🔵 Document Upload (Web): Response received');
        print('   - Status Code: ${response.statusCode}');
        print('   - Body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        if (kDebugMode) {
          print('[SUCCESS] Document Upload (Web): Success!');
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Document uploaded successfully',
          'document': data['data'],
        };
      } else {
        if (kDebugMode) {
          print('[ERROR] Document Upload (Web): Failed - ${data['message']}');
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload document',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] Document Upload (Web): Exception - ${e.toString()}');
      }
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // Get user's documents
  static Future<Map<String, dynamic>> getUserDocuments() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.documentsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'documents': data['data'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch documents',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Delete document
  static Future<Map<String, dynamic>> deleteDocument(int documentId) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.documentsUrl}/$documentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Document deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete document',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Download document URL
  static String getDownloadUrl(int documentId) {
    return '${ApiConfig.documentsUrl}/$documentId/download';
  }
}
