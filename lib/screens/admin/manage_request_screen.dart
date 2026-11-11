import 'package:flutter/material.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';

class ManageRequestScreen extends StatefulWidget {
  final AssistanceRequest request;
  const ManageRequestScreen({super.key, required this.request});

  @override
  State<ManageRequestScreen> createState() => _ManageRequestScreenState();
}

class _ManageRequestScreenState extends State<ManageRequestScreen> {
  final RequestService _requestService = RequestService();
  final _noteController = TextEditingController();
  String _selectedStatus = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Pending', 'icon': Icons.hourglass_empty, 'color': Colors.orange},
    {'label': 'In Progress', 'icon': Icons.sync, 'color': Colors.blue},
    {'label': 'Completed', 'icon': Icons.check_circle, 'color': Colors.green},
    {'label': 'Cancelled', 'icon': Icons.cancel, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.request.status;
    _noteController.text = widget.request.adminNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    setState(() => _isLoading = true);

    String? error = await _requestService.updateRequestStatus(
      requestId: widget.request.id,
      status: _selectedStatus,
      adminNote: _noteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Manage Request',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Requester',
                    value: widget.request.userName,
                  ),
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: widget.request.userPhone,
                  ),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: widget.request.type,
                  ),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: widget.request.address,
                  ),
                  _DetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: widget.request.description,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status update
            const Text(
              'Update Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_statusOptions.map((option) {
              bool isSelected = _selectedStatus == option['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedStatus = option['label']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (option['color'] as Color).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? option['color'] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(option['icon'], color: option['color'], size: 24),
                      const SizedBox(width: 12),
                      Text(
                        option['label'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? option['color'] : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle, color: option['color']),
                    ],
                  ),
                ),
              );
            })).toList(),

            const SizedBox(height: 20),

            // Admin note
            const Text(
              'Note to Requester (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note for the senior citizen...',
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _updateStatus,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
