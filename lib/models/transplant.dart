class Transplant {
  final int id;
  final int? patientId;
  final String transplantDate;
  final int rank;
  final String? donorTypeName;
  final bool isGraftFunctional;
  final String? graftEndDate;
  final String? graftEndCause;
  final String? transplantTypeName;
  final String? surgeonName;
  final String? declampingDate;
  final String? declampingTime;
  final String? harvestSide;
  final String? transplantSide;
  final String? peritonealPositionName;
  final int? totalIschemiaMinutes;
  final int? anastomosisDuration;
  final bool jjProbe;
  final String? comment;
  final String? immunologicalRiskName;
  final bool dialysis;
  final String? lastDialysisDate;
  final bool hasProtocol;
  final List<VirologicalStatus> virologicalStatuses;
  final List<HlaIncompatibility> hlaIncompatibilities;
  final List<String> immunosuppressiveDrugs;
  final int? donorId;
  final String? createdAt;

  Transplant({
    required this.id,
    this.patientId,
    required this.transplantDate,
    required this.rank,
    this.donorTypeName,
    this.isGraftFunctional = true,
    this.graftEndDate,
    this.graftEndCause,
    this.transplantTypeName,
    this.surgeonName,
    this.declampingDate,
    this.declampingTime,
    this.harvestSide,
    this.transplantSide,
    this.peritonealPositionName,
    this.totalIschemiaMinutes,
    this.anastomosisDuration,
    this.jjProbe = false,
    this.comment,
    this.immunologicalRiskName,
    this.dialysis = false,
    this.lastDialysisDate,
    this.hasProtocol = false,
    this.virologicalStatuses = const [],
    this.hlaIncompatibilities = const [],
    this.immunosuppressiveDrugs = const [],
    this.donorId,
    this.createdAt,
  });

  String get totalIschemiaDisplay {
    if (totalIschemiaMinutes == null) return '';
    final h = totalIschemiaMinutes! ~/ 60;
    final m = totalIschemiaMinutes! % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  factory Transplant.fromJson(Map<String, dynamic> json) {
    return Transplant(
      id: json['id'] as int,
      patientId: _extractId(json['patient']),
      transplantDate: json['transplantDate'] as String? ?? '',
      rank: json['rank'] as int? ?? 1,
      donorTypeName: _extractLabel(json['donorType']),
      isGraftFunctional: json['isGraftFunctional'] as bool? ?? true,
      graftEndDate: json['graftEndDate'] as String?,
      graftEndCause: json['graftEndCause'] as String?,
      transplantTypeName: _extractLabel(json['transplantType']),
      surgeonName: json['surgeonName'] as String?,
      declampingDate: json['declampingDate'] as String?,
      declampingTime: json['declampingTime'] as String?,
      harvestSide: json['harvestSide'] as String?,
      transplantSide: json['transplantSide'] as String?,
      peritonealPositionName: _extractLabel(json['peritonealPosition']),
      totalIschemiaMinutes: json['totalIschemiaMinutes'] as int?,
      anastomosisDuration: json['anastomosisDuration'] as int?,
      jjProbe: json['jjProbe'] as bool? ?? false,
      comment: json['comment'] as String?,
      immunologicalRiskName: _extractLabel(json['immunologicalRisk']),
      dialysis: json['dialysis'] as bool? ?? false,
      lastDialysisDate: json['lastDialysisDate'] as String?,
      hasProtocol: json['hasProtocol'] as bool? ?? false,
      virologicalStatuses: _parseVirologicalStatuses(json['virologicalStatuses']),
      hlaIncompatibilities: _parseHlaIncompatibilities(json['hlaIncompatibilities']),
      immunosuppressiveDrugs: _parseDrugs(json['immunosuppressiveDrugs']),
      donorId: _extractId(json['donor']),
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

  static List<VirologicalStatus> _parseVirologicalStatuses(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => VirologicalStatus.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<HlaIncompatibility> _parseHlaIncompatibilities(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => HlaIncompatibility.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<String> _parseDrugs(dynamic v) {
    if (v is! List) return [];
    return v.map((e) {
      if (e is String) return e;
      if (e is Map) return (e['label'] as String?) ?? '';
      return e.toString();
    }).toList();
  }
}

class VirologicalStatus {
  final String marker;
  final String status;

  VirologicalStatus({required this.marker, required this.status});

  factory VirologicalStatus.fromJson(Map<String, dynamic> json) {
    return VirologicalStatus(
      marker: _extractLabel(json['virologicalMarker']) ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }
}

class HlaIncompatibility {
  final String locus;
  final int count;

  HlaIncompatibility({required this.locus, required this.count});

  factory HlaIncompatibility.fromJson(Map<String, dynamic> json) {
    return HlaIncompatibility(
      locus: _extractLabel(json['hlaLocus']) ?? '',
      count: json['incompatibilityCount'] as int? ?? 0,
    );
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }
}
