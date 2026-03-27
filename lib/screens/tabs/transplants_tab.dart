import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/transplant.dart';
import '../../widgets/error_handler.dart';
import '../transplant_detail_screen.dart';

class TransplantsTab extends StatefulWidget {
  final int patientId;

  const TransplantsTab({super.key, required this.patientId});

  @override
  State<TransplantsTab> createState() => _TransplantsTabState();
}

class _TransplantsTabState extends State<TransplantsTab> with AutomaticKeepAliveClientMixin {
  List<Transplant> _items = [];
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
      final items = await api.getTransplants(patientId: widget.patientId);
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

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

    if (_items.isEmpty) return const Center(child: Text('Aucune greffe'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final t = _items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(
                t.isGraftFunctional ? Icons.favorite : Icons.heart_broken,
                color: t.isGraftFunctional ? Colors.green : Colors.red,
              ),
              title: Text('Greffe n°${t.rank} — ${t.transplantDate}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.transplantTypeName != null)
                    Text(t.transplantTypeName!),
                  if (t.immunologicalRiskName != null)
                    Text(
                      t.immunologicalRiskName!,
                      style: TextStyle(
                        color: _riskColor(t.immunologicalRiskName),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransplantDetailScreen(transplant: t),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
