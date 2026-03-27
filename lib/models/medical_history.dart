class MedicalHistory {
  final int id;
  final int? patientId;
  final String? typeName;
  final String description;
  final String? diagnosisDate;
  final String? comment;
  final String? createdAt;

  MedicalHistory({
    required this.id,
    this.patientId,
    this.typeName,
    required this.description,
    this.diagnosisDate,
    this.comment,
    this.createdAt,
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      id: json['id'] as int,
      patientId: _extractId(json['patient']),
      typeName: _extractLabel(json['type']),
      description: json['description'] as String? ?? '',
      diagnosisDate: json['diagnosisDate'] as String?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  static int? _extractId(dynamic v) {
    if (v is int) return v;
    if (v is Map) return v['id'] as int?;
    return null;
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }
}
