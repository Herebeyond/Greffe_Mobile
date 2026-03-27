import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../widgets/section_card.dart';
import 'tabs/consultations_tab.dart';
import 'tabs/biological_results_tab.dart';
import 'tabs/medical_history_tab.dart';
import 'tabs/therapeutic_education_tab.dart';
import 'tabs/transplants_tab.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patient.fullName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Fiche'),
              Tab(icon: Icon(Icons.medical_services), text: 'Consultations'),
              Tab(icon: Icon(Icons.science), text: 'Résultats Bio'),
              Tab(icon: Icon(Icons.history), text: 'Antécédents'),
              Tab(icon: Icon(Icons.school), text: 'ETP'),
              Tab(icon: Icon(Icons.favorite), text: 'Greffes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PatientInfoTab(patient: patient),
            ConsultationsTab(patientId: patient.id, patientIri: '/api/patients/${patient.id}'),
            BiologicalResultsTab(patientId: patient.id),
            MedicalHistoryTab(patientId: patient.id),
            TherapeuticEducationTab(patientId: patient.id),
            TransplantsTab(patientId: patient.id),
          ],
        ),
      ),
    );
  }
}

class _PatientInfoTab extends StatelessWidget {
  final Patient patient;
  const _PatientInfoTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    String? formattedBirth;
    if (patient.birthDate != null) {
      try {
        final date = DateTime.parse(patient.birthDate!);
        formattedBirth = DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {
        formattedBirth = patient.birthDate;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              '${patient.lastName.isNotEmpty ? patient.lastName[0] : ''}${patient.firstName.isNotEmpty ? patient.firstName[0] : ''}',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(patient.fullName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Informations générales',
            children: [
              InfoRow(label: 'N° de dossier', value: patient.fileNumber),
              if (patient.sex != null)
                InfoRow(label: 'Sexe', value: patient.sex == 'M' ? 'Masculin' : 'Féminin'),
              if (formattedBirth != null)
                InfoRow(label: 'Date de naissance', value: formattedBirth),
              if (patient.city != null)
                InfoRow(label: 'Ville', value: patient.city!),
              if (patient.bloodGroup != null)
                InfoRow(label: 'Groupe sanguin', value: patient.bloodGroupDisplay),
            ],
          ),
        ],
      ),
    );
  }
}
