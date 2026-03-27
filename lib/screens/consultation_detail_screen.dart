import 'package:flutter/material.dart';
import '../models/consultation.dart';
import '../widgets/section_card.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailScreen({super.key, required this.consultation});

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
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
