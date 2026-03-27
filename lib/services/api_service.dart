import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/patient.dart';
import '../models/consultation.dart';
import '../models/biological_result.dart';
import '../models/medical_history.dart';
import '../models/therapeutic_education.dart';
import '../models/transplant.dart';
import '../models/donor.dart';
import '../models/notification.dart';

/// Centralises all API calls. Requires a valid JWT token.
class ApiService {
  final String _token;

  ApiService(this._token);

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Accept': 'application/ld+json',
    'Content-Type': 'application/ld+json',
  };

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Generic GET that returns a list of items parsed by [fromJson].
  Future<List<T>> _getCollection<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    int page = 1,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path').replace(
      queryParameters: {'page': page.toString()},
    );
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Generic GET for a single item.
  Future<T> _getItem<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401) {
      throw TokenExpiredException();
    }
  }

  // ─── Patients ──────────────────────────────────────────────────────

  Future<List<Patient>> getPatients({int page = 1}) =>
      _getCollection('/patients', Patient.fromJson, page: page);

  Future<Patient> getPatient(int id) =>
      _getItem('/patients/$id', Patient.fromJson);

  // ─── Consultations ─────────────────────────────────────────────────

  Future<List<Consultation>> getConsultations({int page = 1, int? patientId}) async {
    var path = '/consultations';
    final queryParams = <String, String>{'page': page.toString()};
    if (patientId != null) {
      queryParams['patient'] = patientId.toString();
    }
    final uri = Uri.parse('${AppConfig.apiUrl}$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => Consultation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Consultation> getConsultation(int id) =>
      _getItem('/consultations/$id', Consultation.fromJson);

  Future<Consultation> createConsultation(Consultation consultation) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/consultations');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(consultation.toJson()),
    );
    _checkAuth(response);
    if (response.statusCode != 201) {
      throw ApiException(
        'Erreur lors de la création (${response.statusCode})',
        response.statusCode,
      );
    }
    return Consultation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Consultation> updateConsultation(int id, Consultation consultation) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/consultations/$id');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(consultation.toJson()),
    );
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException(
        'Erreur lors de la mise à jour (${response.statusCode})',
        response.statusCode,
      );
    }
    return Consultation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Upload a file to a consultation.
  Future<void> uploadConsultationFile(int consultationId, File file) async {
    final uri = Uri.parse(
      '${AppConfig.apiUrl}/consultations/$consultationId/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _checkAuth(response);
    if (response.statusCode != 201) {
      throw ApiException(
        'Erreur lors de l\'upload (${response.statusCode})',
        response.statusCode,
      );
    }
  }

  // ─── Biological Results ────────────────────────────────────────────

  Future<List<BiologicalResult>> getBiologicalResults({int page = 1, int? patientId}) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (patientId != null) queryParams['patient'] = patientId.toString();
    final uri = Uri.parse('${AppConfig.apiUrl}/biological_results').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => BiologicalResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BiologicalResult> getBiologicalResult(int id) =>
      _getItem('/biological_results/$id', BiologicalResult.fromJson);

  // ─── Medical Histories ─────────────────────────────────────────────

  Future<List<MedicalHistory>> getMedicalHistories({int page = 1, int? patientId}) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (patientId != null) queryParams['patient'] = patientId.toString();
    final uri = Uri.parse('${AppConfig.apiUrl}/medical_histories').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => MedicalHistory.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Therapeutic Educations ────────────────────────────────────────

  Future<List<TherapeuticEducation>> getTherapeuticEducations({int page = 1, int? patientId}) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (patientId != null) queryParams['patient'] = patientId.toString();
    final uri = Uri.parse('${AppConfig.apiUrl}/therapeutic_educations').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => TherapeuticEducation.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Transplants ───────────────────────────────────────────────────

  Future<List<Transplant>> getTransplants({int page = 1, int? patientId}) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (patientId != null) queryParams['patient'] = patientId.toString();
    final uri = Uri.parse('${AppConfig.apiUrl}/transplants').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur (${response.statusCode})', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hydra:member'] as List?) ?? (data['member'] as List?) ?? [];
    return items.map((e) => Transplant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Transplant> getTransplant(int id) =>
      _getItem('/transplants/$id', Transplant.fromJson);

  // ─── Donors ────────────────────────────────────────────────────────

  Future<List<Donor>> getDonors({int page = 1}) =>
      _getCollection('/donors', Donor.fromJson, page: page);

  Future<Donor> getDonor(int id) =>
      _getItem('/donors/$id', Donor.fromJson);

  // ─── Notifications ─────────────────────────────────────────────────

  Future<List<AppNotification>> getNotifications({int page = 1}) =>
      _getCollection('/notifications', AppNotification.fromJson, page: page);

  Future<void> markNotificationRead(int id) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/notifications/$id');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/ld+json',
        'Content-Type': 'application/merge-patch+json',
      },
      body: jsonEncode({'isRead': true}),
    );
    _checkAuth(response);
    if (response.statusCode != 200) {
      throw ApiException('Erreur (${response.statusCode})', response.statusCode);
    }
  }

  Future<int> getUnreadNotificationCount() async {
    final notifications = await getNotifications(page: 1);
    return notifications.where((n) => !n.isRead).length;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class TokenExpiredException implements Exception {
  @override
  String toString() => 'Session expirée. Veuillez vous reconnecter.';
}
