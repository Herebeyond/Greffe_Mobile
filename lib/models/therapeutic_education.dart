class TherapeuticEducation {
  final int id;
  final int? patientId;
  final String sessionDate;
  final String? topicName;
  final String educator;
  final String? objectives;
  final String? observations;
  final String? patientProgressName;
  final String? nextSessionDate;
  final String? createdAt;

  TherapeuticEducation({
    required this.id,
    this.patientId,
    required this.sessionDate,
    this.topicName,
    required this.educator,
    this.objectives,
    this.observations,
    this.patientProgressName,
    this.nextSessionDate,
    this.createdAt,
  });

  factory TherapeuticEducation.fromJson(Map<String, dynamic> json) {
    return TherapeuticEducation(
      id: json['id'] as int,
      patientId: _extractId(json['patient']),
      sessionDate: json['sessionDate'] as String? ?? '',
      topicName: _extractLabel(json['topic']),
      educator: json['educator'] as String? ?? '',
      objectives: json['objectives'] as String?,
      observations: json['observations'] as String?,
      patientProgressName: _extractLabel(json['patientProgress']),
      nextSessionDate: json['nextSessionDate'] as String?,
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
