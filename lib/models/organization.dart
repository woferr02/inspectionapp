class Organization {
  final String id;
  final String name;
  final String ownerId;
  final List<OrgMember> members;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.ownerId,
    this.members = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Organization.fromJson(Map<String, dynamic> json,
          {List<OrgMember>? members}) =>
      Organization(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerId: json['ownerId'] as String,
        members: members ?? [],
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

enum OrgRole { admin, manager, inspector }

class OrgMember {
  final String userId;
  final String email;
  final String displayName;
  final OrgRole role;
  final DateTime joinedAt;

  OrgMember({
    required this.userId,
    required this.email,
    this.displayName = '',
    this.role = OrgRole.inspector,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory OrgMember.fromJson(Map<String, dynamic> json) => OrgMember(
        userId: json['userId'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        role: OrgRole.values.firstWhere(
          (e) => e.name == (json['role'] as String? ?? 'inspector'),
          orElse: () => OrgRole.inspector,
        ),
        joinedAt:
            DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
      );

  String get roleLabel {
    switch (role) {
      case OrgRole.admin:
        return 'Admin';
      case OrgRole.manager:
        return 'Manager';
      case OrgRole.inspector:
        return 'Inspector';
    }
  }
}
