/// 紧急联系人模型
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone, relationship: $relationship)';
  }
}

/// 热线电话模型
class Hotline {
  final String name;
  final String phone;
  final String description;
  final List<String> tags;

  Hotline({
    required this.name,
    required this.phone,
    required this.description,
    required this.tags,
  });

  Hotline copyWith({
    String? name,
    String? phone,
    String? description,
    List<String>? tags,
  }) {
    return Hotline(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'description': description,
      'tags': tags,
    };
  }

  factory Hotline.fromJson(Map<String, dynamic> json) {
    return Hotline(
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  String toString() {
    return 'Hotline(name: $name, phone: $phone)';
  }
}
