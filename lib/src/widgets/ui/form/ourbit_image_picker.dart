import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'dart:io';

class OurbitImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File? file) onImageSelected;
  final String placeholder;
  final double? width;
  final double? height;

  const OurbitImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.placeholder = 'Pilih Gambar',
    this.width,
    this.height,
  });

  @override
  State<OurbitImagePicker> createState() => _OurbitImagePickerState();
}

class _OurbitImagePickerState extends State<OurbitImagePicker> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load initial image if URL is provided
    if (widget.initialImageUrl != null) {
      // For now, we'll just show the placeholder
      // In a real implementation, you might want to load the image from URL
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        widget.onImageSelected(_selectedImage);
      }
    } catch (e) {
      if (mounted) {
        shadcn.showToast(
          context: context,
          builder: (context, overlay) => shadcn.SurfaceCard(
            child: shadcn.Basic(
              title: const Text('Error'),
              content: Text('Gagal memilih gambar: ${e.toString()}'),
              trailing: OurbitButton.primary(
                onPressed: () => overlay.close(),
                label: 'Tutup',
              ),
            ),
          ),
          location: shadcn.ToastLocation.topCenter,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => shadcn.AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: const Text('Pilih dari mana Anda ingin mengambil gambar'),
        actions: [
          OurbitButton.outline(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            label: 'Galeri',
          ),
          OurbitButton.primary(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            label: 'Kamera',
          ),
        ],
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          width: widget.width ?? 200,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: themeService.isDarkMode 
                  ? shadcn.Theme.of(context).colorScheme.border
                  : shadcn.Theme.of(context).colorScheme.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    // Image Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Remove Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: OurbitButton.ghost(
                        onPressed: _removeImage,
                        label: 'Hapus',
                      ),
                    ),
                    // Loading Overlay
                    if (_isLoading)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: shadcn.CircularProgressIndicator(
                            onSurface: true,
                          ),
                        ),
                      ),
                  ],
                )
              : InkWell(
                  onTap: _isLoading ? null : _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: themeService.isDarkMode 
                          ? shadcn.Theme.of(context).colorScheme.muted
                          : shadcn.Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: shadcn.CircularProgressIndicator(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: themeService.isDarkMode 
                                    ? shadcn.Theme.of(context).colorScheme.mutedForeground
                                    : shadcn.Theme.of(context).colorScheme.mutedForeground,
                              ),
                              const shadcn.Gap(8),
                              Text(
                                widget.placeholder,
                                style: TextStyle(
                                  color: themeService.isDarkMode 
                                      ? shadcn.Theme.of(context).colorScheme.mutedForeground
                                      : shadcn.Theme.of(context).colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
        );
      },
    );
  }
}
