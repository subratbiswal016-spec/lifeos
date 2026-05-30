import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.dio.get(ApiEndpoints.profile);
  if (response.data['success'] == true) {
    return response.data['data'];
  }
  throw Exception('Failed to load profile');
});

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = false;
  
  String? _base64Image;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.dio.put(
        ApiEndpoints.profile,
        data: {
          'name': _nameController.text,
          'email': _emailController.text,
          'city': _cityController.text,
          'monthlyBudget': int.tryParse(_budgetController.text) ?? 0,
          if (_base64Image != null) 'profilePhotoUrl': _base64Image,
        },
      );
      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated')));
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        // Error is handled by DioClient interceptor toast, but we can also show here if needed
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _base64Image = base64String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profileData) {
          // Initialize controllers only once
          if (_nameController.text.isEmpty && profileData['name'] != null) {
            _nameController.text = profileData['name'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _cityController.text = profileData['city'] ?? '';
            _budgetController.text = profileData['monthlyBudget']?.toString() ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          image: _base64Image != null || profileData['profilePhotoUrl'] != null
                              ? DecorationImage(
                                  image: _base64Image != null
                                      ? MemoryImage(base64Decode(_base64Image!.split(',').last)) as ImageProvider
                                      : (profileData['profilePhotoUrl'].startsWith('data:image') 
                                          ? MemoryImage(base64Decode(profileData['profilePhotoUrl'].split(',').last)) 
                                          : NetworkImage(profileData['profilePhotoUrl'])) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                                  fit: BoxFit.cover,
                                ),
                          border: Border.all(color: theme.colorScheme.primary, width: 4),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(theme, 'Full Name', _nameController),
                const SizedBox(height: 16),
                _buildTextField(theme, 'Email Address', _emailController),
                const SizedBox(height: 16),
                _buildTextField(theme, 'City', _cityController),
                const SizedBox(height: 16),
                _buildTextField(theme, 'Monthly Budget (₹)', _budgetController, keyboardType: TextInputType.number),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
