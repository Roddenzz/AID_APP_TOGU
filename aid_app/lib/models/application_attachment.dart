import 'dart:convert';

class ApplicationAttachment {
  final String name;
  final String dataBase64;
  final String? mimeType;

  const ApplicationAttachment({
    required this.name,
    required this.dataBase64,
    this.mimeType,
  });

  List<int> get bytes => base64Decode(dataBase64);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'data': dataBase64,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }

  factory ApplicationAttachment.fromMap(Map<String, dynamic> map) {
    return ApplicationAttachment(
      name: map['name'] ?? 'attachment',
      dataBase64: map['data'] ?? '',
      mimeType: map['mimeType'],
    );
  }
}
