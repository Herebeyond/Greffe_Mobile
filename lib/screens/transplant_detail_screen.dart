import 'package:flutter/material.dart';
import '../models/transplant.dart';
import '../widgets/section_card.dart';

class TransplantDetailScreen extends StatelessWidget {
  final Transplant transplant;

  const TransplantDetailScreen({super.key, required this.transplant});

  Color _riskColor(String? risk) {
    if (risk == null) return Colors.grey;
    final lower = risk.toLowerCase();
    if (lower.contains('non immunisé')) return Colors.green;
    if (lower.contains('immunisé sans dsa') || lower.contains('sans dsa')) return Colors.orange;
    if (lower.contains('dsa') || lower.contains('abo incompatible')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final t = transplant;
    return Scaffold(
      appBar: AppBar(title: Text('Greffe n°${t.rank}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // General info
            SectionCard(
              title: 'Informations générales',
              children: [
                InfoRow(label: 'Date', value: t.transplantDate),
                InfoRow(label: 'Rang', value: t.rank.toString()),
                InfoRow(label: 'Type de donneur', value: t.donorTypeName),
                InfoRow(label: 'Type de greffe', value: t.transplantTypeName),
                InfoRow(
                  label: 'Greffon fonctionnel',
                  value: t.isGraftFunctional ? 'Oui' : 'Non',
                  valueColor: t.isGraftFunctional ? Colors.green : Colors.red,
                ),
                if (!t.isGraftFunctional) ...[
                  InfoRow(label: 'Date fin greffon', value: t.graftEndDate),
                  InfoRow(label: 'Cause fin', value: t.graftEndCause),
                ],
              ],
            ),

            // Surgical details
            SectionCard(
              title: 'Détails chirurgicaux',
              children: [
                InfoRow(label: 'Chirurgien', value: t.surgeonName),
                InfoRow(label: 'Date déclampage', value: t.declampingDate),
                InfoRow(label: 'Heure déclampage', value: t.declampingTime),
                InfoRow(label: 'Côté prélèvement', value: t.harvestSide),
                InfoRow(label: 'Côté greffe', value: t.transplantSide),
                InfoRow(label: 'Position péritonéale', value: t.peritonealPositionName),
                InfoRow(label: 'Ischémie totale', value: t.totalIschemiaDisplay),
                InfoRow(label: 'Durée anastomose', value: t.anastomosisDuration != null ? '${t.anastomosisDuration} min' : null),
                InfoRow(label: 'Sonde JJ', value: t.jjProbe ? 'Oui' : 'Non'),
              ],
            ),

            // Immunological risk
            SectionCard(
              title: 'Risque immunologique',
              children: [
                InfoRow(
                  label: 'Risque',
                  value: t.immunologicalRiskName,
                  valueColor: _riskColor(t.immunologicalRiskName),
                ),
              ],
            ),

            // HLA incompatibilities
            if (t.hlaIncompatibilities.isNotEmpty)
              SectionCard(
                title: 'Incompatibilités HLA',
                children: t.hlaIncompatibilities
                    .map((h) => InfoRow(label: h.locus, value: h.count.toString()))
                    .toList(),
              ),

            // Virological status
            if (t.virologicalStatuses.isNotEmpty)
              SectionCard(
                title: 'Statut virologique',
                children: t.virologicalStatuses
                    .map((v) => InfoRow(label: v.marker, value: v.status))
                    .toList(),
              ),

            // Immunosuppressive drugs
            if (t.immunosuppressiveDrugs.isNotEmpty)
              SectionCard(
                title: 'Conditionnement immunosuppresseur',
                children: t.immunosuppressiveDrugs
                    .map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(children: [
                            const Icon(Icons.medication, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(d),
                          ]),
                        ))
                    .toList(),
              ),

            // Dialysis
            SectionCard(
              title: 'Dialyse',
              children: [
                InfoRow(label: 'Dialyse', value: t.dialysis ? 'Oui' : 'Non'),
                if (t.dialysis && t.lastDialysisDate != null)
                  InfoRow(label: 'Dernière dialyse', value: t.lastDialysisDate),
              ],
            ),

            // Protocol
            SectionCard(
              title: 'Protocole',
              children: [
                InfoRow(label: 'Protocole', value: t.hasProtocol ? 'Oui' : 'Non'),
              ],
            ),

            // Comment
            if (t.comment != null && t.comment!.isNotEmpty)
              SectionCard(
                title: 'Commentaire',
                children: [Text(t.comment!)],
              ),
          ],
        ),
      ),
    );
  }
}
