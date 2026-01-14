class News {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final List<String> likedBy;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    required this.likedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy.join(','),
    };
  }

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      likes: map['likes'] ?? 0,
      likedBy: (map['likedBy'] as String?)?.split(',') ?? [],
    );
  }

  News copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    List<String>? likedBy,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
