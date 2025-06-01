import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final void Function(File image)? onImageSelected;
  final String title;
  final bool isLoading;
  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.title = "Upload Image",
    this.isLoading = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _showPickImageDialog() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImageSelected?.call(_selectedImage!);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).inputDecorationTheme.fillColor, // White background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400, // Set border color
          width: 1.0, // Set border width
        ),
      ),
      child: Row(
        children: [
          if (_selectedImage != null)
            widget.isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
          if (_selectedImage != null) const SizedBox(width: 12),
          TextButton.icon(
            onPressed: _showPickImageDialog,
            icon: const Icon(Icons.add_a_photo),
            label: Text(
              widget.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
