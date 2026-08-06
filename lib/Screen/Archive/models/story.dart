class Story {
  final int id;
  final int placeId;
  final String title;
  final String content;
  final String location;
  final DateTime visitedAt;
  final List<String> imageUrls;
  final bool isWish;

  const Story({
    required this.id,
    required this.placeId,
    required this.title,
    required this.content,
    required this.location,
    required this.visitedAt,
    required this.imageUrls,
    this.isWish = false,
  });

  Story copyWith({
    int? id,
    int? placeId,
    String? title,
    String? content,
    String? location,
    DateTime? visitedAt,
    List<String>? imageUrls,
    bool? isWish,
  }) {
    return Story(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      visitedAt: visitedAt ?? this.visitedAt,
      imageUrls: imageUrls ?? this.imageUrls,
      isWish: isWish ?? this.isWish,
    );
  }
}