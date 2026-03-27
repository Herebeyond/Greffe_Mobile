import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/donor.dart';
import '../widgets/error_handler.dart';
import 'donor_detail_screen.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  List<Donor> _donors = [];
  bool _isLoading = true;
  String? _error;

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
      final donors = await api.getDonors();
      if (mounted) setState(() { _donors = donors; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    if (_donors.isEmpty) return const Center(child: Text('Aucun donneur'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _donors.length,
        itemBuilder: (context, index) {
          final d = _donors[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: d.isLiving ? Colors.green[100] : Colors.blue[100],
                child: Icon(
                  d.isLiving ? Icons.person : Icons.person_outline,
                  color: d.isLiving ? Colors.green[700] : Colors.blue[700],
                ),
              ),
              title: Text(d.displayName),
              subtitle: Text(
                '${d.donorTypeName ?? ''}'
                '${d.bloodGroupName != null ? ' — ${d.bloodGroupName}${d.rhesus ?? ''}' : ''}'
                '${d.age != null ? ' — ${d.age} ans' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DonorDetailScreen(donor: d),
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
