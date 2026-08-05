import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ArchiveImagePicker {
  ArchiveImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<List<File>> showImageSourcePicker({
    required BuildContext context,
    required int remainingCount,
  }) async {
    if (remainingCount <= 0) {
      return [];
    }

    final ImageSource? source =
    await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _ImageSourceBottomSheet(
          onCameraPressed: () {
            Navigator.pop(
              bottomSheetContext,
              ImageSource.camera,
            );
          },
          onGalleryPressed: () {
            Navigator.pop(
              bottomSheetContext,
              ImageSource.gallery,
            );
          },
        );
      },
    );

    if (source == null) {
      return [];
    }

    if (source == ImageSource.camera) {
      final File? image = await _pickFromCamera();

      if (image == null) {
        return [];
      }

      return [image];
    }

    return _pickFromGallery(
      remainingCount: remainingCount,
    );
  }

  static Future<File?> _pickFromCamera() async {
    final XFile? capturedImage =
    await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 95,
      requestFullMetadata: false,
    );

    if (capturedImage == null) {
      return null;
    }

    return _cropToSquare(
      sourcePath: capturedImage.path,
    );
  }

  static Future<List<File>> _pickFromGallery({
    required int remainingCount,
  }) async {
    if (remainingCount <= 0) {
      return [];
    }

    if (remainingCount == 1) {
      final XFile? selectedImage =
      await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        requestFullMetadata: false,
      );

      if (selectedImage == null) {
        return [];
      }

      final File? croppedImage =
      await _cropToSquare(
        sourcePath: selectedImage.path,
      );

      if (croppedImage == null) {
        return [];
      }

      return [croppedImage];
    }

    final List<XFile> selectedImages =
    await _picker.pickMultiImage(
      imageQuality: 95,
      requestFullMetadata: false,
      limit: remainingCount,
    );

    final List<File> croppedImages = [];

    for (final XFile image in selectedImages) {
      if (croppedImages.length >= remainingCount) {
        break;
      }

      final File? croppedImage =
      await _cropToSquare(
        sourcePath: image.path,
      );

      if (croppedImage != null) {
        croppedImages.add(croppedImage);
      }
    }

    return croppedImages;
  }

  static Future<File?> _cropToSquare({
    required String sourcePath,
  }) async {
    final CroppedFile? croppedFile =
    await ImageCropper().cropImage(
      sourcePath: sourcePath,

      // 세로형 3:4
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),

      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,

      // 3:4 비율의 실제 출력 크기
      maxWidth: 1200,
      maxHeight: 1200,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor:
          const Color(0xFF6680FF),
          cropFrameColor: Colors.white,
          cropGridColor: Colors.white54,
          showCropGrid: true,
          hideBottomControls: false,
          lockAspectRatio: true,
          initAspectRatio:
          CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (croppedFile == null) {
      return null;
    }

    return File(croppedFile.path);
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _ImageSourceBottomSheet({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          22,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D5DB),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Photo',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon:
                    Icons.camera_alt_outlined,
                    label: 'Camera',
                    onPressed:
                    onCameraPressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageSourceButton(
                    icon:
                    Icons.photo_library_outlined,
                    label: 'Gallery',
                    onPressed:
                    onGalleryPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4FF),
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E3F1),
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF6680FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}