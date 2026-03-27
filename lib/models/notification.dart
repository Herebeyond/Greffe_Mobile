class AppNotification {
  final int id;
  final String type;
  final String message;
  final bool isRead;
  final String? createdAt;
  final String? readAt;
  final int? relatedPatientId;
  final int? relatedDonorId;
  final String? triggeredByName;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.readAt,
    this.relatedPatientId,
    this.relatedDonorId,
    this.triggeredByName,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      readAt: json['readAt'] as String?,
      relatedPatientId: _extractId(json['relatedPatient']),
      relatedDonorId: _extractId(json['relatedDonor']),
      triggeredByName: _extractName(json['triggeredBy']),
    );
  }

  static int? _extractId(dynamic v) {
    if (v is int) return v;
    if (v is Map) return v['id'] as int?;
    return null;
  }

  static String? _extractName(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) {
      final name = v['name'] as String?;
      final surname = v['surname'] as String?;
      if (name != null || surname != null) return '${surname ?? ''} ${name ?? ''}'.trim();
    }
    return null;
  }
}
