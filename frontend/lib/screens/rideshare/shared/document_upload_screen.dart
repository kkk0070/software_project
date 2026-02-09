import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../services/document_service.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DocumentService.getUserDocuments();
      
      if (result['success'] == true) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(result['documents'] ?? []);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load documents'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadDocument(String documentType) async {
    try {
      if (kDebugMode) {
        print('🔵 Picking document for type: $documentType');
      }
      
      // Pick file with withData: true for web compatibility
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        withData: true, // 🔴 REQUIRED for web
      );

      if (result != null) {
        final pickedFile = result.files.single;
        final fileName = pickedFile.name;
        
        if (kDebugMode) {
          print('🔵 File selected: $fileName');
          print('   - Size: ${pickedFile.size} bytes');
          if (!kIsWeb && pickedFile.path != null) {
            print('   - Path: ${pickedFile.path}');
          }
        }

        if (kDebugMode) {
          print('🔵 Document type selected: $documentType');
        }

        setState(() {
          _isUploading = true;
        });

        // Upload document with platform-safe approach
        Map<String, dynamic> uploadResult;
        
        if (kIsWeb) {
          // ✅ Web: Use bytes
          if (pickedFile.bytes == null) {
            throw Exception('File bytes not available on web');
          }
          uploadResult = await DocumentService.uploadDocumentFromBytes(
            bytes: pickedFile.bytes!,
            fileName: fileName,
            documentType: documentType,
            description: fileName,
          );
        } else {
          // ✅ Mobile/Desktop: Use file path
          if (pickedFile.path == null) {
            throw Exception('File path not available');
          }
          final file = File(pickedFile.path!);
          uploadResult = await DocumentService.uploadDocument(
            file: file,
            documentType: documentType,
            description: fileName,
          );
        }

        if (!mounted) return;

        if (uploadResult['success'] == true) {
          if (kDebugMode) {
            print('[SUCCESS] Document uploaded successfully');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          
          // Reload documents
          await _loadDocuments();
        } else {
          if (kDebugMode) {
            print('[ERROR] Document upload failed: ${uploadResult['message']}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadResult['message'] ?? 'Upload failed'),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('🔵 No file selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] Error in _pickAndUploadDocument: ${e.toString()}');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Get icon for document category
  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'Driver License':
        return Icons.badge;
      case 'Vehicle Registration':
        return Icons.car_rental;
      case 'Insurance':
        return Icons.shield;
      case 'ID Card':
        return Icons.credit_card;
      case 'Other':
        return Icons.folder;
      default:
        return Icons.description;
    }
  }

  // Build category card for document type selection
  Widget _buildCategoryCard(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Check if this category already has a document uploaded
    final hasDocument = _documents.any((doc) => doc['document_type'] == type);
    
    return InkWell(
      onTap: _isUploading ? null : () => _pickAndUploadDocument(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDocument 
                ? AppTheme.primaryGreen
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: hasDocument ? 2 : 1,
          ),
          boxShadow: [
            if (hasDocument)
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(type),
                color: AppTheme.primaryGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasDocument) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocument(int documentId, int index) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
          title: Text(
            'Delete Document',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete this document?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await DocumentService.deleteDocument(documentId);
        
        if (!mounted) return;

        if (result['success'] == true) {
          setState(() {
            _documents.removeAt(index);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Delete failed'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Documents',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Status
                  if (_isUploading)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Uploading document...',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section: Upload Documents
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Documents',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a category to upload your document',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Category Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            FadeInUp(
                              delay: const Duration(milliseconds: 0),
                              child: _buildCategoryCard('Driver License'),
                            ),
                            FadeInUp(
                              delay: const Duration(milliseconds: 50),
                              child: _buildCategoryCard('Vehicle Registration'),
                            ),
                            FadeInUp(
                              delay: const Duration(milliseconds: 100),
                              child: _buildCategoryCard('Insurance'),
                            ),
                            FadeInUp(
                              delay: const Duration(milliseconds: 150),
                              child: _buildCategoryCard('ID Card'),
                            ),
                            FadeInUp(
                              delay: const Duration(milliseconds: 200),
                              child: _buildCategoryCard('Other'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Section: Uploaded Documents
                  if (_documents.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Uploaded Documents',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _documents.length,
                            itemBuilder: (context, index) {
                              return FadeInUp(
                                delay: Duration(milliseconds: 50 * index),
                                child: _buildDocumentCard(_documents[index], index),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final documentType = document['document_type'] ?? 'Other';
    final fileName = document['file_name'] ?? 'Unknown';
    final fileSize = document['file_size'] ?? 0;
    final uploadedAt = document['uploaded_at'] ?? '';
    final status = document['status'] ?? 'Pending';

    // Format file size
    String formattedSize = '';
    if (fileSize > 1024 * 1024) {
      formattedSize = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (fileSize > 1024) {
      formattedSize = '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      formattedSize = '$fileSize bytes';
    }

    // Format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(uploadedAt);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      formattedDate = 'Unknown date';
    }

    // Status color
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Approved':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getDocumentIcon(fileName),
            color: AppTheme.primaryGreen,
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  documentType,
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$formattedSize • $formattedDate',
              style: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: status != 'Approved'
            ? IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                onPressed: () => _deleteDocument(document['id'], index),
              )
            : null,
      ),
    );
  }

  IconData _getDocumentIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
