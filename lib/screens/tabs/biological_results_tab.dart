import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/biological_result.dart';
import '../../widgets/error_handler.dart';
import '../../widgets/section_card.dart';

class BiologicalResultsTab extends StatefulWidget {
  final int patientId;

  const BiologicalResultsTab({super.key, required this.patientId});

  @override
  State<BiologicalResultsTab> createState() => _BiologicalResultsTabState();
}

class _BiologicalResultsTabState extends State<BiologicalResultsTab> with AutomaticKeepAliveClientMixin {
  List<BiologicalResult> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final items = await api.getBiologicalResults(patientId: widget.patientId);
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (_items.isEmpty) return const Center(child: Text('Aucun résultat biologique'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final r = _items[index];
          return SectionCard(
            title: 'Prélèvement du ${r.date}',
            children: [
              if (r.creatinine != null) InfoRow(label: 'Créatinine', value: '${r.creatinine} µmol/L'),
              if (r.creatinineClearance != null) InfoRow(label: 'Clairance', value: '${r.creatinineClearance} mL/min'),
              if (r.proteinuria != null) InfoRow(label: 'Protéinurie', value: '${r.proteinuria} g/24h'),
              if (r.hemoglobin != null) InfoRow(label: 'Hémoglobine', value: '${r.hemoglobin} g/dL'),
              if (r.whiteBloodCells != null) InfoRow(label: 'Leucocytes', value: '${r.whiteBloodCells} G/L'),
              if (r.platelets != null) InfoRow(label: 'Plaquettes', value: '${r.platelets} G/L'),
              if (r.tacrolimusLevel != null) InfoRow(label: 'Tacrolimus', value: '${r.tacrolimusLevel} ng/mL'),
              if (r.ciclosporinLevel != null) InfoRow(label: 'Ciclosporine', value: '${r.ciclosporinLevel} ng/mL'),
              if (r.cmvPcr != null) InfoRow(label: 'CMV PCR', value: r.cmvPcr),
              if (r.ebvPcr != null) InfoRow(label: 'EBV PCR', value: r.ebvPcr),
              if (r.comment != null && r.comment!.isNotEmpty) InfoRow(label: 'Commentaire', value: r.comment),
            ],
          );
        },
      ),
    );
  }
}
