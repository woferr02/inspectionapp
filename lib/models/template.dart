import 'package:flutter/material.dart';

/// A single inspection template in the library.
class Template {
  final String id;
  final String name;
  final String industry;
  final String category;
  final int questionCount;
  final bool isFavourite;
  final String description;
  final String lastUpdated;
  /// ISO country code: 'Global', 'UK', 'US', 'AU', etc.
  final String country;

  Template({
    required this.id,
    required this.name,
    required this.industry,
    this.category = '',
    required this.questionCount,
    this.isFavourite = false,
    this.description = '',
    this.lastUpdated = 'Feb 2026',
    this.country = 'Global',
  });
}

/// An industry grouping shown in the template selector.
class Industry {
  final String name;
  final IconData icon;
  final String tagline;

  const Industry({
    required this.name,
    required this.icon,
    required this.tagline,
  });

  static const List<Industry> all = [
    Industry(name: 'Construction', icon: Icons.construction, tagline: 'Sites, scaffolding & civil works'),
    Industry(name: 'Healthcare', icon: Icons.local_hospital_outlined, tagline: 'Hospitals, clinics & care homes'),
    Industry(name: 'Manufacturing', icon: Icons.precision_manufacturing_outlined, tagline: 'Factories, plants & machinery'),
    Industry(name: 'Office & Retail', icon: Icons.business_center_outlined, tagline: 'Workplaces, shops & DSE'),
    Industry(name: 'Logistics & Warehousing', icon: Icons.local_shipping_outlined, tagline: 'Warehouses, fleets & loading'),
    Industry(name: 'Oil & Gas', icon: Icons.oil_barrel_outlined, tagline: 'Rigs, refineries & pipelines'),
    Industry(name: 'Education', icon: Icons.school_outlined, tagline: 'Schools, campuses & labs'),
    Industry(name: 'Hospitality', icon: Icons.restaurant_outlined, tagline: 'Hotels, kitchens & events'),
    Industry(name: 'Utilities', icon: Icons.bolt_outlined, tagline: 'Electrical, water & telecoms'),
    Industry(name: 'Agriculture', icon: Icons.grass_outlined, tagline: 'Farms, livestock & agri-food'),
    Industry(name: 'Mining', icon: Icons.terrain_outlined, tagline: 'Quarries, tunnels & mineral extraction'),
    Industry(name: 'Transportation', icon: Icons.train_outlined, tagline: 'Rail, aviation & marine'),
    Industry(name: 'General', icon: Icons.shield_outlined, tagline: 'Cross-industry essentials'),
  ];

  static Industry? find(String name) {
    for (final i in all) {
      if (i.name == name) return i;
    }
    return null;
  }
}
