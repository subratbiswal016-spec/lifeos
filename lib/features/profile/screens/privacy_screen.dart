import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _isExporting = false;

  Future<void> _downloadMyData() async {
    setState(() => _isExporting = true);

    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.dio.get(ApiEndpoints.exportData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final exportedData = response.data['data'];
        final jsonString = const JsonEncoder.withIndent('  ').convert(exportedData);

        // Get the downloads / documents directory
        Directory? directory;
        if (Platform.isAndroid) {
          // Android: Use the app-specific external downloads directory (no permissions needed)
          final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (dirs != null && dirs.isNotEmpty) {
            directory = dirs.first;
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          // On Windows, macOS, Linux, getDownloadsDirectory() is supported
          directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/lifeos_data_$timestamp.json';
        final file = File(filePath);
        await file.writeAsString(jsonString);

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Data Exported!')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your data has been saved successfully.',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.document, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filePath.split('/').last,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved to: ${directory?.path}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to export data');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error exporting data: ${e.toString().substring(0, 50)}');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final dialogTheme = Theme.of(context);
          final isDark = dialogTheme.brightness == Brightness.dark;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: dialogTheme.colorScheme.surface,
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Iconsax.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Iconsax.lock_1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Iconsax.password_check),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDialogLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogTheme.colorScheme.primary,
                  foregroundColor: dialogTheme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isDialogLoading
                    ? null
                    : () async {
                        final currentPwd = currentPasswordController.text;
                        final newPwd = newPasswordController.text;
                        final confirmPwd = confirmPasswordController.text;

                        if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please fill all fields');
                          return;
                        }

                        if (newPwd.length < 6) {
                          Fluttertoast.showToast(msg: 'New password must be at least 6 characters');
                          return;
                        }

                        if (newPwd != confirmPwd) {
                          Fluttertoast.showToast(msg: 'New passwords do not match');
                          return;
                        }

                        setDialogState(() => isDialogLoading = true);

                        try {
                          final dioClient = ref.read(dioClientProvider);
                          await dioClient.dio.post(
                            ApiEndpoints.changePassword,
                            data: {
                              'oldPassword': currentPwd,
                              'newPassword': newPwd,
                            },
                          );

                          Fluttertoast.showToast(
                            msg: 'Password changed successfully!',
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );

                          if (mounted) {
                            Navigator.pop(ctx);
                          }
                        } on DioException catch (e) {
                          setDialogState(() => isDialogLoading = false);
                          final msg = e.response?.data['message'] ?? e.message ?? 'Failed to change password';
                          Fluttertoast.showToast(msg: msg);
                        } catch (e) {
                          setDialogState(() => isDialogLoading = false);
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                child: isDialogLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text('Change'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionItem(
            theme,
            Iconsax.password_check,
            'Change Password',
            'Update your account password',
            onTap: _showChangePasswordDialog,
          ),
          const SizedBox(height: 16),
          _buildActionItem(theme, Icons.fingerprint, 'Biometric Login', 'Enable fingerprint or face unlock'),
          const SizedBox(height: 32),
          Text('Data Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionItem(
            theme,
            Iconsax.document_download,
            'Download My Data',
            'Get a copy of all your health logs',
            onTap: _downloadMyData,
            isLoading: _isExporting,
          ),
          const SizedBox(height: 16),
          _buildActionItem(theme, Iconsax.trash, 'Delete Account', 'Permanently remove your account and data', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;
    return InkWell(
      onTap: isLoading ? null : (onTap ?? () {}),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isDestructive ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  )
                : Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(
                    isLoading ? 'Exporting your data...' : subtitle,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!isLoading) Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
