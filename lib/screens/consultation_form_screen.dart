import '../utils/platform_imports.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../models/consultation.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/error_handler.dart';

/// Screen to create or edit a consultation.
class ConsultationFormScreen extends StatefulWidget {
  final int patientId;
  final String patientIri;
  final Consultation? existing; // null = create, non-null = edit

  const ConsultationFormScreen({
    super.key,
    required this.patientId,
    required this.patientIri,
    this.existing,
  });

  @override
  State<ConsultationFormScreen> createState() => _ConsultationFormScreenState();
}

class _ConsultationFormScreenState extends State<ConsultationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _observationsController;
  late final TextEditingController _treatmentController;
  late final TextEditingController _nextAppointmentController;
  bool _isSaving = false;
  final List<File> _filesToUpload = [];

  List<Map<String, dynamic>> _consultationTypes = [];
  String? _selectedTypeIri;
  bool _typesLoading = true;

  // Nurse practitioner picker
  bool _isNurse = false;
  List<Map<String, dynamic>> _patientDoctors = [];
  String? _selectedPractitionerName;
  bool _doctorsLoading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _dateController = TextEditingController(text: e?.date ?? _todayString());
    _observationsController = TextEditingController(text: e?.observations ?? '');
    _treatmentController = TextEditingController(text: e?.treatmentNotes ?? '');
    _nextAppointmentController = TextEditingController(text: e?.nextAppointmentDate ?? '');
    _selectedTypeIri = e?.typeIri;
    _loadConsultationTypes();
    _checkNurseAndLoadDoctors();
  }

  Future<void> _checkNurseAndLoadDoctors() async {
    final auth = context.read<AuthService>();
    if (!auth.isNurse) return;

    setState(() {
      _isNurse = true;
      _doctorsLoading = true;
    });

    try {
      final api = ApiService(auth.token!);
      final doctors = await api.getPatientDoctors(widget.patientId);
      if (mounted) {
        setState(() {
          _patientDoctors = doctors;
          // Default to first doctor if available
          if (doctors.isNotEmpty) {
            _selectedPractitionerName = doctors.first['fullName'] as String?;
          }
          _doctorsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _doctorsLoading = false);
    }
  }

  Future<void> _loadConsultationTypes() async {
    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final types = await api.getConsultationTypes();
      if (mounted) {
        setState(() {
          _consultationTypes = types;
          _typesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _typesLoading = false);
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _observationsController.dispose();
    _treatmentController.dispose();
    _nextAppointmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() => _filesToUpload.add(File(image.path)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _filesToUpload.add(File(result.files.single.path!)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);

      final consultation = Consultation(
        patientIri: widget.patientIri,
        date: _dateController.text,
        typeIri: _selectedTypeIri,
        observations: _observationsController.text,
        treatmentNotes: _treatmentController.text.isNotEmpty ? _treatmentController.text : null,
        nextAppointmentDate:
            _nextAppointmentController.text.isNotEmpty ? _nextAppointmentController.text : null,
        // For nurses, send the selected doctor's name; for doctors it's set server-side
        practitionerName: (_isNurse && _selectedPractitionerName != null)
            ? _selectedPractitionerName!
            : '',
      );

      Consultation saved;
      if (_isEdit) {
        saved = await api.updateConsultation(widget.existing!.id!, consultation);
      } else {
        saved = await api.createConsultation(consultation);
      }

      // Upload attached files to the server
      for (final file in _filesToUpload) {
        await api.uploadConsultationFile(saved.id!, file);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Consultation modifiée' : 'Consultation créée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la consultation' : 'Nouvelle consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_dateController),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Date requise' : null,
                onTap: () => _pickDate(_dateController),
              ),
              const SizedBox(height: 16),

              // Nurse: pick practitioner from patient's doctors
              if (_isNurse) ...[
                _doctorsLoading
                    ? const LinearProgressIndicator()
                    : _patientDoctors.isEmpty
                        ? const Text(
                            'Aucun médecin assigné à ce patient.',
                            style: TextStyle(color: Colors.orange),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedPractitionerName,
                            decoration: const InputDecoration(
                              labelText: 'Praticien *',
                              border: OutlineInputBorder(),
                            ),
                            items: _patientDoctors.map((d) {
                              final name = d['fullName'] as String? ?? '';
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedPractitionerName = v),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Praticien requis' : null,
                          ),
                const SizedBox(height: 16),
              ],

              // Consultation Type
              _typesLoading
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedTypeIri,
                      decoration: const InputDecoration(
                        labelText: 'Type de consultation *',
                        border: OutlineInputBorder(),
                      ),
                      items: _consultationTypes.map((t) {
                        return DropdownMenuItem<String>(
                          value: t['@id'] as String,
                          child: Text(t['label'] as String),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedTypeIri = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Type requis' : null,
                    ),
              const SizedBox(height: 16),

              // Observations
              TextFormField(
                controller: _observationsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Observations *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Observations requises' : null,
              ),
              const SizedBox(height: 16),

              // Treatment Notes
              TextFormField(
                controller: _treatmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes de traitement',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Next Appointment
              TextFormField(
                controller: _nextAppointmentController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Prochain rendez-vous',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_nextAppointmentController),
                  ),
                ),
                onTap: () => _pickDate(_nextAppointmentController),
              ),
              const SizedBox(height: 24),

              // File attachments
              Text('Pièces jointes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Les fichiers sont enregistrés sur le serveur et accessibles depuis toutes les interfaces.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Photo'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Fichier'),
                  ),
                ],
              ),
              if (_filesToUpload.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(_filesToUpload.length, (i) {
                  final file = _filesToUpload[i];
                  final name = file.path.split(RegExp(r'[/\\]')).last;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(name, overflow: TextOverflow.ellipsis),
                    subtitle: const Text('Appuyer pour prévisualiser', style: TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _filesToUpload.removeAt(i)),
                    ),
                    onTap: () => OpenFilex.open(file.path),
                  );
                }),
              ],

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEdit ? 'Enregistrer' : 'Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Screen to create or edit a consultation.
class ConsultationFormScreen extends StatefulWidget {
  final int patientId;
  final String patientIri;
  final Consultation? existing; // null = create, non-null = edit

  const ConsultationFormScreen({
    super.key,
    required this.patientId,
    required this.patientIri,
    this.existing,
  });

  @override
  State<ConsultationFormScreen> createState() => _ConsultationFormScreenState();
}

class _ConsultationFormScreenState extends State<ConsultationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _observationsController;
  late final TextEditingController _treatmentController;
  late final TextEditingController _nextAppointmentController;
  bool _isSaving = false;
  final List<File> _filesToUpload = [];

  List<Map<String, dynamic>> _consultationTypes = [];
  String? _selectedTypeIri;
  bool _typesLoading = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _dateController = TextEditingController(text: e?.date ?? _todayString());
    _observationsController = TextEditingController(text: e?.observations ?? '');
    _treatmentController = TextEditingController(text: e?.treatmentNotes ?? '');
    _nextAppointmentController = TextEditingController(text: e?.nextAppointmentDate ?? '');
    _selectedTypeIri = e?.typeIri;
    _loadConsultationTypes();
  }

  Future<void> _loadConsultationTypes() async {
    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final types = await api.getConsultationTypes();
      if (mounted) {
        setState(() {
          _consultationTypes = types;
          _typesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _typesLoading = false);
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _observationsController.dispose();
    _treatmentController.dispose();
    _nextAppointmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() => _filesToUpload.add(File(image.path)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _filesToUpload.add(File(result.files.single.path!)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);

      final consultation = Consultation(
        patientIri: widget.patientIri,
        date: _dateController.text,
        typeIri: _selectedTypeIri,
        observations: _observationsController.text,
        treatmentNotes: _treatmentController.text.isNotEmpty ? _treatmentController.text : null,
        nextAppointmentDate:
            _nextAppointmentController.text.isNotEmpty ? _nextAppointmentController.text : null,
      );

      Consultation saved;
      if (_isEdit) {
        saved = await api.updateConsultation(widget.existing!.id!, consultation);
      } else {
        saved = await api.createConsultation(consultation);
      }

      // Upload attached files
      for (final file in _filesToUpload) {
        await api.uploadConsultationFile(saved.id!, file);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Consultation modifiée' : 'Consultation créée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la consultation' : 'Nouvelle consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_dateController),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Date requise' : null,
                onTap: () => _pickDate(_dateController),
              ),
              const SizedBox(height: 16),

              // Consultation Type
              _typesLoading
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedTypeIri,
                      decoration: const InputDecoration(
                        labelText: 'Type de consultation *',
                        border: OutlineInputBorder(),
                      ),
                      items: _consultationTypes.map((t) {
                        return DropdownMenuItem<String>(
                          value: t['@id'] as String,
                          child: Text(t['label'] as String),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedTypeIri = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Type requis' : null,
                    ),
              const SizedBox(height: 16),

              // Observations
              TextFormField(
                controller: _observationsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Observations *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Observations requises' : null,
              ),
              const SizedBox(height: 16),

              // Treatment Notes
              TextFormField(
                controller: _treatmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes de traitement',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Next Appointment
              TextFormField(
                controller: _nextAppointmentController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Prochain rendez-vous',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_nextAppointmentController),
                  ),
                ),
                onTap: () => _pickDate(_nextAppointmentController),
              ),
              const SizedBox(height: 24),

              // File attachments
              Text('Pièces jointes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Photo'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Fichier'),
                  ),
                ],
              ),
              if (_filesToUpload.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(_filesToUpload.length, (i) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      _filesToUpload[i].path.split(RegExp(r'[/\\]')).last,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _filesToUpload.removeAt(i)),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEdit ? 'Enregistrer' : 'Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
