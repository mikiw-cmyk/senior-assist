import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../models/request_model.dart';
import '../../widgets/request_card.dart';
import '../login_screen.dart';
import 'manage_request_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final RequestService _requestService = RequestService();
  late TabController _tabController;

  final List<String> _statuses = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: StreamBuilder<List<AssistanceRequest>>(
        stream: _requestService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          List<AssistanceRequest> allRequests = snapshot.data ?? [];

          // Summary counts
          int pending = allRequests.where((r) => r.status == 'Pending').length;
          int inProgress = allRequests
              .where((r) => r.status == 'In Progress')
              .length;
          int completed = allRequests
              .where((r) => r.status == 'Completed')
              .length;

          return Column(
            children: [
              // Summary bar
              Container(
                color: const Color(0xFF1565C0),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _SummaryChip(
                      label: 'Total',
                      count: allRequests.length,
                      color: Colors.white,
                    ),
                    _SummaryChip(
                      label: 'Pending',
                      count: pending,
                      color: Colors.orange,
                    ),
                    _SummaryChip(
                      label: 'In Progress',
                      count: inProgress,
                      color: Colors.lightBlue,
                    ),
                    _SummaryChip(
                      label: 'Done',
                      count: completed,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              // Tabs content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _statuses.map((status) {
                    List<AssistanceRequest> filtered = status == 'All'
                        ? allRequests
                        : allRequests.where((r) => r.status == status).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No $status requests',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return RequestCard(
                          request: filtered[index],
                          isAdmin: true,
                          onManage: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ManageRequestScreen(request: filtered[index]),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
