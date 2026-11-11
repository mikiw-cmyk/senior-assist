class AssistanceRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String type; // 'Medicine', 'Food', 'Help'
  final String description;
  final String status; // 'Pending', 'In Progress', 'Completed', 'Cancelled'
  final String address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNote;

  AssistanceRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.type,
    required this.description,
    required this.status,
    required this.address,
    required this.createdAt,
    this.updatedAt,
    this.adminNote,
  });

  factory AssistanceRequest.fromMap(Map<String, dynamic> map, String id) {
    return AssistanceRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
      adminNote: map['adminNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'type': type,
      'description': description,
      'status': status,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'adminNote': adminNote,
    };
  }
}
