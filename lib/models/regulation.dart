class Regulation {
  final String id;
  final String code;
  final String name;
  final String jurisdiction;
  final String description;
  final String category;

  const Regulation({
    required this.id,
    required this.code,
    required this.name,
    required this.jurisdiction,
    required this.description,
    required this.category,
  });

  /// Alias for jurisdiction – used as the issuing authority.
  String get authority => jurisdiction;

  /// Returns the category as a single-element list for UI display.
  List<String> get categories => [category];

  /// Generates sensible key requirements from the regulation description.
  List<String> get keyRequirements => [
        'Ensure compliance with $code standards',
        'Maintain documentation and records',
        'Conduct regular inspections and audits',
        'Train personnel on $name requirements',
      ];
}

/// Pre-loaded regulatory framework reference data.
class Regulations {
  static const List<Regulation> all = [
    // ── OSHA (US) ──
    Regulation(
      id: 'osha-1910',
      code: 'OSHA 1910',
      name: 'General Industry Standards',
      jurisdiction: 'United States',
      description: 'Federal safety & health standards for general industry workplaces.',
      category: 'Occupational Safety',
    ),
    Regulation(
      id: 'osha-1926',
      code: 'OSHA 1926',
      name: 'Construction Standards',
      jurisdiction: 'United States',
      description: 'Federal safety standards for construction sites.',
      category: 'Construction',
    ),
    Regulation(
      id: 'osha-300',
      code: 'OSHA 300 Log',
      name: 'Injury & Illness Recordkeeping',
      jurisdiction: 'United States',
      description: 'Requirements for recording work-related injuries and illnesses.',
      category: 'Recordkeeping',
    ),

    // ── ISO ──
    Regulation(
      id: 'iso-45001',
      code: 'ISO 45001',
      name: 'Occupational Health & Safety',
      jurisdiction: 'International',
      description: 'International standard for OH&S management systems.',
      category: 'Management Systems',
    ),
    Regulation(
      id: 'iso-14001',
      code: 'ISO 14001',
      name: 'Environmental Management',
      jurisdiction: 'International',
      description: 'Framework for environmental management and compliance.',
      category: 'Environment',
    ),
    Regulation(
      id: 'iso-9001',
      code: 'ISO 9001',
      name: 'Quality Management Systems',
      jurisdiction: 'International',
      description: 'International standard for quality management systems.',
      category: 'Quality',
    ),

    // ── UK / EU ──
    Regulation(
      id: 'hswa-1974',
      code: 'HSWA 1974',
      name: 'Health & Safety at Work Act',
      jurisdiction: 'United Kingdom',
      description: 'Primary UK legislation covering occupational health and safety.',
      category: 'Occupational Safety',
    ),
    Regulation(
      id: 'coshh',
      code: 'COSHH',
      name: 'Control of Substances Hazardous to Health',
      jurisdiction: 'United Kingdom',
      description: 'Regulations for preventing exposure to hazardous substances.',
      category: 'Chemical',
    ),
    Regulation(
      id: 'riddor',
      code: 'RIDDOR',
      name: 'Reporting of Injuries, Diseases & Dangerous Occurrences',
      jurisdiction: 'United Kingdom',
      description: 'Mandatory reporting requirements for workplace incidents.',
      category: 'Recordkeeping',
    ),
    Regulation(
      id: 'loler',
      code: 'LOLER',
      name: 'Lifting Operations & Lifting Equipment Regulations',
      jurisdiction: 'United Kingdom',
      description: 'Requirements for safe lifting operations and equipment inspection.',
      category: 'Equipment',
    ),
    Regulation(
      id: 'puwer',
      code: 'PUWER',
      name: 'Provision & Use of Work Equipment',
      jurisdiction: 'United Kingdom',
      description: 'Regulations for the safe provision and use of work equipment.',
      category: 'Equipment',
    ),
    Regulation(
      id: 'wahr',
      code: 'WAHR 2005',
      name: 'Work at Height Regulations',
      jurisdiction: 'United Kingdom',
      description: 'Regulations for working at height and fall prevention.',
      category: 'Height',
    ),

    // ── Fire ──
    Regulation(
      id: 'nfpa-101',
      code: 'NFPA 101',
      name: 'Life Safety Code',
      jurisdiction: 'United States',
      description: 'Fire protection and life safety requirements for buildings.',
      category: 'Fire',
    ),
    Regulation(
      id: 'nfpa-70',
      code: 'NFPA 70 (NEC)',
      name: 'National Electrical Code',
      jurisdiction: 'United States',
      description: 'Standards for safe electrical design, installation, and inspection.',
      category: 'Electrical',
    ),
    Regulation(
      id: 'rrf-2005',
      code: 'RRO 2005',
      name: 'Regulatory Reform (Fire Safety) Order',
      jurisdiction: 'United Kingdom',
      description: 'UK fire safety legislation for non-domestic premises.',
      category: 'Fire',
    ),

    // ── Environmental ──
    Regulation(
      id: 'epa-rcra',
      code: 'EPA RCRA',
      name: 'Resource Conservation & Recovery Act',
      jurisdiction: 'United States',
      description: 'Framework for managing hazardous and non-hazardous waste.',
      category: 'Environment',
    ),

    // ── Mining ──
    Regulation(
      id: 'msha',
      code: 'MSHA',
      name: 'Mine Safety & Health Administration',
      jurisdiction: 'United States',
      description: 'Federal mine safety and health standards.',
      category: 'Mining',
    ),

    // ── Transportation ──
    Regulation(
      id: 'dot-fmcsa',
      code: 'DOT/FMCSA',
      name: 'Federal Motor Carrier Safety',
      jurisdiction: 'United States',
      description: 'Regulations for commercial motor vehicle safety.',
      category: 'Transportation',
    ),

    // ── Food / Hospitality ──
    Regulation(
      id: 'haccp',
      code: 'HACCP',
      name: 'Hazard Analysis & Critical Control Points',
      jurisdiction: 'International',
      description: 'Systematic food safety management framework.',
      category: 'Food Safety',
    ),
  ];

  /// Returns regulations matching a given category keyword.
  static List<Regulation> forCategory(String category) {
    final lower = category.toLowerCase();
    return all.where((r) =>
        r.category.toLowerCase().contains(lower) ||
        r.name.toLowerCase().contains(lower)).toList();
  }

  /// Returns regulation by ID.
  static Regulation? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}
