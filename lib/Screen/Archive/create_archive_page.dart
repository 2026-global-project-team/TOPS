import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tops/Main/widgets/polaroidCard.dart';
import 'package:tops/services/image_picker.dart';

class CreateArchivePage extends StatefulWidget {
  /// 나중에 카메라 또는 갤러리 기능을 연결할 때 사용한다.
  ///
  /// remainingCount:
  /// 현재 추가 가능한 사진 개수
  ///
  /// 사진이 0장이면 2
  /// 사진이 1장이면 1

  const CreateArchivePage({super.key});

  @override
  State<CreateArchivePage> createState() {
    return _CreateArchivePageState();
  }
}

class _CreateArchivePageState extends State<CreateArchivePage> {
  static const Color _primaryColor = Color(0xFF6680FF);

  static const int _maxImageCount = 2;

  final TextEditingController _titleController = TextEditingController();

  final List<File> _selectedImages = [];

  String? _selectedLocation;
  DateTime? _selectedDate;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_selectedImages.length >= _maxImageCount) {
      _showMessage(
        '사진은 최대 2장까지 추가할 수 있습니다.',
      );
      return;
    }

    final int remainingCount =
        _maxImageCount - _selectedImages.length;

    try {
      final List<File> newImages =
      await ArchiveImagePicker.showImageSourcePicker(
        context: context,
        remainingCount: remainingCount,
      );

      if (!mounted || newImages.isEmpty) {
        return;
      }

      setState(() {
        _selectedImages.addAll(
          newImages.take(remainingCount),
        );
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '사진을 불러오지 못했습니다: '
            '${error.toString()}',
      );
    }
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  void _selectLocation() {
    // 위치 선택 페이지가 생기면
    // 여기에서 Navigator로 연결하면 된다.
    setState(() {
      _selectedLocation = 'London';
    });
  }

  Future<void> _saveArchive() async {
    final String title = _titleController.text.trim();

    if (_selectedImages.isEmpty) {
      _showMessage('사진을 최소 1장 추가해 주세요.');
      return;
    }

    if (title.isEmpty) {
      _showMessage('제목을 입력해 주세요.');
      return;
    }

    if (_selectedLocation == null) {
      _showMessage('위치를 선택해 주세요.');
      return;
    }

    if (_selectedDate == null) {
      _showMessage('날짜를 선택해 주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 나중에 이 부분에서
      // Supabase Story 저장 기능을 호출한다.
      //
      // 예:
      //
      // await StoryService().createStory(
      //   title: title,
      //   location: _selectedLocation!,
      //   visitedAt: _selectedDate!,
      //   images: _selectedImages,
      // );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _showMessage('저장 기능은 나중에 Supabase와 연결합니다.');
    } catch (error) {
      if (!mounted) return;

      _showMessage('저장에 실패했습니다: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _goBack() {
    Navigator.maybePop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // MainShell에서 하단바가 표시되므로
      // 여기에는 bottomNavigationBar를 넣지 않는다.
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildPhotoSelector(),

              const SizedBox(height: 28),

              _buildPolaroidPreview(),

              const SizedBox(height: 28),

              _buildTitleField(),

              const SizedBox(height: 10),

              _buildInformationButton(
                icon: Icons.location_on_outlined,
                text: _selectedLocation ?? 'Add Location',
                hasValue: _selectedLocation != null,
                onTap: _selectLocation,
              ),

              _buildInformationButton(
                icon: Icons.calendar_today_outlined,
                text: _selectedDate == null
                    ? 'Add Date'
                    : _formatDate(_selectedDate!),
                hasValue: _selectedDate != null,
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          InkWell(
            onTap: _goBack,
            borderRadius: BorderRadius.circular(24),
            child: const SizedBox(
              width: 38,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF282828),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 2),

          const Expanded(
            child: Text(
              'Create Archive',
              style: TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6680FF), Color(0xFFA453C8)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveArchive,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(68, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return SizedBox(
      height: 116,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAddPhotoButton(),

          for (int index = 0; index < _selectedImages.length; index++) ...[
            const SizedBox(width: 8),
            _buildSelectedThumbnail(index),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    final bool isFull = _selectedImages.length >= _maxImageCount;

    return InkWell(
      onTap: isFull ? null : _addPhoto,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 114,
        height: 114,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFC8CAD2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isFull
                    ? const Color(0xFFB8BAC2)
                    : const Color(0xFF303033),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),

            const SizedBox(height: 12),

            Text(
              isFull ? '2 / 2' : 'Add Photo',
              style: TextStyle(
                color: isFull
                    ? const Color(0xFFA2A4AC)
                    : const Color(0xFF747474),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedThumbnail(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            _selectedImages[index],
            width: 114,
            height: 114,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 114,
                height: 114,
                color: const Color(0xFFF0F1F6),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF999999),
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: () {
              _removePhoto(index);
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolaroidPreview() {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: _selectedImages.isEmpty
          ? _buildEmptyPolaroid()
          : Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (_selectedImages.length == 2)
                  Transform.translate(
                    offset: const Offset(32, 9),
                    child: Transform.rotate(
                      angle: 0.14,
                      child: PolaroidCard(
                        image: Image.file(_selectedImages[1]),
                        width: 185,
                        height: 235,
                      ),
                    ),
                  ),

                Transform.translate(
                  offset: _selectedImages.length == 2
                      ? const Offset(-18, 0)
                      : Offset.zero,
                  child: Transform.rotate(
                    angle: -0.01,
                    child: PolaroidCard(
                      image: Image.file(_selectedImages[0]),
                      width: 198,
                      height: 245,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyPolaroid() {
    return Center(
      child: Container(
        width: 198,
        height: 245,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 62),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Container(
          color: const Color(0xFFE8E9F2),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: _primaryColor,
            size: 46,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
      decoration: const InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(
          color: Color(0xFF777777),
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD5D7DF)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryColor, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildInformationButton({
    required IconData icon,
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: hasValue ? _primaryColor : const Color(0xFFA8AAB2),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue
                      ? const Color(0xFF555555)
                      : const Color(0xFFA8AAB2),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
