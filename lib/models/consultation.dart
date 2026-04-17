class Consultation {
  final int? id;
  final int? patientId;
  final String? patientIri;
  final String date;
  final String practitionerName;
  final String? createdByName;
  final String? typeName;
  final String? typeIri;
  final String observations;
  final String? treatmentNotes;
  final String? nextAppointmentDate;
  final List<String> attachmentFilenames;
  final String? createdAt;

  Consultation({
    this.id,
    this.patientId,
    this.patientIri,
    required this.date,
    this.practitionerName = '',
    this.createdByName,
    this.typeName,
    this.typeIri,
    required this.observations,
    this.treatmentNotes,
    this.nextAppointmentDate,
    this.attachmentFilenames = const [],
    this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as int?,
      patientId: _extractId(json['patient']),
      patientIri: _extractIri(json['patient']),
      date: json['date'] as String? ?? '',
      practitionerName: json['practitionerName'] as String? ?? '',
      createdByName: json['createdByName'] as String?,
      typeName: _extractLabel(json['type']),
      typeIri: _extractIri(json['type']),
      observations: json['observations'] as String? ?? '',
      treatmentNotes: json['treatmentNotes'] as String?,
      nextAppointmentDate: json['nextAppointmentDate'] as String?,
      attachmentFilenames: _parseStringList(json['attachmentFilenames']),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'date': date,
      'observations': observations,
    };
    if (patientIri != null) data['patient'] = patientIri;
    if (typeIri != null) data['type'] = typeIri;
    if (treatmentNotes != null) data['treatmentNotes'] = treatmentNotes;
    if (nextAppointmentDate != null) {
      data['nextAppointmentDate'] = nextAppointmentDate;
    }
    // Only send practitionerName if explicitly provided (e.g. by a nurse selecting a doctor)
    if (practitionerName.isNotEmpty) {
      data['practitionerName'] = practitionerName;
    }
    return data;
  }

  static int? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map) return value['id'] as int?;
    return null;
  }

  static String? _extractIri(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['@id'] as String?;
    return null;
  }

  static String? _extractLabel(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['label'] as String?;
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
