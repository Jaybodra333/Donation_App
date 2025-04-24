class DonationModel {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime createdAt;
  final String? assignedTo;
  final String? location;
  final String? notes;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.assignedTo,
    this.location,
    this.notes,
  });

  factory DonationModel.fromMap(Map<String, dynamic> data) {
    return DonationModel(
      id: data['id'],
      donorId: data['donorId'],
      title: data['title'],
      description: data['description'],
      category: data['category'],
      status: data['status'],
      createdAt: DateTime.parse(data['createdAt']),
      assignedTo: data['assignedTo'],
      location: data['location'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorId': donorId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'assignedTo': assignedTo,
      'location': location,
      'notes': notes,
    };
  }
}
