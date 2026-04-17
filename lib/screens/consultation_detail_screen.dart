import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/consultation.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/section_card.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailScreen({super.key, required this.consultation});

  Future<void> _downloadAndOpen(BuildContext context, String filename) async {
    final auth = context.read<AuthService>();
    final api = ApiService(auth.token!);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement en cours...')),
      );

      final response = await api.downloadConsultationFile(consultation.id!, filename);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le fichier: ${result.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = consultation;
    return Scaffold(
      appBar: AppBar(title: Text(c.typeName ?? 'Consultation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            SectionCard(
              title: 'Informations',
              children: [
                InfoRow(label: 'Date', value: c.date),
                InfoRow(label: 'Praticien', value: c.practitionerName),
                InfoRow(label: 'Type', value: c.typeName),
              ],
            ),
            SectionCard(
              title: 'Observations',
              children: [
                Text(c.observations),
              ],
            ),
            if (c.treatmentNotes != null && c.treatmentNotes!.isNotEmpty)
              SectionCard(
                title: 'Notes de traitement',
                children: [Text(c.treatmentNotes!)],
              ),
            if (c.nextAppointmentDate != null)
              SectionCard(
                title: 'Prochain rendez-vous',
                children: [Text(c.nextAppointmentDate!)],
              ),
            if (c.attachmentFilenames.isNotEmpty)
              SectionCard(
                title: 'Pièces jointes (${c.attachmentFilenames.length})',
                children: c.attachmentFilenames
                    .map((f) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.attach_file),
                          title: Text(f, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.download, size: 20),
                          onTap: () => _downloadAndOpen(context, f),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
