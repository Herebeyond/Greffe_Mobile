import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/patient.dart';
import '../widgets/error_handler.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final patients = await api.getPatients(page: 1);
      if (mounted) {
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
          _isLoading = false;
          _currentPage = 1;
          _hasMore = patients.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) {
        handleApiError(context, e);
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final auth = context.read<AuthService>();
      final api = ApiService(auth.token!);
      final next = await api.getPatients(page: _currentPage + 1);
      if (mounted) {
        setState(() {
          _currentPage++;
          _patients.addAll(next);
          _filterPatients();
          _hasMore = next.length >= 20;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredPatients = List.from(_patients);
    } else {
      _filteredPatients = _patients.where((p) {
        return p.lastName.toLowerCase().contains(query) ||
            p.firstName.toLowerCase().contains(query) ||
            p.fileNumber.toLowerCase().contains(query) ||
            (p.city?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un patient...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(_filterPatients);
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(_filterPatients),
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadPatients,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  : _filteredPatients.isEmpty
                      ? const Center(child: Text('Aucun patient trouvé'))
                      : RefreshIndicator(
                          onRefresh: _loadPatients,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredPatients.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredPatients.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final patient = _filteredPatients[index];
                              return _PatientTile(patient: patient);
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _PatientTile extends StatelessWidget {
  final Patient patient;

  const _PatientTile({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            patient.lastName.isNotEmpty ? patient.lastName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Dossier: ${patient.fileNumber}'
          '${patient.bloodGroupDisplay.isNotEmpty ? ' — ${patient.bloodGroupDisplay}' : ''}'
          '${patient.city != null ? ' — ${patient.city}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PatientDetailScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }
}
