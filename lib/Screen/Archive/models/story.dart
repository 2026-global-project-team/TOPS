class Story {
  //title
  // → Good dinner
  //
  // location
  // → Camden, London, UK
  //
  // visitedAt
  // → 2026-10-20
  //
  // imageUrls
  // → 기록에 첨부한 사진 목록
  //
  // isWish
  // → 찜 여부

  final String id;
  final String title;
  final String location;
  final DateTime visitedAt;
  final List<String> imageUrls;
  final bool isWish;

  const Story({
    required this.id,
    required this.title,
    required this.location,
    required this.visitedAt,
    required this.imageUrls,
    this.isWish = false,
  });

  Story copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? visitedAt,
    List<String>? imageUrls,
    bool? isWish,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      visitedAt: visitedAt ?? this.visitedAt,
      imageUrls: imageUrls ?? this.imageUrls,
      isWish: isWish ?? this.isWish,
    );
  }
}