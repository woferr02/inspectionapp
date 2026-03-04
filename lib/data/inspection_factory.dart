import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/services/auth_service.dart';

class InspectionFactory {
  /// Create an inspection from a template + chosen site.
  /// Uses the logged-in user's name as inspector.
  static Inspection fromTemplate(
    Template template, {
    Site? site,
    String? customName,
  }) {
    final inspectorName = AuthService.instance.displayName.isNotEmpty
        ? AuthService.instance.displayName
        : 'Inspector';

    final sectionDefs = _sectionsForTemplate(template);
    final totalQ = template.questionCount;

    // Distribute questions proportionally across sections
    final sections = _distributeSections(template.id, sectionDefs, totalQ);

    return Inspection(
      id: 'insp-${DateTime.now().millisecondsSinceEpoch}',
      name: customName ?? template.name,
      siteId: site?.id ?? '',
      siteName: site?.name ?? 'Unassigned',
      siteAddress: site?.address ?? '',
      date: DateTime.now(),
      status: InspectionStatus.draft,
      inspectorName: inspectorName,
      sections: sections,
    );
  }

  /// Generate contextual section names based on template industry + category.
  static List<String> _sectionsForTemplate(Template template) {
    final key = '${template.industry}::${template.category}'.toLowerCase();
    final name = template.name.toLowerCase();

    // ── Construction ──
    if (key.contains('construction') && key.contains('general site')) {
      return ['Site Access & Perimeter', 'PPE Compliance', 'Housekeeping & Welfare', 'Plant & Equipment', 'Working at Height'];
    }
    if (key.contains('construction') && key.contains('height')) {
      return ['Scaffold Structure', 'Platform & Decking', 'Guard Rails & Toe Boards', 'Access Ladders', 'Fall Protection Systems'];
    }
    if (key.contains('construction') && key.contains('ground')) {
      return ['Excavation Protection', 'Shoring Systems', 'Access & Egress', 'Nearby Services'];
    }
    if (key.contains('construction') && key.contains('plant')) {
      return ['Pre-Lift Planning', 'Crane Condition', 'Exclusion Zones', 'Signaller & Banksman', 'Load Security'];
    }
    if (key.contains('construction') && key.contains('demolition')) {
      return ['Structural Survey', 'Asbestos Check', 'Exclusion Zones', 'Sequence & Method', 'Dust & Noise Control'];
    }
    if (key.contains('construction') && key.contains('structural')) {
      return ['Design Check Certificates', 'Falsework Condition', 'Loading Checks', 'Propping Systems'];
    }
    if (key.contains('construction') && key.contains('permits')) {
      return ['Permit Documentation', 'Fire Precautions', 'Equipment Condition', 'Area Isolation'];
    }

    // ── Healthcare ──
    if (key.contains('healthcare') && key.contains('general')) {
      return ['Patient Area Safety', 'Infection Control', 'Medical Gas Systems', 'Emergency Equipment', 'Staff Welfare'];
    }
    if (key.contains('healthcare') && key.contains('waste')) {
      return ['Sharps Disposal', 'Colour-Coded Bins', 'Storage Areas', 'Transport Procedures'];
    }
    if (key.contains('healthcare') && key.contains('ergonomics')) {
      return ['Manual Handling Aids', 'Hoist Equipment', 'Staff Training Records', 'Risk Assessments'];
    }
    if (key.contains('healthcare') && key.contains('hygiene')) {
      return ['Hand Hygiene Stations', 'PPE Availability', 'Surface Cleaning', 'Isolation Procedures', 'Audit Compliance'];
    }
    if (key.contains('healthcare') && key.contains('systems')) {
      return ['Cylinder Storage', 'Pipeline Integrity', 'Alarm Systems', 'VIE Checks'];
    }
    if (key.contains('healthcare') && key.contains('storage')) {
      return ['Controlled Drug Registers', 'Temperature Monitoring', 'Access Controls', 'Expiry Management'];
    }
    if (key.contains('healthcare') && key.contains('labs')) {
      return ['Fume Cupboards', 'Chemical Labelling', 'Biological Agents', 'Eye Wash Stations', 'Waste Disposal'];
    }

    // ── Manufacturing ──
    if (key.contains('manufacturing') && key.contains('general')) {
      return ['Machine Guarding', 'Lockout/Tagout', 'Noise & Vibration', 'Process Safety', 'Housekeeping'];
    }
    if (key.contains('manufacturing') && key.contains('chemical')) {
      return ['Chemical Storage', 'MSDS Availability', 'Exposure Controls', 'PPE Requirements'];
    }
    if (key.contains('manufacturing') && key.contains('machinery')) {
      return ['Fixed Guards', 'Interlocks', 'Trip Devices', 'Two-Hand Controls', 'Emergency Stops'];
    }
    if (key.contains('manufacturing') && key.contains('energy')) {
      return ['Isolation Procedures', 'Lock Placement', 'Verification Steps', 'Group Lockout'];
    }
    if (key.contains('manufacturing') && key.contains('occupational')) {
      return ['Noise Dosimetry', 'Vibration Exposure', 'Hearing Protection', 'Health Surveillance'];
    }
    if (key.contains('manufacturing') && key.contains('automation')) {
      return ['Light Curtains', 'Safety-Rated Inputs', 'Teach Mode', 'Perimeter Fencing'];
    }

    // ── Office & Retail ──
    if (key.contains('office') && key.contains('general')) {
      return ['Workstation Setup', 'Fire Routes', 'First Aid', 'Workspace Organisation'];
    }
    if (key.contains('office') && key.contains('ergonomics')) {
      return ['Display Equipment', 'Seating & Posture', 'Lighting Levels', 'Break Frequency'];
    }
    if (key.contains('office') && key.contains('retail')) {
      return ['Customer Areas', 'Stockroom Access', 'Cash Handling', 'Trip Hazards'];
    }
    if (key.contains('office') && key.contains('personnel')) {
      return ['Communication Plans', 'Check-In Schedules', 'Emergency Procedures'];
    }
    if (key.contains('office') && key.contains('access')) {
      return ['Sign-In Procedures', 'Safety Briefings', 'Restricted Areas'];
    }

    // ── Logistics ──
    if (key.contains('logistics') && key.contains('warehouse')) {
      return ['Racking Integrity', 'Forklift Routes', 'Loading Bays', 'Storage Compliance', 'Emergency Equipment'];
    }
    if (key.contains('logistics') && key.contains('fleet')) {
      return ['Tyres & Brakes', 'Lights & Signals', 'Load Security', 'Driver Documents'];
    }
    if (key.contains('logistics') && key.contains('plant')) {
      return ['Forks & Mast', 'Hydraulics', 'Horn & Lights', 'Seatbelt & Restraints'];
    }
    if (key.contains('logistics') && key.contains('dock')) {
      return ['Dock Levellers', 'Wheel Chocks', 'Edge Protection', 'Dock Lighting'];
    }
    if (key.contains('logistics') && key.contains('storage')) {
      return ['SEMA Colour Coding', 'Upright Condition', 'Beam Locks', 'Load Notices'];
    }

    // ── Oil & Gas ──
    if (key.contains('oil') && key.contains('offshore')) {
      return ['Helideck Safety', 'Lifeboat Systems', 'Process Isolation', 'Permit-to-Work', 'Emergency Response'];
    }
    if (key.contains('oil') && key.contains('pipeline')) {
      return ['Corrosion Monitoring', 'Cathodic Protection', 'Valve Inspections', 'Leak Detection'];
    }
    if (key.contains('oil') && key.contains('permits')) {
      return ['Isolation Verification', 'Cross-Referencing', 'Handback Procedures'];
    }
    if (key.contains('oil') && key.contains('gas safety')) {
      return ['Detector Calibration', 'Wind Direction', 'Escape Routes', 'SCBA Equipment'];
    }
    if (key.contains('oil') && key.contains('process')) {
      return ['PSV Testing', 'Safety Instrumented Systems', 'HAZOP Actions', 'Alarm Management', 'Emergency Shutdown'];
    }

    // ── Education ──
    if (key.contains('education') && key.contains('general')) {
      return ['Playground Safety', 'Classroom Hazards', 'Corridors & Stairs', 'Fire Drill Records', 'Safeguarding'];
    }
    if (key.contains('education') && key.contains('labs')) {
      return ['Fume Cupboards', 'Chemical Storage', 'Eye Wash Stations', 'Gas Taps & Isolation'];
    }
    if (key.contains('education') && key.contains('sports')) {
      return ['Equipment Condition', 'Surface Integrity', 'Changing Rooms', 'First Aid Provision'];
    }
    if (key.contains('education') && key.contains('campus')) {
      return ['Lecture Halls', 'Residences', 'Workshops', 'Accessibility', 'External Areas'];
    }

    // ── Hospitality ──
    if (key.contains('hospitality') && key.contains('food')) {
      return ['HACCP Checkpoints', 'Temperature Logs', 'Cross-Contamination', 'Staff Hygiene', 'Pest Control'];
    }
    if (key.contains('hospitality') && key.contains('general')) {
      return ['Guest Room Safety', 'Corridors & Stairs', 'Pool & Leisure', 'Fire Systems', 'Emergency Exits'];
    }
    if (key.contains('hospitality') && key.contains('events')) {
      return ['Crowd Capacity', 'Temporary Structures', 'PA & Communication', 'Egress Routes'];
    }
    if (key.contains('hospitality') && key.contains('leisure')) {
      return ['Water Quality', 'Lifeguard Cover', 'Signage', 'Drain Covers'];
    }

    // ── Utilities ──
    if (key.contains('utilities') && key.contains('electrical')) {
      return ['HV Switchgear', 'Earthing Systems', 'Arc Flash Labels', 'Access Controls'];
    }
    if (key.contains('utilities') && key.contains('water')) {
      return ['Chemical Dosing', 'Confined Spaces', 'Biological Hazards', 'Emergency Equipment'];
    }
    if (key.contains('utilities') && key.contains('telecoms')) {
      return ['Climbing Systems', 'RF Exclusion Zones', 'Structural Integrity'];
    }
    if (key.contains('utilities') && key.contains('gas')) {
      return ['Leak Detection', 'Pressure Regulation', 'Valve Access', 'Warning Signage'];
    }

    // ── Agriculture ──
    if (key.contains('agriculture') && key.contains('general')) {
      return ['Machinery Storage', 'Chemical Sheds', 'Livestock Handling', 'Access Routes', 'Welfare Facilities'];
    }
    if (key.contains('agriculture') && key.contains('machinery')) {
      return ['PTO Guards', 'Roll Bars & ROPS', 'Brakes & Lights', 'Daily Pre-Use Checks'];
    }
    if (key.contains('agriculture') && key.contains('chemical')) {
      return ['Locked Storage', 'COSHH Compliance', 'PPE Provision', 'Application Records'];
    }
    if (key.contains('agriculture') && key.contains('livestock')) {
      return ['Crush Pens', 'Race Design', 'Flooring', 'Handler Escape Routes'];
    }
    if (key.contains('agriculture') && key.contains('storage')) {
      return ['Confined Space Entry', 'Dust Explosion Prevention', 'Structural Integrity'];
    }

    // ── Mining ──
    if (key.contains('mining') && key.contains('underground')) {
      return ['Ventilation Systems', 'Ground Support', 'Refuge Chambers', 'Escape Routes', 'Gas Monitoring'];
    }
    if (key.contains('mining') && key.contains('surface')) {
      return ['Bench Stability', 'Haul Road Design', 'Berm Heights', 'Blast Exclusion', 'Drainage'];
    }
    if (key.contains('mining') && key.contains('blasting')) {
      return ['Magazine Storage', 'Shot-Firer Competency', 'Fly-Rock Controls', 'Misfire Procedures'];
    }
    if (key.contains('mining') && key.contains('health')) {
      return ['Dust Suppression', 'Air Monitoring', 'RPE Provision', 'Health Surveillance'];
    }
    if (key.contains('mining') && key.contains('fleet')) {
      return ['Vehicle Condition', 'Proximity Detection', 'Seatbelt Compliance', 'Communication'];
    }

    // ── Transportation ──
    if (key.contains('transportation') && key.contains('rail')) {
      return ['Track Condition', 'Signalling', 'Level Crossings', 'Electrification Safety', 'Platform Safety'];
    }
    if (key.contains('transportation') && key.contains('aviation')) {
      return ['Ramp Operations', 'Jet Blast Zones', 'FOD Prevention', 'Pushback Safety'];
    }
    if (key.contains('transportation') && key.contains('marine')) {
      return ['Life-Saving Appliances', 'Fire Suppression', 'Hull Integrity', 'ISPS Compliance', 'Navigation Safety'];
    }
    if (key.contains('transportation') && key.contains('road')) {
      return ['Servicing Areas', 'Fuelling Safety', 'Wash Facilities', 'Driver Welfare'];
    }
    if (key.contains('transportation') && key.contains('ports')) {
      return ['Container Handling', 'Quay Edge Protection', 'Vessel Mooring', 'Crane Operations'];
    }

    // ── General (cross-industry) ──
    if (name.contains('fire') && !key.contains('uk regulatory')) {
      return ['Fire Extinguishers', 'Fire Alarms & Detection', 'Evacuation Routes', 'Fire Doors & Barriers'];
    }
    if (name.contains('electrical')) {
      return ['PAT Testing', 'Panel Access', 'Isolation Procedures', 'RCD Protection'];
    }
    if (name.contains('ppe')) {
      return ['Head Protection', 'Eye & Face Protection', 'Hearing Protection', 'Hand & Foot Protection'];
    }
    if (name.contains('height')) {
      return ['Ladders & Stepladders', 'Edge Protection', 'Harness & Lanyards', 'Rescue Plans'];
    }
    if (name.contains('confined')) {
      return ['Atmosphere Testing', 'Permit System', 'Rescue Equipment', 'Communication'];
    }
    if (name.contains('risk assessment')) {
      return ['Hazard Identification', 'Control Measures', 'Review & Update'];
    }
    if (name.contains('first aid')) {
      return ['Kit Contents', 'Trained Personnel', 'AED Checks', 'Signage'];
    }
    if (name.contains('slip') || name.contains('trip')) {
      return ['Floor Surfaces', 'Cable Management', 'Warning Signage', 'Drainage'];
    }
    if (name.contains('environmental')) {
      return ['Waste Segregation', 'Spill Kits', 'Emissions Monitoring', 'Discharge Permits'];
    }
    if (name.contains('emergency')) {
      return ['Evacuation Drills', 'Assembly Points', 'Communication Plans', 'Emergency Equipment'];
    }
    if (name.contains('manual handling') && !key.contains('uk regulatory')) {
      return ['Lifting Techniques', 'Load Weights', 'Mechanical Aids', 'Training Records'];
    }
    if (name.contains('contractor')) {
      return ['Insurance Verification', 'Method Statements', 'RAMS Review', 'Competency Check'];
    }
    if (name.contains('violence') || name.contains('security')) {
      return ['Threat Assessment', 'Alarm Systems', 'Lone Worker Plans', 'De-Escalation'];
    }
    if (name.contains('asbestos')) {
      return ['Register Review', 'Condition Assessment', 'Labelling', 'Management Plan'];
    }
    if (name.contains('legionella') && !key.contains('uk regulatory')) {
      return ['Water System Mapping', 'Temperature Checks', 'Dead Legs', 'Treatment Logs'];
    }

    // ── UK HSE Regulatory templates (fully compliant) ──
    if (key.contains('uk regulatory')) {
      // CDM 2015 Welfare Facilities Audit
      if (name.contains('cdm') && name.contains('welfare')) {
        return ['Sanitary Conveniences', 'Washing Facilities', 'Drinking Water Provision', 'Rest & Welfare Areas', 'Changing & Drying Rooms'];
      }
      // LOLER 1998 Lifting Equipment Exam
      if (name.contains('loler')) {
        return ['Equipment Identity & SWL Markings', 'Structural Integrity Check', 'Overload & Limit Devices', 'Wire Ropes & Lifting Accessories', 'Operational & Load Testing'];
      }
      // LEV Thorough Examination (COSHH Reg 9)
      if (name.contains('lev')) {
        return ['Hood & Capture Point', 'Ductwork & Joints', 'Filter & Collector Unit', 'Fan & Motor Assembly', 'Airflow & Containment Verification'];
      }
      // Legionella L8 Compliance Audit
      if (name.contains('legionella') || name.contains('l8')) {
        return ['Cold Water Tanks & Pipework', 'Hot Water Calorifiers & TMVs', 'Stagnation & Low-Use Outlets', 'Legionella Sampling & Records', 'Responsible Person & L8 Duties'];
      }
      // Confined Space Entry Audit (CS Regs 1997)
      if (name.contains('confined')) {
        return ['Entry Risk Assessment Review', 'Permit-to-Work Verification', 'Gas Testing & Continuous Monitoring', 'Entrant Competence & PPE', 'Retrieval & Emergency Plan'];
      }
      // Asbestos Management Review (CAR 2012)
      if (name.contains('asbestos')) {
        return ['ACM Survey & Dutyholder Record', 'ACM Scoring & Type Identification', 'Asbestos Management Controls', 'Re-inspection & Clearance Monitoring', 'Asbestos Awareness & Permits'];
      }
      // PUWER 1998 Work Equipment Inspection
      if (name.contains('puwer')) {
        return ['Equipment Suitability & Selection', 'Guards & Interlock Devices', 'Maintenance Log & Defect Records', 'Controls & Emergency Stops', 'Operator Training & Safe Use'];
      }
      // Scaffold Inspection (NASC TG20 / WAH 2005)
      if (name.contains('scaffold') || name.contains('nasc')) {
        return ['Foundations & Base Plates', 'Standards, Ledgers & Couplers', 'Bracing & Tie Patterns', 'Scaffold Boards & Decking', 'Edge Protection & Ladder Access'];
      }

      // ── UK Industry-Specific Compliance (uk9–uk20) ──

      // Fire Risk Assessment (RRO 2005)
      if (name.contains('fire risk assessment')) {
        return ['Fire Risk Assessment', 'Fire Alarms & Detection', 'Evacuation Routes', 'Fire Doors & Barriers', 'Fire Training & Drills'];
      }
      // DSE Workstation Assessment (HSE Regs 1992)
      if (name.contains('dse workstation')) {
        return ['DSE Workstation', 'Display Equipment', 'Seating & Posture', 'Lighting Levels'];
      }
      // Gas Safety Check (GSIUR 1998)
      if (name.contains('gas safety')) {
        return ['Gas Safety', 'Flue & Ventilation', 'CO Detection & Certificate'];
      }
      // Electricity at Work (EWR 1989)
      if (name.contains('electricity at work')) {
        return ['Electricity at Work', 'PAT Testing', 'Isolation Procedures', 'RCD Protection'];
      }
      // Noise at Work (CNW Regs 2005)
      if (name.contains('noise at work')) {
        return ['Noise at Work', 'Hearing Protection', 'Noise Dosimetry'];
      }
      // Vibration at Work (CVW Regs 2005)
      if (name.contains('vibration at work')) {
        return ['Vibration at Work', 'Vibration Exposure', 'Health Surveillance'];
      }
      // Manual Handling Assessment (MHO Regs 1992)
      if (name.contains('manual handling')) {
        return ['Manual Handling Assessment', 'Mechanical Aids', 'Training Records'];
      }
      // Food Hygiene Inspection (FH Regs 2006)
      if (name.contains('food hygiene')) {
        return ['Food Hygiene', 'Temperature Logs', 'Cross-Contamination', 'Staff Hygiene', 'Pest Control'];
      }
      // RIDDOR Incident Investigation
      if (name.contains('riddor')) {
        return ['RIDDOR Incident', 'Scene Preservation & Witnesses', 'Root Cause & Corrective Actions'];
      }
      // COSHH Assessment (COSHH Regs 2002)
      if (name.contains('coshh assessment')) {
        return ['COSHH Assessment', 'Chemical Storage', 'Exposure Controls', 'Health Surveillance'];
      }
      // Construction Phase Plan Review (CDM 2015 Reg 12)
      if (name.contains('construction phase plan')) {
        return ['Construction Phase Plan', 'Site Rules & Induction', 'Emergency Procedures'];
      }
      // Workplace Transport Safety (HSG136)
      if (name.contains('workplace transport')) {
        return ['Workplace Transport', 'Pedestrian Safety', 'Loading & Unloading'];
      }
    }

    // ── US OSHA Regulatory templates (29 CFR compliant) ──
    if (key.contains('us osha')) {
      // OSHA Scaffolding Inspection (29 CFR 1926.451)
      if (name.contains('scaffold') && name.contains('1926.451')) {
        return ['Foundation & Sill Assessment', 'Planking & Platform Integrity', 'Guardrail & Midrail Systems', 'Access Points & Climbing Devices', 'Capacity & Load Compliance', 'Fall Protection & Competent Person'];
      }
      // OSHA Permit-Required Confined Space (29 CFR 1910.146)
      if (name.contains('confined') && name.contains('1910.146')) {
        return ['Space Classification & Inventory', 'Written Program & Permits', 'Atmospheric Testing Procedures', 'Attendant & Communication Duties', 'Rescue & Emergency Services'];
      }
      // OSHA Lockout/Tagout (29 CFR 1910.147)
      if (name.contains('lockout') || name.contains('loto')) {
        return ['Energy Control Program Review', 'Lock & Tag Device Adequacy', 'Machine-Specific Procedures', 'Periodic Inspection Records', 'Employee Training & Authorisation'];
      }
      // OSHA Fall Protection Compliance (29 CFR 1926.501)
      if (name.contains('fall protection') && name.contains('1926.501')) {
        return ['Leading Edge & Unprotected Sides', 'Hole Covers & Guardrail Systems', 'Personal Fall Arrest Systems', 'Safety Net & Controlled Access Zones', 'Rescue Planning & Training'];
      }
      // OSHA Hazard Communication (29 CFR 1910.1200)
      if (name.contains('hazard communication') || name.contains('hazcom')) {
        return ['Written HazCom Program', 'Safety Data Sheet Management', 'Container Labelling & GHS', 'Employee Training & Information'];
      }
      // NFPA 70E Electrical Safety Audit
      if (name.contains('nfpa 70e') || name.contains('electrical safety')) {
        return ['Arc Flash Hazard Analysis', 'Energized Electrical Work Permits', 'Approach Boundaries & PPE Selection', 'Equipment Labelling & Documentation', 'Training & Qualification Records'];
      }
      // OSHA Powered Industrial Trucks (29 CFR 1910.178)
      if (name.contains('powered industrial') || name.contains('1910.178')) {
        return ['Pre-Shift Truck Condition Check', 'Operator Training & Certification', 'Travel & Operating Rules', 'Load Handling & Stability', 'Pedestrian Safety & Awareness'];
      }
      // DOT Pre-Trip Vehicle Inspection (49 CFR 396.13)
      if (name.contains('dot') && name.contains('pre-trip')) {
        return ['Engine, Cab & Mirrors', 'Brakes, Tyres & Wheels', 'Lights, Signals & Reflectors', 'Steering, Suspension & Coupling', 'Emergency Equipment & Documentation'];
      }
      // OSHA Respiratory Protection Program (29 CFR 1910.134)
      if (name.contains('respiratory') && name.contains('1910.134')) {
        return ['Written Program & Administration', 'Hazard Evaluation & Respirator Selection', 'Medical Evaluation & Fit Testing', 'Respirator Use & Maintenance', 'Training & Program Evaluation'];
      }
      // OSHA Stairways & Ladders (29 CFR 1926 Subpart X)
      if (name.contains('stairways') || name.contains('subpart x')) {
        return ['Stairway Construction & Handrails', 'Portable Ladder Condition & Use', 'Fixed Ladder & Cage Systems', 'Ladder Placement & Securing', 'Training & Competent Person'];
      }
    }

    // ── AU WHS templates (Safe Work Australia / WHS Act 2011) ──
    if (key.contains('au whs')) {
      // Working at Heights Inspection (WHS Regs Ch 6)
      if (name.contains('height') && name.contains('whs')) {
        return ['Fall Prevention Hierarchy Review', 'Scaffold & EWP Condition', 'Edge Protection & Penetrations', 'Anchor Points & Harness Systems', 'Emergency Rescue Provisions'];
      }
      // Confined Space Entry (AS 2865 / WHS Regs)
      if (name.contains('confined') && name.contains('as 2865')) {
        return ['Confined Space Risk Assessment', 'Entry Permit & Signage', 'Atmospheric Monitoring Equipment', 'Standby Person & Communication', 'Emergency & Rescue Procedure'];
      }
      // Asbestos Management Plan Review (WHS Regs Ch 8)
      if (name.contains('asbestos') && name.contains('whs')) {
        return ['Asbestos Register Completeness', 'Management Plan & PCBU Duties', 'Identification & Labelling', 'Air Monitoring & Exposure Controls', 'Clearance Certificates & Records'];
      }
      // Plant & Equipment Risk Assessment (WHS Regs Ch 5)
      if (name.contains('plant') && name.contains('whs')) {
        return ['Design Registration & Compliance', 'Guarding & Safety Devices', 'Maintenance & Inspection Records', 'Operator Competency & Licensing', 'Risk Control Hierarchy'];
      }
      // Excavation & Trenching Audit (WHS Regs Ch 7)
      if (name.contains('excavation') && name.contains('whs')) {
        return ['Geotechnical Assessment & Soil Type', 'Shoring, Benching & Battering', 'Edge Protection & Barricading', 'Underground Services Location', 'Access, Egress & Dewatering'];
      }
      // Electrical Test & Tag (AS/NZS 3760)
      if (name.contains('test & tag') || name.contains('3760')) {
        return ['Visual Inspection & Condition', 'Earth Continuity Testing', 'Insulation Resistance Testing', 'RCD Testing & Functionality', 'Tagging, Records & Compliance'];
      }
      // Fire Systems Compliance (AS 1851)
      if (name.contains('fire') && name.contains('1851')) {
        return ['Fire Extinguisher Servicing', 'Hydrant & Hose Reel Systems', 'Sprinkler & Suppression Systems', 'Detection, Alarm & Warning', 'Emergency Lighting & Exit Signs'];
      }
      // Traffic Management Plan (WHS Regs s 314)
      if (name.contains('traffic management')) {
        return ['TMP Documentation & Approval', 'Pedestrian & Vehicle Separation', 'Signage & Speed Controls', 'Plant & Vehicle Movement', 'Monitoring & Review'];
      }
      // General Workplace WHS Audit (WHS Act 2011)
      if (name.contains('workplace') && name.contains('whs')) {
        return ['Hazard Identification & Risk', 'Consultation & Communication', 'Incident Reporting & Investigation', 'Emergency Preparedness', 'WHS Documentation & Records'];
      }
      // Hazardous Chemical Register & SDS (WHS Regs Ch 7)
      if (name.contains('hazardous chemical') || (name.contains('chemical') && name.contains('ch 7'))) {
        return ['Chemical Register & Manifest', 'SDS Availability & Currency', 'GHS Labelling Compliance', 'Storage & Segregation', 'Exposure Monitoring & Health Surveillance'];
      }
    }

    // ── Canadian OHS Regulatory templates ──
    if (key.contains('ca ohs')) {
      // Workplace JHSC Inspection (OHSA s 9)
      if (name.contains('jhsc') || name.contains('ohsa s 9')) {
        return ['Workplace Hazard Walkthrough', 'Housekeeping & Organisation', 'Emergency Equipment & Exits', 'PPE Compliance & Availability', 'Documentation & JHSC Records'];
      }
      // Confined Space Entry (O. Reg. 632/05)
      if (name.contains('confined') && name.contains('632')) {
        return ['Space Hazard Assessment', 'Entry Plan & Permits', 'Atmospheric Testing & Monitoring', 'Rescue Procedures & Equipment', 'Worker Training & Competency'];
      }
      // Fall Protection (O. Reg. 213/91 s 26)
      if (name.contains('fall protection') && name.contains('213')) {
        return ['Guardrail Systems & Covers', 'Travel Restraint Systems', 'Fall Arrest Systems & Anchors', 'Safety Nets & Work Positioning', 'Rescue Plans & Training'];
      }
      // WHMIS 2015 Compliance Audit (HPR)
      if (name.contains('whmis')) {
        return ['SDS Availability & 16-Section Format', 'Supplier Label Compliance', 'Workplace Label Requirements', 'Worker Education & Training', 'Chemical Inventory & Records'];
      }
      // Construction Health & Safety (O. Reg. 213/91)
      if (name.contains('construction') && name.contains('213')) {
        return ['Project Registration & Notice', 'Site Signage & Access Control', 'Housekeeping & Material Storage', 'Protective Equipment & Clothing', 'Scaffolding, Trenching & Electrical'];
      }
    }

    // ── New Zealand HSWA templates ──
    if (key.contains('nz hswa')) {
      // General Workplace HSWA Audit
      if (name.contains('workplace') && name.contains('hswa')) {
        return ['PCBU Duties & Risk Management', 'Worker Engagement & Participation', 'Hazard Identification & Control', 'Notifiable Event Procedures', 'Emergency Planning & Preparedness'];
      }
      // Working at Height (HSW Regs Part 3 Subpart 2)
      if (name.contains('height') && name.contains('hsw')) {
        return ['Height Work Risk Assessment', 'Scaffolding & EWP Compliance', 'Edge Protection & Barriers', 'Harness Systems & Anchor Points', 'Rescue & Emergency Provisions'];
      }
      // Confined Space Entry (HSW Regs Part 3 Subpart 3)
      if (name.contains('confined') && name.contains('hsw')) {
        return ['Entry Permit & Risk Assessment', 'Atmospheric Monitoring', 'NZ Standby Person & Communication', 'Ventilation & Hazard Controls', 'Emergency & Rescue Procedures'];
      }
      // Asbestos Management (HSW Asbestos Regs 2016)
      if (name.contains('asbestos') && name.contains('hsw')) {
        return ['Asbestos Management Plan', 'Asbestos Register & Identification', 'Exposure Prevention Controls', 'Asbestos Removal Procedures', 'Clearance & Record Keeping'];
      }
      // Construction Site Safety (HSW Regs Part 4)
      if (name.contains('construction') && name.contains('hsw')) {
        return ['Principal Contractor Duties', 'Site Access & Induction', 'Notifiable Work Compliance', 'Excavation & Demolition Safety', 'Traffic Management & Signage'];
      }
    }

    // ── Fallback ──
    return ['Pre-Inspection Setup', 'Core Safety Checks', 'Documentation & Closeout'];
  }

  /// Distribute total questions across sections proportionally.
  static List<InspectionSection> _distributeSections(
    String templateId,
    List<String> sectionNames,
    int totalQuestions,
  ) {
    if (sectionNames.isEmpty) {
      return [
        InspectionSection(
          id: '$templateId-s1',
          name: 'General Checks',
          questionCount: totalQuestions,
          completedCount: 0,
        ),
      ];
    }

    final n = sectionNames.length;
    final base = totalQuestions ~/ n;
    var remainder = totalQuestions % n;

    return sectionNames.asMap().entries.map((entry) {
      final i = entry.key;
      final name = entry.value;
      final extra = remainder > 0 ? 1 : 0;
      if (remainder > 0) remainder--;
      final qCount = base + extra;
      return InspectionSection(
        id: '$templateId-s${i + 1}',
        name: name,
        questionCount: qCount > 0 ? qCount : 1,
        completedCount: 0,
      );
    }).toList();
  }
}
