class User {
  final String id;
  final String email;
  final String studentId;
  final String fullName;
  final String phone;
  final bool isStaff;
  final DateTime createdAt;
  final String? avatar;
  final String? academicGroup;

  User({
    required this.id,
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.phone,
    required this.isStaff,
    required this.createdAt,
    this.avatar,
    this.academicGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'studentId': studentId,
      'fullName': fullName,
      'phone': phone,
      'isStaff': isStaff ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'avatar': avatar,
      'academicGroup': academicGroup,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      isStaff: (map['isStaff'] ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      avatar: map['avatar'],
      academicGroup: map['academicGroup'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? studentId,
    String? fullName,
    String? phone,
    bool? isStaff,
    DateTime? createdAt,
    String? avatar,
    String? academicGroup,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isStaff: isStaff ?? this.isStaff,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
      academicGroup: academicGroup ?? this.academicGroup,
    );
  }
}
