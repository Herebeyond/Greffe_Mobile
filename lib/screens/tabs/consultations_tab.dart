import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/consultation.dart';
import '../../widgets/error_handler.dart';
import '../consultation_detail_screen.dart';
import '../consultation_form_screen.dart';

class ConsultationsTab extends StatefulWidget {
  final int patientId;
  final String patientIri;

  const ConsultationsTab({super.key, required this.patientId, required this.patientIri});

  @override
  State<ConsultationsTab> createState() => _ConsultationsTabState();
}

class _ConsultationsTabState extends State<ConsultationsTab> with AutomaticKeepAliveClientMixin {
  List<Consultation> _items = [];
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
      final items = await api.getConsultations(patientId: widget.patientId);
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

    return Scaffold(
      body: _items.isEmpty
          ? const Center(child: Text('Aucune consultation'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final c = _items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.medical_services_outlined),
                      title: Text(c.typeName ?? 'Consultation'),
                      subtitle: Text('${c.date} — ${c.practitionerName}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConsultationDetailScreen(consultation: c),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addConsultation',
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ConsultationFormScreen(
                patientId: widget.patientId,
                patientIri: widget.patientIri,
              ),
            ),
          );
          if (created == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
