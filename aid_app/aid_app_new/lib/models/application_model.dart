enum ApplicationStatus {
  pending,
  approved,
  rejected,
  inReview,
}

enum AidCategory {
  tuition,
  accommodation,
  food,
  medical,
  emergency,
  other,
}

class Application {
  final String id;
  final String userId;
  final String fullName;
  final String academicGroup;
  final String phone;
  final AidCategory category;
  final String description;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final double? approvedAmount;
  final List<String> attachments;
  final String? notes;

  Application({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.academicGroup,
    required this.phone,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.approvedAmount,
    required this.attachments,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'academicGroup': academicGroup,
      'phone': phone,
      'category': category.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
      'approvedAmount': approvedAmount,
      'attachments': attachments.join(','),
      'notes': notes,
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      academicGroup: map['academicGroup'] ?? '',
      phone: map['phone'] ?? '',
      category: AidCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (map['category'] ?? 'other'),
        orElse: () => AidCategory.other,
      ),
      description: map['description'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      reviewedAt: map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      reviewedBy: map['reviewedBy'],
      rejectionReason: map['rejectionReason'],
      approvedAmount: (map['approvedAmount'] as num?)?.toDouble(),
      attachments: (map['attachments'] as String?)?.split(',') ?? [],
      notes: map['notes'],
    );
  }

  Application copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? academicGroup,
    String? phone,
    AidCategory? category,
    String? description,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
    double? approvedAmount,
    List<String>? attachments,
    String? notes,
  }) {
    return Application(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      academicGroup: academicGroup ?? this.academicGroup,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
    );
  }
}
