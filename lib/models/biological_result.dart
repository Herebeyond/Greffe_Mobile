class BiologicalResult {
  final int id;
  final int? patientId;
  final String date;
  final double? creatinine;
  final double? creatinineClearance;
  final double? proteinuria;
  final double? hemoglobin;
  final double? whiteBloodCells;
  final double? platelets;
  final double? tacrolimusLevel;
  final double? ciclosporinLevel;
  final String? cmvPcr;
  final String? ebvPcr;
  final String? comment;
  final List<String> reportFilenames;
  final String? createdAt;

  BiologicalResult({
    required this.id,
    this.patientId,
    required this.date,
    this.creatinine,
    this.creatinineClearance,
    this.proteinuria,
    this.hemoglobin,
    this.whiteBloodCells,
    this.platelets,
    this.tacrolimusLevel,
    this.ciclosporinLevel,
    this.cmvPcr,
    this.ebvPcr,
    this.comment,
    this.reportFilenames = const [],
    this.createdAt,
  });

  factory BiologicalResult.fromJson(Map<String, dynamic> json) {
    return BiologicalResult(
      id: json['id'] as int,
      patientId: _extractId(json['patient']),
      date: json['date'] as String? ?? '',
      creatinine: _toDouble(json['creatinine']),
      creatinineClearance: _toDouble(json['creatinineClearance']),
      proteinuria: _toDouble(json['proteinuria']),
      hemoglobin: _toDouble(json['hemoglobin']),
      whiteBloodCells: _toDouble(json['whiteBloodCells']),
      platelets: _toDouble(json['platelets']),
      tacrolimusLevel: _toDouble(json['tacrolimusLevel']),
      ciclosporinLevel: _toDouble(json['ciclosporinLevel']),
      cmvPcr: json['cmvPcr'] as String?,
      ebvPcr: json['ebvPcr'] as String?,
      comment: json['comment'] as String?,
      reportFilenames: _parseList(json['reportFilenames']),
      createdAt: json['createdAt'] as String?,
    );
  }

  static int? _extractId(dynamic v) {
    if (v is int) return v;
    if (v is Map) return v['id'] as int?;
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static List<String> _parseList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}
