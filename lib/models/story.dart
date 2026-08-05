class Story {
  final int id;
  final String userId;
  final String title;
  final String? content;
  final String? location;
  final DateTime? visitedAt;
  final DateTime createdAt;
  final List<StoryImage> images;

  const Story({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.images,
    this.content,
    this.location,
    this.visitedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final rawImages =
        json['story_images'] as List<dynamic>? ?? [];

    rawImages.sort(
          (a, b) => (a['display_order'] as int)
          .compareTo(b['display_order'] as int),
    );

    return Story(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      location: json['location'] as String?,
      visitedAt: json['visited_at'] == null
          ? null
          : DateTime.parse(json['visited_at'] as String),
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      images: rawImages
          .map(
            (image) => StoryImage.fromJson(
          image as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class StoryImage {
  final int id;
  final String imagePath;
  final int displayOrder;

  const StoryImage({
    required this.id,
    required this.imagePath,
    required this.displayOrder,
  });

  factory StoryImage.fromJson(
      Map<String, dynamic> json,
      ) {
    return StoryImage(
      id: json['id'] as int,
      imagePath: json['image_path'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}