import 'package:flutter/material.dart';
import '../models/donor.dart';
import '../widgets/section_card.dart';

class DonorDetailScreen extends StatelessWidget {
  final Donor donor;

  const DonorDetailScreen({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    final d = donor;
    return Scaffold(
      appBar: AppBar(title: Text(d.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // General
            SectionCard(
              title: 'Informations générales',
              children: [
                InfoRow(label: 'N° CRISTAL', value: d.cristalNumber),
                InfoRow(label: 'Type', value: d.donorTypeName),
                InfoRow(label: 'Groupe sanguin', value: '${d.bloodGroupName ?? ''}${d.rhesus ?? ''}'),
                InfoRow(label: 'Sexe', value: d.sex),
                InfoRow(label: 'Âge', value: d.age?.toString()),
                InfoRow(label: 'Taille', value: d.height != null ? '${d.height} cm' : null),
                InfoRow(label: 'Poids', value: d.weight != null ? '${d.weight} kg' : null),
                if (d.bmi != null) InfoRow(label: 'IMC', value: d.bmi!.toStringAsFixed(1)),
              ],
            ),

            // Living donor specifics
            if (d.isLiving) ...[
              SectionCard(
                title: 'Donneur vivant',
                children: [
                  InfoRow(label: 'Nom', value: d.lastName),
                  InfoRow(label: 'Prénom', value: d.firstName),
                  InfoRow(label: 'Lien', value: d.relationshipTypeName),
                  if (d.relationshipComment != null) InfoRow(label: 'Commentaire lien', value: d.relationshipComment),
                  if (d.creatinine != null) InfoRow(label: 'Créatinine', value: '${d.creatinine} µmol/L'),
                  if (d.isotopicClearance != null) InfoRow(label: 'Clairance isotopique', value: '${d.isotopicClearance} mL/min'),
                  if (d.proteinuria != null) InfoRow(label: 'Protéinurie', value: '${d.proteinuria} g/24h'),
                  InfoRow(label: 'Approche', value: d.approachName),
                  if (d.robot != null) InfoRow(label: 'Robot', value: d.robot! ? 'Oui' : 'Non'),
                ],
              ),
            ],

            // Deceased donor specifics
            if (!d.isLiving) ...[
              SectionCard(
                title: 'Donneur décédé',
                children: [
                  InfoRow(label: 'Ville d\'origine', value: d.originCity),
                  InfoRow(label: 'Cause du décès', value: d.deathCauseName),
                  if (d.deathCauseComment != null) InfoRow(label: 'Commentaire', value: d.deathCauseComment),
                  if (d.extendedCriteriaDonor != null) InfoRow(label: 'DCE', value: d.extendedCriteriaDonor! ? 'Oui' : 'Non'),
                  if (d.cardiacArrest != null) InfoRow(label: 'Arrêt cardiaque', value: d.cardiacArrest! ? 'Oui' : 'Non'),
                  if (d.cardiacArrestDuration != null) InfoRow(label: 'Durée arrêt (min)', value: d.cardiacArrestDuration.toString()),
                  if (d.meanArterialPressure != null) InfoRow(label: 'PAM', value: '${d.meanArterialPressure} mmHg'),
                  if (d.amines != null) InfoRow(label: 'Amines', value: d.amines! ? 'Oui' : 'Non'),
                  if (d.transfusion != null) InfoRow(label: 'Transfusion', value: d.transfusion! ? 'Oui' : 'Non'),
                  if (d.transfusion == true) ...[
                    InfoRow(label: 'CGR', value: d.cgr?.toString()),
                    InfoRow(label: 'CPA', value: d.cpa?.toString()),
                    InfoRow(label: 'PFC', value: d.pfc?.toString()),
                  ],
                  if (d.creatinineArrival != null) InfoRow(label: 'Créatinine arrivée', value: '${d.creatinineArrival} µmol/L'),
                  if (d.creatinineSample != null) InfoRow(label: 'Créatinine prélèvement', value: '${d.creatinineSample} µmol/L'),
                  if (d.ureter != null) InfoRow(label: 'Uretère', value: d.ureter),
                ],
              ),
            ],

            // HLA typing
            if (d.hlaTypings.isNotEmpty)
              SectionCard(
                title: 'Typage HLA',
                children: d.hlaTypings
                    .map((h) => InfoRow(label: h.locus, value: h.value.toString()))
                    .toList(),
              ),

            // Serology
            if (d.serologyResults.isNotEmpty)
              SectionCard(
                title: 'Sérologie',
                children: d.serologyResults
                    .map((s) => InfoRow(
                          label: s.marker,
                          value: s.result,
                          valueColor: s.result == '+' ? Colors.red : Colors.green,
                        ))
                    .toList(),
              ),

            // Surgical
            SectionCard(
              title: 'Détails chirurgicaux',
              children: [
                InfoRow(label: 'Chirurgien', value: d.donorSurgeonName),
                InfoRow(label: 'Date clampage', value: d.clampingDate),
                InfoRow(label: 'Côté prélèvement', value: d.donorHarvestSide),
                InfoRow(label: 'Machine perfusion', value: d.perfusionMachine),
                InfoRow(label: 'Liquide perfusion', value: d.perfusionLiquidName),
              ],
            ),

            // Comment
            if (d.patientComment != null && d.patientComment!.isNotEmpty)
              SectionCard(
                title: 'Commentaire',
                children: [Text(d.patientComment!)],
              ),
          ],
        ),
      ),
    );
  }
}
