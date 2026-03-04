class Site {
  final String id;
  final String name;
  final String address;
  final String? contactName;
  final String? contactPhone;
  final int inspectionCount;
  final DateTime? lastInspectionDate;
  final String notes;

  Site({
    required this.id,
    required this.name,
    required this.address,
    this.contactName,
    this.contactPhone,
    this.inspectionCount = 0,
    this.lastInspectionDate,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'contactName': contactName ?? '',
        'contactPhone': contactPhone ?? '',
        'inspectionCount': inspectionCount,
        'lastInspectionDate': lastInspectionDate?.toIso8601String(),
        'notes': notes,
      };

  factory Site.fromJson(Map<String, dynamic> json) => Site(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        contactName: json['contactName'] as String?,
        contactPhone: json['contactPhone'] as String?,
        inspectionCount: json['inspectionCount'] as int? ?? 0,
        lastInspectionDate:
            DateTime.tryParse(json['lastInspectionDate'] as String? ?? ''),
        notes: json['notes'] as String? ?? '',
      );

  Site copyWith({
    String? id,
    String? name,
    String? address,
    String? contactName,
    String? contactPhone,
    int? inspectionCount,
    DateTime? lastInspectionDate,
    String? notes,
  }) =>
      Site(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        contactName: contactName ?? this.contactName,
        contactPhone: contactPhone ?? this.contactPhone,
        inspectionCount: inspectionCount ?? this.inspectionCount,
        lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
        notes: notes ?? this.notes,
      );
}
