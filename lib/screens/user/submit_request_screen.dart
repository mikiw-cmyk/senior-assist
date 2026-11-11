import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';

class SubmitRequestScreen extends StatefulWidget {
  final UserModel? user;
  const SubmitRequestScreen({super.key, this.user});

  @override
  State<SubmitRequestScreen> createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final RequestService _requestService = RequestService();
  final AuthService _authService = AuthService();

  String _selectedType = 'Medicine';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _requestTypes = [
    {'label': 'Medicine', 'icon': Icons.medication, 'color': Colors.orange},
    {'label': 'Food', 'icon': Icons.restaurant, 'color': Colors.green},
    {'label': 'Help', 'icon': Icons.handshake, 'color': Colors.blue},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? uid = _authService.currentUser?.uid;
    if (uid == null) return;

    String? error = await _requestService.submitRequest(
      userId: uid,
      userName: widget.user?.name ?? 'Unknown',
      userPhone: widget.user?.phone ?? '',
      type: _selectedType,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Request Submitted!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your request has been submitted. We will get back to you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Submit Request',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              const Text(
                'Type of Assistance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: _requestTypes.map((type) {
                  bool isSelected = _selectedType == type['label'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = type['label']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? type['color'] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? type['color']
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type['icon'],
                              color: isSelected ? Colors.white : type['color'],
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what you need help with...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please describe your request'
                    : null,
              ),
              const SizedBox(height: 20),

              // Address
              const Text(
                'Your Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your complete address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Request'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
