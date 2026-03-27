import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/medical_history.dart';
import '../../widgets/error_handler.dart';
import '../../widgets/section_card.dart';

class MedicalHistoryTab extends StatefulWidget {
  final int patientId;

  const MedicalHistoryTab({super.key, required this.patientId});

  @override
  State<MedicalHistoryTab> createState() => _MedicalHistoryTabState();
}

class _MedicalHistoryTabState extends State<MedicalHistoryTab> with AutomaticKeepAliveClientMixin {
  List<MedicalHistory> _items = [];
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
      final items = await api.getMedicalHistories(patientId: widget.patientId);
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

    if (_items.isEmpty) return const Center(child: Text('Aucun antécédent'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final h = _items[index];
          return SectionCard(
            title: h.typeName ?? 'Antécédent',
            children: [
              InfoRow(label: 'Description', value: h.description),
              if (h.diagnosisDate != null) InfoRow(label: 'Date diagnostic', value: h.diagnosisDate),
              if (h.comment != null && h.comment!.isNotEmpty) InfoRow(label: 'Commentaire', value: h.comment),
            ],
          );
        },
      ),
    );
  }
}
