import 'application_attachment.dart';

enum ApplicationStatus {
  pending,
  approved,
  rejected,
  inReview,
}

enum AidCategory {
  categoryNeedy,
  svoParticipant,
  parentingChildUnder14,
  travelHome,
  marriageRegistration,
  childBirth,
  earlyPregnancyRegistration,
  medicalExpenses,
  emergencyCircumstances,
  relativeDeath,
  pensionerParents,
  chronicCondition,
  singleParentFamily,
  otherHardship,
  other,
}

const Map<AidCategory, String> aidCategoryTitles = {
  AidCategory.categoryNeedy: 'Особы нуждающиеся',
  AidCategory.svoParticipant: 'Участник СВО / боевых действий',
  AidCategory.parentingChildUnder14: 'Воспитание детей до 14 лет',
  AidCategory.travelHome: 'Проезд домой (дорога)',
  AidCategory.marriageRegistration: 'Регистрация брака',
  AidCategory.childBirth: 'Рождение ребёнка',
  AidCategory.earlyPregnancyRegistration: 'Ранний учёт беременности',
  AidCategory.medicalExpenses: 'Лечение, медикаменты, оздоровление',
  AidCategory.emergencyCircumstances: 'Чрезвычайные обстоятельства',
  AidCategory.relativeDeath: 'Смерть близкого родственника',
  AidCategory.pensionerParents: 'Родители-пенсионеры',
  AidCategory.chronicCondition: 'Хронические заболевания на диспансерном учёте',
  AidCategory.singleParentFamily: 'Неполная семья',
  AidCategory.otherHardship: 'Тяжёлое материальное положение (иные обстоятельства)',
  AidCategory.other: 'Другое',
};

final Map<String, AidCategory> _aidCategoryLookup = {
  for (final entry in aidCategoryTitles.entries) entry.key.toString().split('.').last: entry.key,
  // Backward compatibility with прежние коды
  'tuition': AidCategory.other,
  'accommodation': AidCategory.other,
  'food': AidCategory.other,
  'medical': AidCategory.medicalExpenses,
  'emergency': AidCategory.emergencyCircumstances,
};

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
  final List<ApplicationAttachment> attachments;
  final String? signatureData;
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
    this.signatureData,
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
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'signature': signatureData,
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
      category: _aidCategoryLookup[(map['category'] ?? 'other') as String] ?? AidCategory.other,
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
      attachments: (map['attachments'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApplicationAttachment.fromMap)
              .toList() ??
          [],
      signatureData: map['signature'],
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
    List<ApplicationAttachment>? attachments,
    String? signatureData,
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
      signatureData: signatureData ?? this.signatureData,
      notes: notes ?? this.notes,
    );
  }
}