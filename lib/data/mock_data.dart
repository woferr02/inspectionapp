import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/models/template.dart';

class MockData {
  static final List<Inspection> inspections = [
    Inspection(
      id: '1',
      name: 'Q1 Fire Safety Audit',
      siteName: 'Riverside Construction Site',
      siteAddress: '123 Riverside Drive, London E1 6AN',
      date: DateTime(2026, 2, 15, 14, 30),
      status: InspectionStatus.completed,
      score: 87,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '1-1',
          name: 'Fire Extinguishers',
          questionCount: 8,
          completedCount: 8,
          score: 92,
        ),
        InspectionSection(
          id: '1-2',
          name: 'Emergency Exits',
          questionCount: 6,
          completedCount: 6,
          score: 85,
        ),
        InspectionSection(
          id: '1-3',
          name: 'Fire Alarms',
          questionCount: 5,
          completedCount: 5,
          score: 84,
        ),
      ],
    ),
    Inspection(
      id: '2',
      name: 'Annual Electrical Review',
      siteName: "St Mary's Hospital",
      siteAddress: '45 Medical Way, London SW1A 1AA',
      date: DateTime(2026, 2, 14, 10, 15),
      status: InspectionStatus.submitted,
      score: 92,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '2-1',
          name: 'Electrical Panels',
          questionCount: 7,
          completedCount: 7,
          score: 95,
        ),
        InspectionSection(
          id: '2-2',
          name: 'Outlet Safety',
          questionCount: 5,
          completedCount: 5,
          score: 90,
        ),
      ],
    ),
    Inspection(
      id: '3',
      name: 'PPE Compliance Check',
      siteName: 'Metro Tower Office',
      siteAddress: 'Metro Tower, 22 Bishopsgate, London EC2N 4AJ',
      date: DateTime(2026, 2, 16, 9, 0),
      status: InspectionStatus.inProgress,
      score: null,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '3-1',
          name: 'Head Protection',
          questionCount: 4,
          completedCount: 2,
          score: null,
        ),
        InspectionSection(
          id: '3-2',
          name: 'Eye Protection',
          questionCount: 3,
          completedCount: 1,
          score: null,
        ),
      ],
    ),
    Inspection(
      id: '4',
      name: 'Hazardous Materials Inspection',
      siteName: 'Greenfield Chemical Plant',
      siteAddress: 'Greenfield Industrial Estate, Manchester M60 7RA',
      date: DateTime(2026, 2, 13, 11, 45),
      status: InspectionStatus.draft,
      score: null,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '4-1',
          name: 'Chemical Storage',
          questionCount: 6,
          completedCount: 0,
          score: null,
        ),
      ],
    ),
    Inspection(
      id: '5',
      name: 'Scaffolding Safety Review',
      siteName: 'Riverside Construction Site',
      siteAddress: '123 Riverside Drive, London E1 6AN',
      date: DateTime(2026, 2, 10, 13, 20),
      status: InspectionStatus.completed,
      score: 78,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '5-1',
          name: 'Scaffold Structure',
          questionCount: 9,
          completedCount: 9,
          score: 80,
        ),
        InspectionSection(
          id: '5-2',
          name: 'Fall Protection',
          questionCount: 7,
          completedCount: 7,
          score: 75,
        ),
      ],
    ),
    Inspection(
      id: '6',
      name: 'Emergency Exit Assessment',
      siteName: "St Mary's Hospital",
      siteAddress: '45 Medical Way, London SW1A 1AA',
      date: DateTime(2026, 2, 8, 15, 30),
      status: InspectionStatus.completed,
      score: 95,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '6-1',
          name: 'Exit Routes',
          questionCount: 8,
          completedCount: 8,
          score: 96,
        ),
        InspectionSection(
          id: '6-2',
          name: 'Emergency Lighting',
          questionCount: 5,
          completedCount: 5,
          score: 94,
        ),
      ],
    ),
    Inspection(
      id: '7',
      name: 'Noise Level Survey',
      siteName: 'Metro Tower Office',
      siteAddress: 'Metro Tower, 22 Bishopsgate, London EC2N 4AJ',
      date: DateTime(2026, 2, 5, 14, 0),
      status: InspectionStatus.draft,
      score: null,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '7-1',
          name: 'Noise Measurement',
          questionCount: 4,
          completedCount: 0,
          score: null,
        ),
      ],
    ),
    Inspection(
      id: '8',
      name: 'Ventilation System Check',
      siteName: 'Greenfield Chemical Plant',
      siteAddress: 'Greenfield Industrial Estate, Manchester M60 7RA',
      date: DateTime(2026, 2, 3, 10, 0),
      status: InspectionStatus.inProgress,
      score: null,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '8-1',
          name: 'Ventilation Ducts',
          questionCount: 6,
          completedCount: 3,
          score: null,
        ),
      ],
    ),
    Inspection(
      id: '9',
      name: 'Ladder Safety Audit',
      siteName: 'Thames Bridge Project',
      siteAddress: 'Thames Embankment, London SE1 7PB',
      date: DateTime(2026, 1, 28, 11, 15),
      status: InspectionStatus.submitted,
      score: 88,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '9-1',
          name: 'Ladder Inspection',
          questionCount: 5,
          completedCount: 5,
          score: 90,
        ),
        InspectionSection(
          id: '9-2',
          name: 'Safe Use',
          questionCount: 4,
          completedCount: 4,
          score: 85,
        ),
      ],
    ),
    Inspection(
      id: '10',
      name: 'Confined Space Assessment',
      siteName: 'Thames Bridge Project',
      siteAddress: 'Thames Embankment, London SE1 7PB',
      date: DateTime(2026, 1, 25, 9, 45),
      status: InspectionStatus.draft,
      score: null,
      inspectorName: 'Alex Johnson',
      sections: [
        InspectionSection(
          id: '10-1',
          name: 'Atmosphere Testing',
          questionCount: 7,
          completedCount: 0,
          score: null,
        ),
      ],
    ),
  ];

  static final List<Site> sites = [
    Site(
      id: '1',
      name: 'Riverside Construction Site',
      address: '123 Riverside Drive, London E1 6AN',
      contactName: 'Michael Chen',
      contactPhone: '+44 20 7123 4567',
      inspectionCount: 8,
      lastInspectionDate: DateTime(2026, 2, 15),
    ),
    Site(
      id: '2',
      name: "St Mary's Hospital",
      address: '45 Medical Way, London SW1A 1AA',
      contactName: 'Dr. Sarah Williams',
      contactPhone: '+44 20 7987 6543',
      inspectionCount: 12,
      lastInspectionDate: DateTime(2026, 2, 14),
    ),
    Site(
      id: '3',
      name: 'Metro Tower Office',
      address: 'Metro Tower, 22 Bishopsgate, London EC2N 4AJ',
      contactName: 'James Robertson',
      contactPhone: '+44 20 3322 1188',
      inspectionCount: 6,
      lastInspectionDate: DateTime(2026, 2, 16),
    ),
    Site(
      id: '4',
      name: 'Greenfield Chemical Plant',
      address: 'Greenfield Industrial Estate, Manchester M60 7RA',
      contactName: 'Lisa Thompson',
      contactPhone: '+44 161 555 7890',
      inspectionCount: 5,
      lastInspectionDate: DateTime(2026, 2, 13),
    ),
    Site(
      id: '5',
      name: 'Thames Bridge Project',
      address: 'Thames Embankment, London SE1 7PB',
      contactName: 'Robert Garcia',
      contactPhone: '+44 20 8444 3322',
      inspectionCount: 4,
      lastInspectionDate: DateTime(2026, 1, 28),
    ),
  ];

  static final List<Template> templates = [
    // ════════════════════════════════════════════════
    // Construction
    // ════════════════════════════════════════════════
    Template(id: 'c1', name: 'Construction Site Safety', industry: 'Construction', category: 'General Site', questionCount: 42, isFavourite: true, description: 'Comprehensive site-wide safety audit covering all major hazards', lastUpdated: 'Feb 2026'),
    Template(id: 'c2', name: 'Scaffolding Inspection', industry: 'Construction', category: 'Working at Height', questionCount: 28, description: 'Scaffold structure, bracing, platforms, and fall protection', lastUpdated: 'Jan 2026'),
    Template(id: 'c3', name: 'Excavation & Trenching', industry: 'Construction', category: 'Ground Works', questionCount: 22, description: 'Shoring, sloping, access, and protective systems check', lastUpdated: 'Feb 2026'),
    Template(id: 'c4', name: 'Crane & Lifting Operations', industry: 'Construction', category: 'Plant & Equipment', questionCount: 35, description: 'Pre-use checks, load plans, exclusion zones, and signaller protocols', lastUpdated: 'Dec 2025'),
    Template(id: 'c5', name: 'Demolition Safety Plan', industry: 'Construction', category: 'Demolition', questionCount: 30, description: 'Structural survey, exclusion zones, asbestos checks, and sequence plan', lastUpdated: 'Jan 2026'),
    Template(id: 'c6', name: 'Temporary Works Review', industry: 'Construction', category: 'Structural', questionCount: 24, description: 'Falsework, formwork, propping, and design check certificates', lastUpdated: 'Feb 2026'),
    Template(id: 'c7', name: 'Hot Works Permit Audit', industry: 'Construction', category: 'Permits', questionCount: 18, description: 'Welding, cutting, and grinding fire precaution and permit compliance', lastUpdated: 'Nov 2025'),

    // ════════════════════════════════════════════════
    // Healthcare
    // ════════════════════════════════════════════════
    Template(id: 'h1', name: 'Healthcare Facility Audit', industry: 'Healthcare', category: 'General', questionCount: 38, isFavourite: true, description: 'Ward safety, infection control, medical gas, and patient areas', lastUpdated: 'Feb 2026'),
    Template(id: 'h2', name: 'Clinical Waste Management', industry: 'Healthcare', category: 'Waste', questionCount: 18, description: 'Sharps disposal, colour-coded bins, storage, and transport', lastUpdated: 'Jan 2026'),
    Template(id: 'h3', name: 'Patient Handling & Ergonomics', industry: 'Healthcare', category: 'Ergonomics', questionCount: 20, description: 'Manual handling aids, hoist checks, and staff training records', lastUpdated: 'Nov 2025'),
    Template(id: 'h4', name: 'Infection Control Audit', industry: 'Healthcare', category: 'Hygiene', questionCount: 32, description: 'Hand hygiene stations, PPE availability, surface cleaning schedules', lastUpdated: 'Feb 2026'),
    Template(id: 'h5', name: 'Medical Gas Safety', industry: 'Healthcare', category: 'Systems', questionCount: 22, description: 'Cylinder storage, pipeline integrity, alarm systems, and VIE checks', lastUpdated: 'Jan 2026'),
    Template(id: 'h6', name: 'Pharmacy Storage Audit', industry: 'Healthcare', category: 'Storage', questionCount: 16, description: 'Controlled drug registers, temperature monitoring, and access controls', lastUpdated: 'Dec 2025'),
    Template(id: 'h7', name: 'Laboratory Safety Review', industry: 'Healthcare', category: 'Labs', questionCount: 28, description: 'Fume cupboards, chemical labelling, biological agents, and eye wash stations', lastUpdated: 'Feb 2026'),

    // ════════════════════════════════════════════════
    // Manufacturing
    // ════════════════════════════════════════════════
    Template(id: 'm1', name: 'Manufacturing Plant Review', industry: 'Manufacturing', category: 'General', questionCount: 45, description: 'Machine guarding, LOTO, noise, vibration, and process safety', lastUpdated: 'Feb 2026'),
    Template(id: 'm2', name: 'COSHH Assessment', industry: 'Manufacturing', category: 'Chemical', questionCount: 24, description: 'Chemical storage, MSDS availability, exposure controls, and PPE', lastUpdated: 'Jan 2026'),
    Template(id: 'm3', name: 'Machine Guarding Audit', industry: 'Manufacturing', category: 'Machinery', questionCount: 30, description: 'Fixed guards, interlocks, trip devices, and two-hand controls', lastUpdated: 'Dec 2025'),
    Template(id: 'm4', name: 'Lockout / Tagout (LOTO)', industry: 'Manufacturing', category: 'Energy Isolation', questionCount: 20, description: 'Isolation procedures, lock placement, verification, and group lockout', lastUpdated: 'Feb 2026'),
    Template(id: 'm5', name: 'Noise & Vibration Survey', industry: 'Manufacturing', category: 'Occupational Health', questionCount: 18, description: 'Dosimetry readings, exposure action values, hearing protection zones', lastUpdated: 'Jan 2026'),
    Template(id: 'm6', name: 'Robotic Cell Safety', industry: 'Manufacturing', category: 'Automation', questionCount: 22, description: 'Light curtains, safety-rated inputs, teach-mode controls, and fencing', lastUpdated: 'Feb 2026'),

    // ════════════════════════════════════════════════
    // Office & Retail
    // ════════════════════════════════════════════════
    Template(id: 'o1', name: 'Office Workplace Assessment', industry: 'Office & Retail', category: 'General', questionCount: 28, description: 'DSE, fire routes, first aid, and general workspace organisation', lastUpdated: 'Feb 2026'),
    Template(id: 'o2', name: 'DSE Workstation Review', industry: 'Office & Retail', category: 'Ergonomics', questionCount: 16, description: 'Display screen equipment, seating posture, and lighting levels', lastUpdated: 'Jan 2026'),
    Template(id: 'o3', name: 'Retail Store Safety', industry: 'Office & Retail', category: 'Retail', questionCount: 24, description: 'Customer areas, stockroom access, cash handling, and trip hazards', lastUpdated: 'Feb 2026'),
    Template(id: 'o4', name: 'Lone Worker Assessment', industry: 'Office & Retail', category: 'Personnel', questionCount: 14, description: 'Communication plans, check-in schedules, and emergency procedures', lastUpdated: 'Dec 2025'),
    Template(id: 'o5', name: 'Visitor & Contractor Induction', industry: 'Office & Retail', category: 'Access', questionCount: 12, description: 'Sign-in procedures, safety briefings, and restricted area controls', lastUpdated: 'Jan 2026'),

    // ════════════════════════════════════════════════
    // Logistics & Warehousing
    // ════════════════════════════════════════════════
    Template(id: 'l1', name: 'Warehouse Safety Inspection', industry: 'Logistics & Warehousing', category: 'Warehouse', questionCount: 32, isFavourite: true, description: 'Racking integrity, forklift routes, loading bays, and storage', lastUpdated: 'Feb 2026'),
    Template(id: 'l2', name: 'Fleet Vehicle Pre-Use Check', industry: 'Logistics & Warehousing', category: 'Fleet', questionCount: 20, description: 'Tyres, lights, brakes, load security, and driver documents', lastUpdated: 'Jan 2026'),
    Template(id: 'l3', name: 'Forklift Daily Inspection', industry: 'Logistics & Warehousing', category: 'Plant', questionCount: 16, description: 'Forks, mast, hydraulics, horn, lights, and seatbelt check', lastUpdated: 'Feb 2026'),
    Template(id: 'l4', name: 'Loading Dock Safety', industry: 'Logistics & Warehousing', category: 'Dock', questionCount: 18, description: 'Dock levellers, wheel chocks, edge protection, and lighting', lastUpdated: 'Dec 2025'),
    Template(id: 'l5', name: 'Racking Integrity Audit', industry: 'Logistics & Warehousing', category: 'Storage', questionCount: 22, description: 'SEMA colour coding, upright damage, beam locks, and load notices', lastUpdated: 'Jan 2026'),

    // ════════════════════════════════════════════════
    // Oil & Gas
    // ════════════════════════════════════════════════
    Template(id: 'og1', name: 'Offshore Platform Audit', industry: 'Oil & Gas', category: 'Offshore', questionCount: 50, description: 'Helideck, lifeboat, process isolation, and permit-to-work systems', lastUpdated: 'Feb 2026'),
    Template(id: 'og2', name: 'Pipeline Integrity Check', industry: 'Oil & Gas', category: 'Pipeline', questionCount: 28, description: 'Corrosion monitoring, cathodic protection, and valve inspections', lastUpdated: 'Jan 2026'),
    Template(id: 'og3', name: 'Permit to Work Audit', industry: 'Oil & Gas', category: 'Permits', questionCount: 20, description: 'Isolation verification, cross-referencing, and handback procedures', lastUpdated: 'Feb 2026'),
    Template(id: 'og4', name: 'H₂S Awareness Audit', industry: 'Oil & Gas', category: 'Gas Safety', questionCount: 18, description: 'Detector calibration, wind socks, escape routes, and SCBA checks', lastUpdated: 'Dec 2025'),
    Template(id: 'og5', name: 'Process Safety Review', industry: 'Oil & Gas', category: 'Process', questionCount: 36, description: 'PSV testing, safety instrumented systems, HAZOP actions, and alarms', lastUpdated: 'Feb 2026'),

    // ════════════════════════════════════════════════
    // Education
    // ════════════════════════════════════════════════
    Template(id: 'e1', name: 'School Safety Inspection', industry: 'Education', category: 'General', questionCount: 30, description: 'Playground, classroom, corridors, safeguarding, and fire drills', lastUpdated: 'Feb 2026'),
    Template(id: 'e2', name: 'Science Lab Safety', industry: 'Education', category: 'Labs', questionCount: 24, description: 'CLEAPSS compliance, fume cupboards, chemical storage, and eye wash', lastUpdated: 'Jan 2026'),
    Template(id: 'e3', name: 'PE & Sports Facility Check', industry: 'Education', category: 'Sports', questionCount: 18, description: 'Equipment condition, surface integrity, changing rooms, and first aid', lastUpdated: 'Dec 2025'),
    Template(id: 'e4', name: 'University Campus Audit', industry: 'Education', category: 'Campus', questionCount: 40, description: 'Lecture halls, residences, workshops, and accessibility compliance', lastUpdated: 'Feb 2026'),

    // ════════════════════════════════════════════════
    // Hospitality
    // ════════════════════════════════════════════════
    Template(id: 'hp1', name: 'Kitchen & Food Safety', industry: 'Hospitality', category: 'Food Safety', questionCount: 34, description: 'HACCP checkpoints, temperature logs, cross-contamination, and hygiene', lastUpdated: 'Feb 2026'),
    Template(id: 'hp2', name: 'Hotel Safety Walkthrough', industry: 'Hospitality', category: 'General', questionCount: 28, description: 'Guest rooms, corridors, pool area, fire systems, and emergency exits', lastUpdated: 'Jan 2026'),
    Template(id: 'hp3', name: 'Event Venue Assessment', industry: 'Hospitality', category: 'Events', questionCount: 26, description: 'Crowd capacity, temporary structures, PA systems, and egress routes', lastUpdated: 'Feb 2026'),
    Template(id: 'hp4', name: 'Swimming Pool Inspection', industry: 'Hospitality', category: 'Leisure', questionCount: 20, description: 'Water quality, lifeguard cover, signage, and drain covers', lastUpdated: 'Dec 2025'),

    // ════════════════════════════════════════════════
    // Utilities
    // ════════════════════════════════════════════════
    Template(id: 'u1', name: 'Electrical Substation Audit', industry: 'Utilities', category: 'Electrical', questionCount: 30, description: 'HV switchgear, earthing, arc flash labels, and access controls', lastUpdated: 'Feb 2026'),
    Template(id: 'u2', name: 'Water Treatment Plant Check', industry: 'Utilities', category: 'Water', questionCount: 26, description: 'Chemical dosing, confined space entries, and biological hazards', lastUpdated: 'Jan 2026'),
    Template(id: 'u3', name: 'Telecoms Tower Inspection', industry: 'Utilities', category: 'Telecoms', questionCount: 22, description: 'Climbing systems, RF exclusion zones, and structural integrity', lastUpdated: 'Feb 2026'),
    Template(id: 'u4', name: 'Gas Distribution Safety', industry: 'Utilities', category: 'Gas', questionCount: 24, description: 'Leak detection, pressure regulation, valve access, and signage', lastUpdated: 'Dec 2025'),

    // ════════════════════════════════════════════════
    // General (cross-industry)
    // ════════════════════════════════════════════════
    Template(id: 'g1', name: 'Fire Safety Comprehensive', industry: 'General', category: 'Fire', questionCount: 24, isFavourite: true, description: 'Extinguishers, alarms, evacuation routes, and fire door checks', lastUpdated: 'Feb 2026'),
    Template(id: 'g2', name: 'Electrical Systems Check', industry: 'General', category: 'Electrical', questionCount: 18, description: 'PAT testing, panel access, isolation procedures, and RCD checks', lastUpdated: 'Jan 2026'),
    Template(id: 'g3', name: 'PPE Compliance Review', industry: 'General', category: 'PPE', questionCount: 15, description: 'Head, eye, ear, hand, and foot protection adequacy and condition', lastUpdated: 'Feb 2026'),
    Template(id: 'g4', name: 'Working at Height', industry: 'General', category: 'Height', questionCount: 26, description: 'Ladders, edge protection, harnesses, and rescue plans', lastUpdated: 'Dec 2025'),
    Template(id: 'g5', name: 'Confined Space Entry', industry: 'General', category: 'Confined Space', questionCount: 22, description: 'Atmosphere testing, permits, rescue equipment, and communication', lastUpdated: 'Nov 2025'),
    Template(id: 'g6', name: 'Risk Assessment Review', industry: 'General', category: 'Risk', questionCount: 14, description: 'Hazard identification, control measures, and review dates', lastUpdated: 'Feb 2026'),
    Template(id: 'g7', name: 'First Aid Readiness', industry: 'General', category: 'First Aid', questionCount: 16, description: 'Kit contents, trained personnel, signage, and AED checks', lastUpdated: 'Feb 2026'),
    Template(id: 'g8', name: 'Slip, Trip & Fall Prevention', industry: 'General', category: 'Housekeeping', questionCount: 18, description: 'Floor surfaces, cable management, signage, and drainage', lastUpdated: 'Jan 2026'),
    Template(id: 'g9', name: 'Environmental Compliance', industry: 'General', category: 'Environment', questionCount: 20, description: 'Waste segregation, spill kits, emissions, and discharge permits', lastUpdated: 'Feb 2026'),
    Template(id: 'g10', name: 'Emergency Preparedness', industry: 'General', category: 'Emergency', questionCount: 22, description: 'Evacuation drills, assembly points, communication plans, and mutual aid', lastUpdated: 'Feb 2026'),
    Template(id: 'g11', name: 'Manual Handling Assessment', industry: 'General', category: 'Ergonomics', questionCount: 16, description: 'Lifting techniques, load weights, mechanical aids, and training records', lastUpdated: 'Feb 2026'),
    Template(id: 'g12', name: 'Contractor Pre-Qualification', industry: 'General', category: 'Contractors', questionCount: 20, description: 'Insurance, method statements, RAMS review, and competency verification', lastUpdated: 'Jan 2026'),
    Template(id: 'g13', name: 'Workplace Violence Prevention', industry: 'General', category: 'Security', questionCount: 14, description: 'Threat assessment, panic alarms, lone worker provisions, and de-escalation', lastUpdated: 'Feb 2026'),
    Template(id: 'g14', name: 'Asbestos Management Survey', industry: 'General', category: 'Hazmat', questionCount: 22, description: 'Register review, condition assessment, labelling, and management plan', lastUpdated: 'Jan 2026'),
    Template(id: 'g15', name: 'Legionella Risk Assessment', industry: 'General', category: 'Water', questionCount: 18, description: 'Water system mapping, temperature checks, dead legs, and treatment logs', lastUpdated: 'Feb 2026'),

    // ════════════════════════════════════════════════
    // Agriculture
    // ════════════════════════════════════════════════
    Template(id: 'ag1', name: 'Farm Safety Walkthrough', industry: 'Agriculture', category: 'General', questionCount: 34, description: 'Machinery storage, chemical sheds, livestock handling, and access routes', lastUpdated: 'Feb 2026'),
    Template(id: 'ag2', name: 'Tractor & Machinery Check', industry: 'Agriculture', category: 'Machinery', questionCount: 24, description: 'PTO guards, roll bars, brakes, lights, and pre-use daily checks', lastUpdated: 'Jan 2026'),
    Template(id: 'ag3', name: 'Pesticide & Chemical Storage', industry: 'Agriculture', category: 'Chemical', questionCount: 20, description: 'COSHH compliance, locked storage, PPE, and application records', lastUpdated: 'Feb 2026'),
    Template(id: 'ag4', name: 'Livestock Handling Facilities', industry: 'Agriculture', category: 'Livestock', questionCount: 18, description: 'Crush pens, race design, flooring, and escape routes for handlers', lastUpdated: 'Dec 2025'),
    Template(id: 'ag5', name: 'Grain Silo & Storage Safety', industry: 'Agriculture', category: 'Storage', questionCount: 16, description: 'Confined space entry, dust explosion prevention, and structural integrity', lastUpdated: 'Jan 2026'),

    // ════════════════════════════════════════════════
    // Mining
    // ════════════════════════════════════════════════
    Template(id: 'mn1', name: 'Underground Mine Inspection', industry: 'Mining', category: 'Underground', questionCount: 48, description: 'Ventilation, ground support, refuge chambers, and escape routes', lastUpdated: 'Feb 2026'),
    Template(id: 'mn2', name: 'Open Pit Safety Audit', industry: 'Mining', category: 'Surface', questionCount: 36, description: 'Bench stability, haul road design, berm heights, and blast exclusion zones', lastUpdated: 'Jan 2026'),
    Template(id: 'mn3', name: 'Blast Safety Review', industry: 'Mining', category: 'Blasting', questionCount: 24, description: 'Magazine storage, shot-firer competency, fly-rock controls, and misfires', lastUpdated: 'Feb 2026'),
    Template(id: 'mn4', name: 'Dust & Respirable Hazards', industry: 'Mining', category: 'Health', questionCount: 20, description: 'Dust suppression, air monitoring, RPE provision, and silicosis prevention', lastUpdated: 'Dec 2025'),
    Template(id: 'mn5', name: 'Mine Vehicle Pre-Start Check', industry: 'Mining', category: 'Fleet', questionCount: 18, description: 'Dump trucks, loaders, proximity detection, and seatbelt compliance', lastUpdated: 'Jan 2026'),

    // ════════════════════════════════════════════════
    // Transportation
    // ════════════════════════════════════════════════
    Template(id: 'tr1', name: 'Rail Infrastructure Inspection', industry: 'Transportation', category: 'Rail', questionCount: 38, description: 'Track condition, signalling, level crossings, and electrification safety', lastUpdated: 'Feb 2026'),
    Template(id: 'tr2', name: 'Aviation Ground Safety', industry: 'Transportation', category: 'Aviation', questionCount: 32, description: 'Ramp operations, jet blast zones, FOD walks, and pushback safety', lastUpdated: 'Jan 2026'),
    Template(id: 'tr3', name: 'Marine Vessel Safety', industry: 'Transportation', category: 'Marine', questionCount: 36, description: 'Life-saving appliances, fire suppression, hull integrity, and ISPS compliance', lastUpdated: 'Feb 2026'),
    Template(id: 'tr4', name: 'Bus & Coach Depot Audit', industry: 'Transportation', category: 'Road', questionCount: 22, description: 'Vehicle servicing areas, fuelling, wash facilities, and driver welfare', lastUpdated: 'Dec 2025'),
    Template(id: 'tr5', name: 'Port & Dockside Safety', industry: 'Transportation', category: 'Ports', questionCount: 28, description: 'Container handling, quay edge protection, vessel mooring, and crane operations', lastUpdated: 'Jan 2026'),

    // ════════════════════════════════════════════════
    // UK HSE Regulatory — niche, fully compliant
    // ════════════════════════════════════════════════
    Template(id: 'uk1', name: 'CDM 2015 Welfare Facilities Audit', industry: 'Construction', category: 'UK Regulatory', questionCount: 27, country: 'UK',
      description: 'Schedule 2 welfare requirements: sanitary conveniences, washing stations, drinking water, rest areas, and changing rooms per CDM Regulations 2015', lastUpdated: 'Mar 2026'),
    Template(id: 'uk2', name: 'LOLER 1998 Lifting Equipment Exam', industry: 'General', category: 'UK Regulatory', questionCount: 30, country: 'UK',
      description: 'Thorough examination per Lifting Operations & Lifting Equipment Regulations 1998: SWL markings, structural integrity, safety limiters, wire ropes, and load testing', lastUpdated: 'Mar 2026'),
    Template(id: 'uk3', name: 'LEV Thorough Examination (COSHH Reg 9)', industry: 'Manufacturing', category: 'UK Regulatory', questionCount: 25, country: 'UK',
      description: '14-month statutory examination of Local Exhaust Ventilation per COSHH Regulation 9: hoods, ductwork, filters, fans, and airflow verification', lastUpdated: 'Mar 2026'),
    Template(id: 'uk4', name: 'Legionella L8 Compliance Audit', industry: 'General', category: 'UK Regulatory', questionCount: 26, country: 'UK',
      description: 'HSG274 / ACoP L8 water hygiene inspection: cold water tanks, calorifiers, TMVs, stagnation points, sampling records, and responsible person duties', lastUpdated: 'Mar 2026'),
    Template(id: 'uk5', name: 'Confined Space Entry Audit (CS Regs 1997)', industry: 'General', category: 'UK Regulatory', questionCount: 26, country: 'UK',
      description: 'Permit-to-work verification under Confined Spaces Regulations 1997: risk assessment, gas testing, entrant competence, and rescue planning', lastUpdated: 'Mar 2026'),
    Template(id: 'uk6', name: 'Asbestos Management Review (CAR 2012)', industry: 'General', category: 'UK Regulatory', questionCount: 24, country: 'UK',
      description: 'Duty to manage asbestos per Control of Asbestos Regulations 2012: ACM survey, material scoring, management controls, re-inspection, and awareness training', lastUpdated: 'Mar 2026'),
    Template(id: 'uk7', name: 'PUWER 1998 Work Equipment Inspection', industry: 'Manufacturing', category: 'UK Regulatory', questionCount: 25, country: 'UK',
      description: 'Provision & Use of Work Equipment Regulations 1998: suitability, guards & interlocks, maintenance records, emergency stops, and operator training', lastUpdated: 'Mar 2026'),
    Template(id: 'uk8', name: 'Scaffold Inspection (NASC TG20 / WAH 2005)', industry: 'Construction', category: 'UK Regulatory', questionCount: 27, country: 'UK',
      description: 'Pre-use scaffold inspection per Work at Height Regulations 2005 & NASC TG20: foundations, standards, bracing, boards, and edge protection', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // US OSHA Regulatory — fully compliant with 29 CFR
    // ════════════════════════════════════════════════
    Template(id: 'us1', name: 'OSHA Scaffolding Inspection (29 CFR 1926.451)', industry: 'Construction', category: 'US OSHA', questionCount: 28, country: 'US',
      description: 'Competent person scaffold inspection per 29 CFR 1926 Subpart L: foundations, planking, guardrails, access, capacity, and fall protection compliance', lastUpdated: 'Mar 2026'),
    Template(id: 'us2', name: 'OSHA Permit-Required Confined Space (29 CFR 1910.146)', industry: 'General', category: 'US OSHA', questionCount: 26, country: 'US',
      description: 'PRCS entry program audit per 29 CFR 1910.146: hazard evaluation, permit system, atmospheric testing, attendant duties, and rescue provisions', lastUpdated: 'Mar 2026'),
    Template(id: 'us3', name: 'OSHA Lockout/Tagout Verification (29 CFR 1910.147)', industry: 'Manufacturing', category: 'US OSHA', questionCount: 25, country: 'US',
      description: 'Control of hazardous energy (LOTO) program audit: energy isolation procedures, lock/tag devices, periodic inspections, and employee training per OSHA', lastUpdated: 'Mar 2026'),
    Template(id: 'us4', name: 'OSHA Fall Protection Compliance (29 CFR 1926.501)', industry: 'Construction', category: 'US OSHA', questionCount: 27, country: 'US',
      description: 'Fall protection systems audit per 29 CFR 1926 Subpart M: leading edges, hole covers, guardrails, safety nets, PFAS, training, and rescue planning', lastUpdated: 'Mar 2026'),
    Template(id: 'us5', name: 'OSHA Hazard Communication Audit (29 CFR 1910.1200)', industry: 'General', category: 'US OSHA', questionCount: 24, country: 'US',
      description: 'HazCom / GHS compliance audit: written program, SDS availability, container labelling, employee training, and chemical inventory per OSHA', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // AU WHS — Safe Work Australia / WHS Act 2011
    // ════════════════════════════════════════════════
    Template(id: 'au1', name: 'Working at Heights Inspection (WHS Regs Part 4.4)', industry: 'Construction', category: 'AU WHS', questionCount: 27, country: 'AU',
      description: 'Height safety compliance per WHS Regulations Part 4.4 (s 78-80): fall prevention hierarchy, scaffolds, EWPs, edge protection, anchor points, and rescue plans', lastUpdated: 'Mar 2026'),
    Template(id: 'au2', name: 'Confined Space Entry (AS 2865 / WHS Regs)', industry: 'General', category: 'AU WHS', questionCount: 26, country: 'AU',
      description: 'Confined space entry audit per AS 2865 and WHS Regs Part 4.3: risk assessment, entry permit, atmospheric monitoring, standby person, and emergency procedures', lastUpdated: 'Mar 2026'),
    Template(id: 'au3', name: 'Asbestos Management Plan Review (WHS Regs Ch 8)', industry: 'Construction', category: 'AU WHS', questionCount: 25, country: 'AU',
      description: 'PCBU duties under WHS Regulations Chapter 8: asbestos register, management plan, identification, labelling, air monitoring, and clearance certificates', lastUpdated: 'Mar 2026'),
    Template(id: 'au4', name: 'Plant & Equipment Risk Assessment (WHS Regs Ch 5)', industry: 'Manufacturing', category: 'AU WHS', questionCount: 26, country: 'AU',
      description: 'PCBU plant risk assessment per WHS Regulations Chapter 5, Part 5.1: design registration, guarding, maintenance, operator competency, and risk controls', lastUpdated: 'Mar 2026'),
    Template(id: 'au5', name: 'Excavation & Trenching Audit (WHS Regs Ch 6 Part 6.3)', industry: 'Construction', category: 'AU WHS', questionCount: 25, country: 'AU',
      description: 'Excavation safety per WHS Regulations Chapter 6, Part 6.3 (s 304-307): geotechnical assessment, shoring & benching, edge protection, underground services, and access/egress', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // Additional US OSHA — high-volume templates
    // ════════════════════════════════════════════════
    Template(id: 'us6', name: 'NFPA 70E Electrical Safety Audit', industry: 'General', category: 'US OSHA', questionCount: 25, country: 'US',
      description: 'Arc flash and electrical safety program audit per NFPA 70E and 29 CFR 1910 Subpart S: hazard analysis, PPE selection, energized work permits, approach boundaries, and labelling', lastUpdated: 'Mar 2026'),
    Template(id: 'us7', name: 'OSHA Powered Industrial Trucks (29 CFR 1910.178)', industry: 'Logistics & Warehousing', category: 'US OSHA', questionCount: 24, country: 'US',
      description: 'Forklift/PIT daily pre-shift inspection and operator compliance per 29 CFR 1910.178: truck condition, operator training, travel rules, load handling, and pedestrian safety', lastUpdated: 'Mar 2026'),
    Template(id: 'us8', name: 'DOT Pre-Trip Vehicle Inspection (49 CFR 396.13)', industry: 'Transportation', category: 'US OSHA', questionCount: 26, country: 'US',
      description: 'Commercial motor vehicle pre-trip inspection per 49 CFR 396.13 and DVIR requirements: brakes, tyres, lights, steering, coupling, emergency equipment, and driver documentation', lastUpdated: 'Mar 2026'),
    Template(id: 'us9', name: 'OSHA Respiratory Protection Program (29 CFR 1910.134)', industry: 'General', category: 'US OSHA', questionCount: 25, country: 'US',
      description: 'Respiratory protection program audit per 29 CFR 1910.134: written program, hazard evaluation, respirator selection, fit testing, medical evaluation, and maintenance', lastUpdated: 'Mar 2026'),
    Template(id: 'us10', name: 'OSHA Stairways & Ladders (29 CFR 1926 Subpart X)', industry: 'Construction', category: 'US OSHA', questionCount: 24, country: 'US',
      description: 'Stairway and ladder compliance per 29 CFR 1926.1050-1060: stairway construction, handrails, portable ladders, fixed ladders, and training requirements', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // Additional AU WHS — high-volume templates
    // ════════════════════════════════════════════════
    Template(id: 'au6', name: 'Electrical Test & Tag (AS/NZS 3760)', industry: 'General', category: 'AU WHS', questionCount: 24, country: 'AU',
      description: 'Portable electrical equipment inspection and testing per AS/NZS 3760: visual inspection, earth continuity, insulation resistance, RCD testing, tagging, and record keeping', lastUpdated: 'Mar 2026'),
    Template(id: 'au7', name: 'Fire Systems Compliance (AS 1851)', industry: 'General', category: 'AU WHS', questionCount: 25, country: 'AU',
      description: 'Routine service of fire protection systems per AS 1851: fire extinguishers, hydrants, sprinklers, fire detection and alarm, emergency lighting, and fire doors', lastUpdated: 'Mar 2026'),
    Template(id: 'au8', name: 'Traffic Management Plan Review (WHS Regs s 314)', industry: 'Construction', category: 'AU WHS', questionCount: 24, country: 'AU',
      description: 'Construction traffic management audit per WHS Regs s 314-316: TMP documentation, pedestrian separation, vehicle controls, signage, and speed management', lastUpdated: 'Mar 2026'),
    Template(id: 'au9', name: 'General Workplace WHS Audit (WHS Act 2011)', industry: 'General', category: 'AU WHS', questionCount: 26, country: 'AU',
      description: 'General WHS workplace inspection per WHS Act 2011 and Regulations: hazard identification, risk controls, consultation, incident reporting, and emergency preparedness', lastUpdated: 'Mar 2026'),
    Template(id: 'au10', name: 'Hazardous Chemical Register & SDS (WHS Regs Ch 7)', industry: 'Manufacturing', category: 'AU WHS', questionCount: 25, country: 'AU',
      description: 'Hazardous chemical management audit per WHS Regulations Chapter 7: chemical register, SDS availability, labelling (GHS), storage, exposure monitoring, and health surveillance', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // Canada (OHSA / provincial OHS) — new country
    // ════════════════════════════════════════════════
    Template(id: 'ca1', name: 'Workplace JHSC Inspection (OHSA s 9)', industry: 'General', category: 'CA OHS', questionCount: 26, country: 'CA',
      description: 'Joint Health & Safety Committee monthly workplace inspection per Ontario OHSA s 9: hazard identification, housekeeping, emergency equipment, PPE compliance, and documentation', lastUpdated: 'Mar 2026'),
    Template(id: 'ca2', name: 'Confined Space Entry (O. Reg. 632/05)', industry: 'General', category: 'CA OHS', questionCount: 25, country: 'CA',
      description: 'Confined space program audit per Ontario Regulation 632/05: hazard assessment, entry plan, atmospheric testing, rescue procedures, and worker training', lastUpdated: 'Mar 2026'),
    Template(id: 'ca3', name: 'Fall Protection (O. Reg. 213/91 s 26)', industry: 'Construction', category: 'CA OHS', questionCount: 25, country: 'CA',
      description: 'Construction fall protection per Ontario Reg. 213/91 s 26: guardrails, travel restraint, fall arrest, safety nets, work positioning, and rescue plans', lastUpdated: 'Mar 2026'),
    Template(id: 'ca4', name: 'WHMIS 2015 Compliance Audit (HPR)', industry: 'General', category: 'CA OHS', questionCount: 24, country: 'CA',
      description: 'WHMIS 2015 / GHS workplace inspection per Hazardous Products Regulations: SDS availability, supplier & workplace labels, worker education, and chemical inventory', lastUpdated: 'Mar 2026'),
    Template(id: 'ca5', name: 'Construction Health & Safety (O. Reg. 213/91)', industry: 'Construction', category: 'CA OHS', questionCount: 26, country: 'CA',
      description: 'General construction project safety per Ontario Reg. 213/91: project registration, signage, housekeeping, protective equipment, trenching, scaffolding, and electrical hazards', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // New Zealand (HSWA 2015 / HSW Regulations 2016)
    // ════════════════════════════════════════════════
    Template(id: 'nz1', name: 'General Workplace HSWA Audit', industry: 'General', category: 'NZ HSWA', questionCount: 26, country: 'NZ',
      description: 'PCBU workplace inspection per Health and Safety at Work Act 2015: risk management, worker engagement, hazard identification, notifiable events, and emergency procedures', lastUpdated: 'Mar 2026'),
    Template(id: 'nz2', name: 'Working at Height (HSW Regs Part 3 Subpart 2)', industry: 'Construction', category: 'NZ HSWA', questionCount: 25, country: 'NZ',
      description: 'Height safety per HSW (General Risk and Workplace Management) Regulations 2016 Part 3: hierarchy of controls, scaffolding, edge protection, harness systems, and rescue planning', lastUpdated: 'Mar 2026'),
    Template(id: 'nz3', name: 'Confined Space Entry (HSW Regs Part 3 Subpart 3)', industry: 'General', category: 'NZ HSWA', questionCount: 25, country: 'NZ',
      description: 'Confined space entry per HSW Regulations Part 3, Subpart 3: entry permits, atmospheric monitoring, standby person, ventilation, and emergency & rescue procedures', lastUpdated: 'Mar 2026'),
    Template(id: 'nz4', name: 'Asbestos Management (HSW Asbestos Regs 2016)', industry: 'Construction', category: 'NZ HSWA', questionCount: 24, country: 'NZ',
      description: 'Asbestos management per Health and Safety at Work (Asbestos) Regulations 2016: asbestos management plan, register, identification, exposure prevention, removal, and clearance', lastUpdated: 'Mar 2026'),
    Template(id: 'nz5', name: 'Construction Site Safety (HSW Regs Part 4)', industry: 'Construction', category: 'NZ HSWA', questionCount: 25, country: 'NZ',
      description: 'Construction work per HSW Regulations Part 4: principal contractor duties, site access, notifiable work, excavation, demolition, and traffic management', lastUpdated: 'Mar 2026'),

    // ════════════════════════════════════════════════
    // UK Industry-Specific — common compliance templates
    // ════════════════════════════════════════════════
    Template(id: 'uk9', name: 'Fire Risk Assessment (RRO 2005)', industry: 'General', category: 'UK Regulatory', questionCount: 30, country: 'UK',
      description: 'Regulatory Reform (Fire Safety) Order 2005 fire risk assessment: responsible person duties, fire hazard identification, people at risk, fire prevention measures, detection & warning systems, escape routes, maintenance, and emergency plan', lastUpdated: 'Mar 2026'),
    Template(id: 'uk10', name: 'DSE Workstation Assessment (HSE Regs 1992)', industry: 'Office & Retail', category: 'UK Regulatory', questionCount: 20, country: 'UK',
      description: 'Health and Safety (Display Screen Equipment) Regulations 1992 workstation assessment: screen position & settings, keyboard & mouse arrangement, desk & chair ergonomics, lighting & glare, work routine & breaks, and eye test provisions', lastUpdated: 'Mar 2026'),
    Template(id: 'uk11', name: 'Gas Safety Check (GSIUR 1998)', industry: 'Hospitality', category: 'UK Regulatory', questionCount: 22, country: 'UK',
      description: 'Gas Safety (Installation and Use) Regulations 1998: Gas Safe registered engineer check, appliance condition, flue and ventilation adequacy, gas tightness testing, emergency controls, and landlord gas safety certificate compliance', lastUpdated: 'Mar 2026'),
    Template(id: 'uk12', name: 'Electricity at Work Inspection (EWR 1989)', industry: 'General', category: 'UK Regulatory', questionCount: 24, country: 'UK',
      description: 'Electricity at Work Regulations 1989: fixed installation condition reports, portable appliance testing, isolation procedures, earth bonding, RCD protection, switchboard access, competent persons, and record keeping', lastUpdated: 'Mar 2026'),
    Template(id: 'uk13', name: 'Noise at Work Assessment (CNW Regs 2005)', industry: 'Manufacturing', category: 'UK Regulatory', questionCount: 22, country: 'UK',
      description: 'Control of Noise at Work Regulations 2005: noise exposure assessment, lower & upper exposure action values (80/85 dB), hearing protection zones, audiometric testing, noise reduction measures, and employee information', lastUpdated: 'Mar 2026'),
    Template(id: 'uk14', name: 'Vibration at Work Assessment (CVW Regs 2005)', industry: 'Construction', category: 'UK Regulatory', questionCount: 20, country: 'UK',
      description: 'Control of Vibration at Work Regulations 2005: HAV & WBV exposure assessment, exposure action & limit values, tool inventory and vibration magnitudes, health surveillance, and risk reduction measures', lastUpdated: 'Mar 2026'),
    Template(id: 'uk15', name: 'Manual Handling Assessment (MHO Regs 1992)', industry: 'General', category: 'UK Regulatory', questionCount: 22, country: 'UK',
      description: 'Manual Handling Operations Regulations 1992: TILE assessment (Task, Individual, Load, Environment), risk reduction hierarchy, mechanical aids, training records, and handling technique observation', lastUpdated: 'Mar 2026'),
    Template(id: 'uk16', name: 'Food Hygiene Inspection (FH Regs 2006)', industry: 'Hospitality', category: 'UK Regulatory', questionCount: 28, country: 'UK',
      description: 'Food Hygiene (England) Regulations 2006 / EC 852/2004: HACCP documented system, temperature monitoring, food storage & labelling, pest control, staff hygiene & training, cleaning schedules, allergen management, and waste disposal', lastUpdated: 'Mar 2026'),
    Template(id: 'uk17', name: 'RIDDOR Incident Investigation', industry: 'General', category: 'UK Regulatory', questionCount: 24, country: 'UK',
      description: 'Reporting of Injuries, Diseases and Dangerous Occurrences Regulations 2013 investigation: incident classification, root cause analysis, witness statements, immediate & underlying causes, corrective actions, and regulatory notification checklist', lastUpdated: 'Mar 2026'),
    Template(id: 'uk18', name: 'COSHH Assessment (COSHH Regs 2002)', industry: 'General', category: 'UK Regulatory', questionCount: 26, country: 'UK',
      description: 'Control of Substances Hazardous to Health Regulations 2002: substance inventory, hazard classification, exposure routes & controls, health surveillance, LEV checks, PPE provision, SDS availability, and COSHH assessment review schedule', lastUpdated: 'Mar 2026'),
    Template(id: 'uk19', name: 'Construction Phase Plan Review (CDM 2015 Reg 12)', industry: 'Construction', category: 'UK Regulatory', questionCount: 26, country: 'UK',
      description: 'CDM 2015 Regulation 12 construction phase plan review: project description, management arrangements, site rules, specific risks & controls, welfare provisions, site induction, emergency procedures, and monitoring arrangements', lastUpdated: 'Mar 2026'),
    Template(id: 'uk20', name: 'Workplace Transport Safety', industry: 'Logistics & Warehousing', category: 'UK Regulatory', questionCount: 24, country: 'UK',
      description: 'HSG136 workplace transport safety: traffic routes & separation, pedestrian walkways, vehicle speed controls, visibility & lighting, reversing procedures, loading/unloading safety, driver competence, and site rules', lastUpdated: 'Mar 2026'),
  ];
}
