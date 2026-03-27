import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/therapeutic_education.dart';
import '../../widgets/error_handler.dart';
import '../../widgets/section_card.dart';

class TherapeuticEducationTab extends StatefulWidget {
  final int patientId;

  const TherapeuticEducationTab({super.key, required this.patientId});

  @override
  State<TherapeuticEducationTab> createState() => _TherapeuticEducationTabState();
}

class _TherapeuticEducationTabState extends State<TherapeuticEducationTab> with AutomaticKeepAliveClientMixin {
  List<TherapeuticEducation> _items = [];
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
      final items = await api.getTherapeuticEducations(patientId: widget.patientId);
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

    if (_items.isEmpty) return const Center(child: Text('Aucune session ETP'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final e = _items[index];
          return SectionCard(
            title: e.topicName ?? 'Session ETP',
            children: [
              InfoRow(label: 'Date', value: e.sessionDate),
              InfoRow(label: 'Éducateur', value: e.educator),
              if (e.objectives != null) InfoRow(label: 'Objectifs', value: e.objectives),
              if (e.observations != null) InfoRow(label: 'Observations', value: e.observations),
              if (e.patientProgressName != null) InfoRow(label: 'Progression', value: e.patientProgressName),
              if (e.nextSessionDate != null) InfoRow(label: 'Prochaine session', value: e.nextSessionDate),
            ],
          );
        },
      ),
    );
  }
}
