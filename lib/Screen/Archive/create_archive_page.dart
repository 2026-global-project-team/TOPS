import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/widgets/polaroidCard.dart';

import '../Explore/pages/explore_page.dart';
import '../../services/image_picker.dart';
import '../../services/story_service.dart';

class CreateArchivePage extends StatefulWidget {
  const CreateArchivePage({
    super.key,
  });

  @override
  State<CreateArchivePage> createState() {
    return _CreateArchivePageState();
  }
}

class _CreateArchivePageState
    extends State<CreateArchivePage> {
  static const Color _primaryColor =
  Color(0xFF6680FF);

  static const int _maxImageCount = 2;

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController
  _descriptionController =
  TextEditingController();

  final List<File> _selectedImages = [];

  /*
   * ExplorePage에서 선택한 places 테이블의
   * 매장 정보가 저장된다.
   *
   * 예상 데이터:
   * id
   * name
   * address
   * city
   * latitude
   * longitude
   * category
   * image_url
   */
  Map<String, dynamic>? _selectedPlace;

  DateTime? _selectedDate;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // 사진 추가
  // ============================================================

  Future<void> _addPhoto() async {
    if (_selectedImages.length >=
        _maxImageCount) {
      _showMessage(
        'You can add up to 2 photos.',
      );

      return;
    }

    final int remainingCount =
        _maxImageCount -
            _selectedImages.length;

    try {
      final List<File> newImages =
      await ArchiveImagePicker
          .showImageSourcePicker(
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
    } catch (error, stackTrace) {
      debugPrint(
        'Archive image picker error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to load the photo.',
      );
    }
  }

  // ============================================================
  // 선택한 사진 삭제
  // ============================================================

  void _removePhoto(int index) {
    if (index < 0 ||
        index >= _selectedImages.length) {
      return;
    }

    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ============================================================
  // 날짜 선택
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate:
      _selectedDate ?? DateTime.now(),
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

  // ============================================================
  // 소상공인 매장 선택
  //
  // 기존 ExplorePage를 선택 모드로 연다.
  // 지도에서 매장을 선택한 뒤 Select Place를 누르면
  // places 테이블의 매장 정보가 반환된다.
  // ============================================================

  Future<void> _selectLocation() async {
    final Map<String, dynamic>? selectedPlace =
    await Navigator.push<
        Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const ExplorePage(
            isPlaceSelectionMode: true,
          );
        },
      ),
    );

    if (selectedPlace == null || !mounted) {
      return;
    }

    setState(() {
      _selectedPlace =
      Map<String, dynamic>.from(
        selectedPlace,
      );
    });
  }

  // ============================================================
  // Archive 저장
  //
  // 실제 Supabase 구조:
  //
  // stories
  // - user_id
  // - place_id
  // - title
  // - content
  // - location
  // - visited_at
  //
  // StoryService 내부:
  // - story-images Storage 업로드
  // - story_images.story_id 저장
  // - story_images.image_path 저장
  // - story_images.display_order 저장
  // ============================================================

  Future<void> _saveArchive() async {
    if (_isSaving) {
      return;
    }

    final String title =
    _titleController.text.trim();

    /*
     * 화면 변수명은 descriptionController지만
     * Supabase stories 테이블에는
     * description이 아닌 content 컬럼으로 저장한다.
     */
    final String content =
    _descriptionController.text.trim();

    if (_selectedImages.isEmpty) {
      _showMessage(
        'Please add at least one photo.',
      );

      return;
    }

    if (title.isEmpty) {
      _showMessage(
        'Please enter a title.',
      );

      return;
    }

    if (_selectedPlace == null) {
      _showMessage(
        'Please select a local place.',
      );

      return;
    }

    /*
     * places.id와 stories.place_id는
     * 모두 int8이므로 int로 변환한다.
     */
    final int? placeId = int.tryParse(
      _selectedPlace!['id']
          ?.toString()
          .trim() ??
          '',
    );

    if (placeId == null) {
      _showMessage(
        'The selected place is invalid.',
      );

      return;
    }

    if (_selectedDate == null) {
      _showMessage(
        'Please add a date.',
      );

      return;
    }

    if (content.isEmpty) {
      _showMessage(
        'Please share your experience.',
      );

      return;
    }

    /*
     * stories.location에 저장할 문자열.
     *
     * places 데이터에서 매장 이름, 주소, 도시를 조합한다.
     */
    final String location =
    _buildSelectedPlaceLocation();

    if (location.isEmpty) {
      _showMessage(
        'The selected place has no location information.',
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final int storyId =
      await StoryService.createStory(
        title: title,
        content: content,
        placeId: placeId,
        location: location,
        visitedAt: _selectedDate!,
        images: List<File>.from(
          _selectedImages,
        ),
      );

      debugPrint(
        'Archive saved successfully. '
            'storyId: $storyId',
      );

      if (!mounted) {
        return;
      }

      /*
       * true를 ArchivePage로 반환한다.
       *
       * ArchivePage에서는 true를 받은 경우
       * Supabase stories 목록을 다시 조회하면 된다.
       */
      Navigator.pop(context, true);
    } on AuthException catch (error) {
      debugPrint(
        'Archive authentication error: '
            '${error.message}',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        error.message,
      );
    } on StorageException catch (error) {
      debugPrint(
        '========== STORAGE ERROR ==========',
      );

      debugPrint(
        'message: ${error.message}',
      );

      debugPrint(
        'statusCode: ${error.statusCode}',
      );

      debugPrint(
        'error: ${error.error}',
      );

      debugPrint(
        '===================================',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Storage Error: ${error.message}',
      );
    } on PostgrestException catch (error) {
      debugPrint(
        '========== STORY DB ERROR ==========',
      );

      debugPrint(
        'message: ${error.message}',
      );

      debugPrint(
        'details: ${error.details}',
      );

      debugPrint(
        'hint: ${error.hint}',
      );

      debugPrint(
        'code: ${error.code}',
      );

      debugPrint(
        '====================================',
      );

      if (!mounted) {
        return;
      }

      /*
       * 개발 중에는 실제 오류 내용을 표시해서
       * 컬럼 또는 RLS 문제를 바로 확인한다.
       *
       * 배포 전에는 일반 메시지로 바꾸는 것이 좋다.
       */
      _showMessage(
        'DB Error: ${error.message}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========== CREATE ARCHIVE ERROR ==========',
      );

      debugPrint(
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      debugPrint(
        '==========================================',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Save Error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // 선택한 장소 문자열 생성
  // ============================================================

  String _buildSelectedPlaceLocation() {
    final Map<String, dynamic>? place =
        _selectedPlace;

    if (place == null) {
      return '';
    }

    final String name =
        place['name']?.toString().trim() ??
            '';

    final String address =
        place['address']
            ?.toString()
            .trim() ??
            '';

    final String city =
        place['city']?.toString().trim() ??
            '';

    final List<String> values =
    <String>[
      name,
      address,
      city,
    ].where(
          (String value) {
        return value.isNotEmpty;
      },
    ).toList();

    return values.join(', ');
  }

  // ============================================================
  // Create Archive 화면에 표시할 장소 문자열
  // ============================================================

  String _getSelectedPlaceText() {
    final Map<String, dynamic>? place =
        _selectedPlace;

    if (place == null) {
      return 'Add Location';
    }

    final String name =
        place['name']?.toString().trim() ??
            '';

    final String address =
        place['address']
            ?.toString()
            .trim() ??
            '';

    final String city =
        place['city']?.toString().trim() ??
            '';

    final List<String> values =
    <String>[
      name,
      address,
      city,
    ].where(
          (String value) {
        return value.isNotEmpty;
      },
    ).toList();

    if (values.isEmpty) {
      return 'Selected Place';
    }

    return values.join(' · ');
  }

  void _goBack() {
    Navigator.maybePop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final String day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    return '${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /*
       * MainShell에서 하단바가 표시되므로
       * 여기에 bottomNavigationBar를 넣지 않는다.
       */
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            150,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
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
                icon:
                Icons.location_on_outlined,
                text:
                _getSelectedPlaceText(),
                hasValue:
                _selectedPlace != null,
                onTap: _selectLocation,
              ),

              _buildInformationButton(
                icon:
                Icons.calendar_today_outlined,
                text: _selectedDate == null
                    ? 'Add Date'
                    : _formatDate(
                  _selectedDate!,
                ),
                hasValue:
                _selectedDate != null,
                onTap: _selectDate,
              ),

              const SizedBox(height: 18),

              _buildDescriptionField(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 상단 Header
  // ============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          InkWell(
            onTap: _goBack,
            borderRadius:
            BorderRadius.circular(24),
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
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  Color(0xFF6680FF),
                  Color(0xFFA453C8),
                ],
              ),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : _saveArchive,
              style:
              ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                Colors.transparent,
                disabledBackgroundColor:
                Colors.transparent,
                shadowColor:
                Colors.transparent,
                minimumSize:
                const Size(68, 44),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(9),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 설명 입력
  // ============================================================

  Widget _buildDescriptionField() {
    return TextField(
      controller:
      _descriptionController,
      keyboardType:
      TextInputType.multiline,
      textInputAction:
      TextInputAction.newline,
      minLines: 4,
      maxLines: 7,
      maxLength: 500,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 17,
        height: 1.4,
      ),
      decoration:
      const InputDecoration(
        hintText:
        'Share your experience...',
        hintStyle: TextStyle(
          color: Color(0xFFA8AAB2),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        counterText: '',
        contentPadding:
        EdgeInsets.symmetric(
          vertical: 10,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  // ============================================================
  // 사진 선택 영역
  // ============================================================

  Widget _buildPhotoSelector() {
    return SizedBox(
      height: 116,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAddPhotoButton(),

          for (
          int index = 0;
          index <
              _selectedImages.length;
          index++
          ) ...[
            const SizedBox(width: 8),

            _buildSelectedThumbnail(
              index,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    final bool isFull =
        _selectedImages.length >=
            _maxImageCount;

    return InkWell(
      onTap: isFull ? null : _addPhoto,
      borderRadius:
      BorderRadius.circular(15),
      child: Container(
        width: 114,
        height: 114,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
            color:
            const Color(0xFFC8CAD2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isFull
                    ? const Color(
                  0xFFB8BAC2,
                )
                    : const Color(
                  0xFF303033,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isFull
                  ? '2 / 2'
                  : 'Add Photo',
              style: TextStyle(
                color: isFull
                    ? const Color(
                  0xFFA2A4AC,
                )
                    : const Color(
                  0xFF747474,
                ),
                fontSize: 14,
                fontWeight:
                FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedThumbnail(
      int index,
      ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(15),
          child: Image.file(
            _selectedImages[index],
            width: 114,
            height: 114,
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return Container(
                width: 114,
                height: 114,
                color: const Color(
                  0xFFF0F1F6,
                ),
                alignment:
                Alignment.center,
                child: const Icon(
                  Icons
                      .broken_image_outlined,
                  color: Color(
                    0xFF999999,
                  ),
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
            customBorder:
            const CircleBorder(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(
                  alpha: 0.65,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 폴라로이드 미리보기
  // ============================================================

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
          if (_selectedImages.length ==
              2)
            Transform.translate(
              offset:
              const Offset(32, 9),
              child: Transform.rotate(
                angle: 0.14,
                child: PolaroidCard(
                  image: Image.file(
                    _selectedImages[1],
                    fit: BoxFit.cover,
                  ),
                  width: 185,
                  height: 235,
                ),
              ),
            ),

          Transform.translate(
            offset:
            _selectedImages.length ==
                2
                ? const Offset(
              -18,
              0,
            )
                : Offset.zero,
            child: Transform.rotate(
              angle: -0.01,
              child: PolaroidCard(
                image: Image.file(
                  _selectedImages[0],
                  fit: BoxFit.cover,
                ),
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
        padding:
        const EdgeInsets.fromLTRB(
          14,
          14,
          14,
          62,
        ),
        decoration: BoxDecoration(
          color:
          const Color(0xFFF7F4FF),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: 0.18,
              ),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Container(
          color:
          const Color(0xFFE8E9F2),
          alignment: Alignment.center,
          child: const Icon(
            Icons
                .add_photo_alternate_outlined,
            color: _primaryColor,
            size: 46,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 제목 입력
  // ============================================================

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      textInputAction:
      TextInputAction.done,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
      decoration:
      const InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(
          color: Color(0xFF777777),
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        contentPadding:
        EdgeInsets.symmetric(
          vertical: 8,
        ),
        enabledBorder:
        UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD5D7DF),
          ),
        ),
        focusedBorder:
        UnderlineInputBorder(
          borderSide: BorderSide(
            color: _primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 위치 및 날짜 버튼
  // ============================================================

  Widget _buildInformationButton({
    required IconData icon,
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(8),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: hasValue
                  ? _primaryColor
                  : const Color(
                0xFFA8AAB2,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue
                      ? const Color(
                    0xFF555555,
                  )
                      : const Color(
                    0xFFA8AAB2,
                  ),
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}