class Donor {
  final int id;
  final String? donorTypeName;
  final String cristalNumber;
  final String? bloodGroupName;
  final String? rhesus;
  final String? sex;
  final int? age;
  final int? height;
  final int? weight;
  final String? patientComment;

  // Living donor fields
  final String? lastName;
  final String? firstName;
  final String? relationshipTypeName;
  final String? relationshipComment;
  final double? creatinine;
  final double? isotopicClearance;
  final double? proteinuria;
  final String? approachName;
  final bool? robot;

  // Deceased donor fields
  final String? originCity;
  final String? deathCauseName;
  final String? deathCauseComment;
  final bool? extendedCriteriaDonor;
  final bool? cardiacArrest;
  final int? cardiacArrestDuration;
  final double? meanArterialPressure;
  final bool? amines;
  final bool? transfusion;
  final int? cgr;
  final int? cpa;
  final int? pfc;
  final double? creatinineArrival;
  final double? creatinineSample;
  final String? ureter;

  // HLA & serology
  final List<HlaTyping> hlaTypings;
  final List<Serology> serologyResults;

  // Surgical
  final String? donorSurgeonName;
  final String? clampingDate;
  final String? donorHarvestSide;
  final String? perfusionMachine;
  final String? perfusionLiquidName;

  Donor({
    required this.id,
    this.donorTypeName,
    required this.cristalNumber,
    this.bloodGroupName,
    this.rhesus,
    this.sex,
    this.age,
    this.height,
    this.weight,
    this.patientComment,
    this.lastName,
    this.firstName,
    this.relationshipTypeName,
    this.relationshipComment,
    this.creatinine,
    this.isotopicClearance,
    this.proteinuria,
    this.approachName,
    this.robot,
    this.originCity,
    this.deathCauseName,
    this.deathCauseComment,
    this.extendedCriteriaDonor,
    this.cardiacArrest,
    this.cardiacArrestDuration,
    this.meanArterialPressure,
    this.amines,
    this.transfusion,
    this.cgr,
    this.cpa,
    this.pfc,
    this.creatinineArrival,
    this.creatinineSample,
    this.ureter,
    this.hlaTypings = const [],
    this.serologyResults = const [],
    this.donorSurgeonName,
    this.clampingDate,
    this.donorHarvestSide,
    this.perfusionMachine,
    this.perfusionLiquidName,
  });

  bool get isLiving => donorTypeName?.toLowerCase().contains('vivant') ?? false;

  String get displayName {
    if (isLiving && lastName != null && firstName != null) {
      return '$lastName $firstName';
    }
    return 'Donneur #$cristalNumber';
  }

  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    final h = height! / 100.0;
    return weight! / (h * h);
  }

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as int,
      donorTypeName: _extractLabel(json['donorType']),
      cristalNumber: json['cristalNumber'] as String? ?? '',
      bloodGroupName: _extractLabel(json['bloodGroup']),
      rhesus: json['rhesus'] as String?,
      sex: json['sex'] as String?,
      age: json['age'] as int?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      patientComment: json['patientComment'] as String?,
      lastName: json['lastName'] as String?,
      firstName: json['firstName'] as String?,
      relationshipTypeName: _extractLabel(json['relationshipType']),
      relationshipComment: json['relationshipComment'] as String?,
      creatinine: _toDouble(json['creatinine']),
      isotopicClearance: _toDouble(json['isotopicClearance']),
      proteinuria: _toDouble(json['proteinuria']),
      approachName: _extractLabel(json['approach']),
      robot: json['robot'] as bool?,
      originCity: json['originCity'] as String?,
      deathCauseName: _extractLabel(json['deathCause']),
      deathCauseComment: json['deathCauseComment'] as String?,
      extendedCriteriaDonor: json['extendedCriteriaDonor'] as bool?,
      cardiacArrest: json['cardiacArrest'] as bool?,
      cardiacArrestDuration: json['cardiacArrestDuration'] as int?,
      meanArterialPressure: _toDouble(json['meanArterialPressure']),
      amines: json['amines'] as bool?,
      transfusion: json['transfusion'] as bool?,
      cgr: json['cgr'] as int?,
      cpa: json['cpa'] as int?,
      pfc: json['pfc'] as int?,
      creatinineArrival: _toDouble(json['creatinineArrival']),
      creatinineSample: _toDouble(json['creatinineSample']),
      ureter: json['ureter'] as String?,
      hlaTypings: _parseHla(json['hlaTypings']),
      serologyResults: _parseSerology(json['serologyResults']),
      donorSurgeonName: json['donorSurgeonName'] as String?,
      clampingDate: json['clampingDate'] as String?,
      donorHarvestSide: json['donorHarvestSide'] as String?,
      perfusionMachine: json['perfusionMachine'] as String?,
      perfusionLiquidName: _extractLabel(json['perfusionLiquid']),
    );
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static List<HlaTyping> _parseHla(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => HlaTyping.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<Serology> _parseSerology(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => Serology.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class HlaTyping {
  final String locus;
  final int value;

  HlaTyping({required this.locus, required this.value});

  factory HlaTyping.fromJson(Map<String, dynamic> json) {
    return HlaTyping(
      locus: _extractLabel(json['hlaLocus']) ?? '',
      value: json['value'] as int? ?? 0,
    );
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }
}

class Serology {
  final String marker;
  final String result;

  Serology({required this.marker, required this.result});

  factory Serology.fromJson(Map<String, dynamic> json) {
    return Serology(
      marker: _extractLabel(json['serologyMarker']) ?? '',
      result: json['result'] as String? ?? '',
    );
  }

  static String? _extractLabel(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['label'] as String?;
    return null;
  }
}
