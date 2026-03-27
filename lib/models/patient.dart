class Patient {
  final int id;
  final String fileNumber;
  final String lastName;
  final String firstName;
  final String? city;
  final String? birthDate;
  final String? bloodGroup;
  final String? rhesus;
  final String? sex;
  final String? createdAt;

  Patient({
    required this.id,
    required this.fileNumber,
    required this.lastName,
    required this.firstName,
    this.city,
    this.birthDate,
    this.bloodGroup,
    this.rhesus,
    this.sex,
    this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int,
      fileNumber: json['fileNumber'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      city: json['city'] as String?,
      birthDate: json['birthDate'] as String?,
      bloodGroup: _extractLabel(json['bloodGroup']),
      rhesus: json['rhesus'] as String?,
      sex: json['sex'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  String get fullName => '$lastName $firstName';

  String get bloodGroupDisplay {
    if (bloodGroup == null) return '';
    return '$bloodGroup${rhesus ?? ''}';
  }

  static String? _extractLabel(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['label'] as String?;
    return null;
  }
}
