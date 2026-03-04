/// Maps section names to contextual check-item questions.
/// Each question has an id, title, and a brief description.
class QuestionBank {
  /// Returns a list of questions for the given section name
  /// with the expected [count].
  static List<Map<String, String>> forSection(String sectionName, int count) {
    final key = sectionName.toLowerCase();

    // Find the BEST (longest/most-specific) match from our bank.
    // Sort candidates by key length descending so 'atmospheric testing
    // procedures' beats 'atmosphere' when both are substrings.
    List<Map<String, String>>? base;
    final sorted = _bank.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in sorted) {
      if (key.contains(entry.key)) {
        base = entry.value;
        break;
      }
    }

    // If no match, generate generic questions from the section name
    base ??= _genericForSection(sectionName);

    // If we have enough, take what we need
    if (base.length >= count) {
      return base.take(count).toList().asMap().entries.map((e) {
        return {
          'id': 'q${e.key + 1}',
          'title': e.value['title']!,
          'desc': e.value['desc']!,
        };
      }).toList();
    }

    // Otherwise, pad with generated extras
    final result = <Map<String, String>>[];
    for (var i = 0; i < count; i++) {
      if (i < base.length) {
        result.add({
          'id': 'q${i + 1}',
          'title': base[i]['title']!,
          'desc': base[i]['desc']!,
        });
      } else {
        result.add({
          'id': 'q${i + 1}',
          'title': '$sectionName check ${i + 1 - base.length}',
          'desc':
              'Verify compliance and document observations for this control.',
        });
      }
    }
    return result;
  }

  static List<Map<String, String>> _genericForSection(String sectionName) {
    return [
      {
        'title': 'Is the $sectionName area safe and accessible?',
        'desc': 'Check access, lighting, and general condition.'
      },
      {
        'title': 'Are all required signs and labels posted?',
        'desc': 'Verify safety signage is visible and not damaged.'
      },
      {
        'title': 'Is all $sectionName equipment in working order?',
        'desc': 'Visual inspection; check service tags and dates.'
      },
      {
        'title': 'Are relevant procedures documented and available?',
        'desc': 'Confirm SOPs, risk assessments, or permits are in place.'
      },
      {
        'title': 'Have personnel been trained for $sectionName tasks?',
        'desc': 'Check training records and competency certificates.'
      },
      {
        'title': 'Are PPE requirements met in this area?',
        'desc': 'Verify correct PPE is available and in good condition.'
      },
    ];
  }

  // ── Keyword → question bank ──
  //
  // Keys are checked via `sectionName.toLowerCase().contains(key)`.
  // Order matters: more specific keys first.
  static const _bank = <String, List<Map<String, String>>>{
    // ────── Fire ──────
    'fire extinguisher': [
      {'title': 'Are fire extinguishers serviced and in date?', 'desc': 'Check service tags for expiry within 12 months'},
      {'title': 'Is the correct extinguisher type provided for the area?', 'desc': 'Verify CO₂, water, foam or powder matches risk profile'},
      {'title': 'Are extinguishers mounted at the correct height?', 'desc': 'Should be wall-mounted with handle at approx. 1.0–1.2m'},
      {'title': 'Are extinguisher locations clearly signed?', 'desc': 'Red ID signs visible from 20m+ with correct pictograms'},
      {'title': 'Are access routes to extinguishers unobstructed?', 'desc': 'No stacking, vehicles, or furniture blocking access'},
      {'title': 'Has a visual damage check been recorded this month?', 'desc': 'Check for dents, corrosion, broken seals, or missing pins'},
      {'title': 'Is the pressure gauge in the green zone?', 'desc': 'Applicable to stored-pressure types; check needle position'},
      {'title': 'Are extinguisher tamper seals intact?', 'desc': 'Safety pin present with unbroken seal tag'},
    ],
    'fire alarm': [
      {'title': 'Is the fire alarm system tested weekly?', 'desc': 'Review test log for weekly call-point activation'},
      {'title': 'Are all call points accessible and undamaged?', 'desc': 'Walk the building checking each manual call point'},
      {'title': 'Do all sounders/strobes activate during test?', 'desc': 'Confirm audible/visual coverage in every zone'},
      {'title': 'Is the alarm panel free of faults and alerts?', 'desc': 'No persistent fault LEDs or disabled zones'},
      {'title': 'Is the fire alarm log book up to date?', 'desc': 'Weekly tests, quarterly servicing, and false alarm records'},
    ],
    'evacuation': [
      {'title': 'Are fire evacuation routes clearly marked and unobstructed?', 'desc': 'Check illuminated exit signs and clear escape paths'},
      {'title': 'Are fire assembly points identified with clear signage?', 'desc': 'Confirm signage visibility from all building exits'},
      {'title': 'Has a fire drill been conducted this quarter?', 'desc': 'Review drill records, timing, and occupant participation'},
      {'title': 'Are evacuation plans posted on each floor?', 'desc': 'Current plans showing "You Are Here" marker and routes'},
      {'title': 'Are roll-call procedures documented and understood?', 'desc': 'Named fire wardens, sweep routes, and headcount process'},
    ],
    'fire door': [
      {'title': 'Do all fire doors close fully on their own?', 'desc': 'Check self-closing mechanism operates from any position'},
      {'title': 'Are fire door seals and intumescent strips intact?', 'desc': 'No gaps, paint-over, or missing strips'},
      {'title': 'Are fire doors free from wedges or propping?', 'desc': 'Only approved hold-open devices connected to alarm'},
      {'title': 'Are fire door signs correct (Keep Shut / Fire Door)?', 'desc': 'Blue mandatory signs on both faces'},
    ],

    // ────── PPE ──────
    'head protection': [
      {'title': 'Are hard hats available at all entry points?', 'desc': 'Check supply and conditon at muster / entry areas'},
      {'title': 'Are hard hats in good condition (no cracks, UV damage)?', 'desc': 'Inspect shells and cradles for degradation'},
      {'title': 'Are chin straps used where required?', 'desc': 'Mandatory at height or in windy conditions'},
      {'title': 'Are hard hats within their replacement date?', 'desc': 'Typical lifespan 2–5 years depending on material'},
    ],
    'eye': [
      {'title': 'Are safety glasses/goggles available for all workers?', 'desc': 'Confirm stock levels match headcount'},
      {'title': 'Are eye protection types appropriate for the hazard?', 'desc': 'Splash goggles for chemicals, side-shields for impact'},
      {'title': 'Are eye wash stations accessible and tested?', 'desc': 'Flush checks monthly, within 10 seconds walking distance'},
      {'title': 'Are prescription safety glasses provided where needed?', 'desc': 'Check availability for workers who require corrective lenses'},
    ],
    'hearing protection': [
      {'title': 'Are hearing protection zones clearly marked?', 'desc': 'Signs at entries to areas exceeding 85 dB(A)'},
      {'title': 'Is appropriate hearing protection available?', 'desc': 'Plugs or muffs with SNR matching noise exposure'},
      {'title': 'Are workers trained in correct fitting?', 'desc': 'Roll-down technique for plugs, seal test for muffs'},
      {'title': 'Are hearing protection dispensers stocked?', 'desc': 'Check wall-mounted dispenser bin levels'},
    ],
    'hand': [
      {'title': 'Are correct glove types available for each task?', 'desc': 'Chemical, cut-resistant, thermal per risk assessment'},
      {'title': 'Are gloves in good condition (no tears or contamination)?', 'desc': 'Visual check before use; discard damaged pairs'},
      {'title': 'Are workers trained on glove selection?', 'desc': 'Understand EN cut levels, chemical permeation data'},
    ],
    'foot': [
      {'title': 'Are safety boots/shoes worn by all site personnel?', 'desc': 'Steel/composite toe, appropriate sole rating'},
      {'title': 'Is footwear in good condition?', 'desc': 'No sole separation, worn tread, or exposed toe caps'},
      {'title': 'Are anti-static or ESD shoes used where required?', 'desc': 'ATEX/EX zones or electronic manufacturing areas'},
    ],

    // ────── Scaffold ──────
    'scaffold': [
      {'title': 'Has the scaffold been inspected by a competent person?', 'desc': 'Valid scaffold tag with inspection date < 7 days'},
      {'title': 'Are all base plates and sole boards in place?', 'desc': 'Level, firm ground; no missing sole boards'},
      {'title': 'Are standards plumb and bracing complete?', 'desc': 'No leaning; all diagonal and ledger braces fitted'},
      {'title': 'Are all platform boards secure and fully decked?', 'desc': 'No gaps > 25mm, boards wired or clipped'},
      {'title': 'Are guard rails at the correct height (950mm min)?', 'desc': 'Top rail, mid rail, and toe board all present'},
      {'title': 'Is the scaffold tag/permit clearly displayed?', 'desc': 'Green tag = safe to use; check date and load class'},
      {'title': 'Are access ladders secured and extending above platform?', 'desc': 'At least 1m above landing with secure ties'},
      {'title': 'Is there adequate edge protection on all open sides?', 'desc': 'Including inside edge on double-boarded scaffolds'},
      {'title': 'Are scaffold ties in place at required intervals?', 'desc': 'Through-tie or lip type as per design drawing'},
    ],
    'platform': [
      {'title': 'Are all platform boards complete with no gaps?', 'desc': 'Maximum gap 25mm; no trap doors or missing boards'},
      {'title': 'Are platform surfaces free from slip hazards?', 'desc': 'No ice, grease, loose materials, or excessive debris'},
      {'title': 'Is the platform load within the rated capacity?', 'desc': 'Check load notice matches actual stored materials'},
    ],
    'guard rail': [
      {'title': 'Are top guard rails installed at 950mm minimum?', 'desc': 'Measured from the working platform surface'},
      {'title': 'Are mid rails fitted between top rail and toe board?', 'desc': 'No unprotected gap greater than 470mm'},
      {'title': 'Are toe boards at least 150mm high?', 'desc': 'Prevents tools and materials rolling off the edge'},
    ],

    // ────── Excavation ──────
    'excavation': [
      {'title': 'Are excavation edges protected with barriers?', 'desc': 'Guardrails or stop blocks at least 1m from edge'},
      {'title': 'Has a utility / service scan been completed?', 'desc': 'CAT & Genny scan before breaking ground'},
      {'title': 'Is shoring or battering adequate for depth?', 'desc': 'Compliant with soil classification and depth'},
      {'title': 'Is there safe access in/out of the excavation?', 'desc': 'Ladder or steps within 15m of any worker'},
      {'title': 'Are stockpiles stored away from the excavation edge?', 'desc': 'Minimum 1m setback to prevent collapse'},
    ],

    // ────── HACCP / Kitchen ──────
    'haccp': [
      {'title': 'Are critical control points documented and monitored?', 'desc': 'CCP decision tree applied; records current'},
      {'title': 'Are temperature logs completed for all chillers/freezers?', 'desc': 'Twice daily; corrective actions for out-of-range'},
      {'title': 'Is probe calibration up to date?', 'desc': 'Calibrated thermometer with certificate'},
      {'title': 'Are allergen controls clearly posted?', 'desc': 'Allergen matrix, labelling, and segregation'},
    ],
    'temperature': [
      {'title': 'Are fridges at or below 5°C?', 'desc': 'Check digital display and probe verify'},
      {'title': 'Are freezers at or below –18°C?', 'desc': 'Check digital display; note any defrost cycles'},
      {'title': 'Are hot-hold foods maintained above 63°C?', 'desc': 'Probe check; discard if below 63°C for 2+ hours'},
      {'title': 'Are delivery temperatures within specification?', 'desc': 'Chilled ≤5°C, frozen ≤–15°C; reject if non-compliant'},
    ],
    'cross-contamination': [
      {'title': 'Are raw and cooked foods stored separately?', 'desc': 'Raw below cooked in fridge; separate prep areas'},
      {'title': 'Are colour-coded chopping boards in use?', 'desc': 'Red=raw meat, blue=fish, green=salad, etc.'},
      {'title': 'Is hand washing carried out between tasks?', 'desc': 'Observe and check soap/paper towel supply'},
    ],
    'hygiene': [
      {'title': 'Are hand washing facilities fully stocked?', 'desc': 'Hot water, soap, paper towels, signage'},
      {'title': 'Are cleaning schedules in place and signed off?', 'desc': 'Daily/weekly/deep-clean rotas with sign-off columns'},
      {'title': 'Are food handlers wearing appropriate clothing?', 'desc': 'Clean uniform, hair nets, no jewellery, nail checks'},
      {'title': 'Are pest control measures in place?', 'desc': 'Bait stations, fly screens, contractor visit records'},
    ],

    // ────── Electrical ──────
    'pat testing': [
      {'title': 'Are all portable appliances PAT tested and labelled?', 'desc': 'Check sticker dates; pass within 12 months'},
      {'title': 'Are leads and plugs in good visual condition?', 'desc': 'No cuts, exposed wires, cracked casings, or scorch marks'},
      {'title': 'Are extension leads used safely (no daisy-chains)?', 'desc': 'Single extension per socket; fully unwound'},
    ],
    'panel': [
      {'title': 'Are electrical panels accessible (1m clear zone)?', 'desc': 'No storage, obstructions, or blocked access'},
      {'title': 'Are panel covers secured and labelled?', 'desc': 'Circuit directory current; all breakers identified'},
      {'title': 'Is there an isolation procedure posted?', 'desc': 'Emergency isolation switch location clearly marked'},
    ],
    'isolation': [
      {'title': 'Are isolation points clearly identified?', 'desc': 'Labels, colour coding, or lock-out points signed'},
      {'title': 'Is a lock-out/tag-out (LOTO) system in use?', 'desc': 'Personal locks, danger tags, and try-before-work'},
      {'title': 'Are isolations verified before work begins?', 'desc': 'Prove dead with approved voltage indicator'},
    ],
    'rcd': [
      {'title': 'Are RCDs tested quarterly with test button?', 'desc': 'Record results; trip time should be < 300ms'},
      {'title': 'Are all 230V site tools protected by 30mA RCD?', 'desc': 'Plug-in RCDs or fixed board protection'},
    ],

    // ────── Confined Space ──────
    'atmosphere': [
      {'title': 'Has atmosphere testing been carried out before entry?', 'desc': 'O₂, LEL, CO, H₂S — all within safe limits'},
      {'title': 'Is continuous monitoring in place during work?', 'desc': 'Personal 4-gas monitor with audible alarm'},
      {'title': 'Are ventilation measures adequate?', 'desc': 'Mechanical ventilation running; duct positioned correctly'},
      {'title': 'Has the gas detector been bump-tested today?', 'desc': 'Daily bump test with record logged'},
    ],
    'permit system': [
      {'title': 'Is a valid confined-space permit in place?', 'desc': 'Signed by authorised person; time and scope correct'},
      {'title': 'Are all permit conditions met before entry?', 'desc': 'Isolation, atmosphere, rescue, communications checked'},
      {'title': 'Is the permit prominently displayed at the entry point?', 'desc': 'Visible to all entrants and the standby person'},
    ],
    'rescue': [
      {'title': 'Is rescue equipment available at the entry point?', 'desc': 'Retrieval winch/tripod, self-contained breathing apparatus'},
      {'title': 'Is a trained standby person positioned at the entry?', 'desc': 'Competent in rescue procedures and first aid'},
      {'title': 'Has a rescue drill been practiced this quarter?', 'desc': 'Realistic scenario with timing recorded'},
    ],
    'communication': [
      {'title': 'Is a communication system established with the entrant?', 'desc': 'Visual, verbal, or radio contact maintained'},
      {'title': 'Are emergency signals agreed and understood?', 'desc': 'Continuous whistle, repeated tug on lifeline, radio code'},
    ],

    // ────── Racking ──────
    'racking': [
      {'title': 'Are uprights free from visible damage?', 'desc': 'SEMA colour code: Green=OK, Amber=monitor, Red=unload'},
      {'title': 'Are beam locks/safety clips fitted?', 'desc': 'Every beam should have locking pins in place'},
      {'title': 'Are load notices displayed on each bay?', 'desc': 'Maximum bay load, per-level load, and UDL'},
      {'title': 'Is racking anchored to the floor?', 'desc': 'Base plates bolted with correct fixings'},
      {'title': 'Are column guards and end-of-aisle protectors in place?', 'desc': 'Yellow bollards or steel guards at vulnerable positions'},
    ],

    // ────── Forklift ──────
    'fork': [
      {'title': 'Are forks straight with no cracks or excessive wear?', 'desc': 'Heel thickness within 10% of original; no bending'},
      {'title': 'Do all lights and horn function correctly?', 'desc': 'Headlights, reverse lights, beacon, and horn test'},
      {'title': 'Is the seatbelt in good condition and used?', 'desc': 'Retraction, latch, and webbing checked'},
      {'title': 'Are hydraulics leak-free?', 'desc': 'Check hoses, rams, and floor beneath for oil spots'},
    ],
    'mast': [
      {'title': 'Does the mast extend and retract smoothly?', 'desc': 'No jerking; chains properly tensioned'},
      {'title': 'Are mast roller guides in good condition?', 'desc': 'No excessive play or missing rollers'},
    ],

    // ────── First Aid ──────
    'kit contents': [
      {'title': 'Is the first aid kit fully stocked?', 'desc': 'Contents list cross-referenced; expired items replaced'},
      {'title': 'Are additional supplies available for site size?', 'desc': 'HSE guidance on number of kits per worker count'},
      {'title': 'Is the kit easily accessible and clearly marked?', 'desc': 'Green cross sign; no locked cabinets without key nearby'},
    ],
    'trained personnel': [
      {'title': 'Are there enough trained first aiders on shift?', 'desc': 'At least 1 per 50 workers; check rota coverage'},
      {'title': 'Are first aider certificates in date?', 'desc': 'FAW = 3 years, EFAW = 3 years; requalify before expiry'},
      {'title': 'Can first aiders be easily identified?', 'desc': 'Name list posted; identifiable by badge or vest'},
    ],
    'aed': [
      {'title': 'Is the AED (defibrillator) accessible and powered on?', 'desc': 'Green status indicator; no fault alerts'},
      {'title': 'Are AED pads within their expiry date?', 'desc': 'Check sealed packet date; replace if expired'},
      {'title': 'Is the AED location signed and within 3-minute reach?', 'desc': 'Heart symbol signage; consider multiple units for large sites'},
    ],

    // ────── Workplace / Office ──────
    'workstation': [
      {'title': 'Is the monitor at appropriate height and distance?', 'desc': 'Top of screen at/just below eye level; arms length away'},
      {'title': 'Is the chair adjustable and correctly set up?', 'desc': 'Feet flat, thighs horizontal, back supported'},
      {'title': 'Is lighting adequate without screen glare?', 'desc': 'No reflections on screen; task lamp if needed'},
      {'title': 'Is the keyboard and mouse positioned correctly?', 'desc': 'Forearms horizontal; wrists neutral'},
    ],
    'fire route': [
      {'title': 'Are all fire exits clearly signed and illuminated?', 'desc': 'Running-man signs; battery-backed emergency lighting'},
      {'title': 'Are fire exit routes free from obstruction?', 'desc': 'No boxes, furniture, or propped-open fire doors'},
      {'title': 'Do fire exit doors open easily in the direction of travel?', 'desc': 'Push-bar or panic latch operational'},
    ],
    'first aid': [
      {'title': 'Is a first aid kit available and stocked?', 'desc': 'Check contents list; replace used/expired items'},
      {'title': 'Are appointed first aiders trained and identified?', 'desc': 'Names posted; certificates within validity'},
      {'title': 'Is an accident book available and used?', 'desc': 'GDPR-compliant format; pen attached'},
    ],

    // ────── Noise & Vibration ──────
    'noise': [
      {'title': 'Have noise exposure levels been measured?', 'desc': 'Dosimetry or sound level meter; compare to EAVs and ELVs'},
      {'title': 'Are hearing protection zones clearly marked?', 'desc': 'Blue mandatory signs at zone entry points'},
      {'title': 'Is hearing protection appropriate for the exposure level?', 'desc': 'SNR rating adequately reduces exposure below 80 dB(A)'},
      {'title': 'Are workers in hearing health surveillance?', 'desc': 'Audiometry baseline + periodic checks for exposed workers'},
    ],
    'vibration': [
      {'title': 'Have hand-arm vibration exposures been assessed?', 'desc': 'Tool vibration magnitude × daily exposure duration'},
      {'title': 'Are low-vibration tools provided where available?', 'desc': 'Anti-vibration mounts, newer models with reduced HAV'},
      {'title': 'Is there a trigger time limit for high-vibration tools?', 'desc': 'Keep total daily exposure below 2.5 m/s² A(8) EAV'},
    ],

    // ────── Chemical / COSHH ──────
    'chemical storage': [
      {'title': 'Are chemicals stored in a designated locked area?', 'desc': 'Bunded, ventilated, and away from ignition sources'},
      {'title': 'Are incompatible chemicals segregated?', 'desc': 'Acids away from bases; oxidisers away from flammables'},
      {'title': 'Are all containers properly labelled?', 'desc': 'GHS labels with hazard pictograms, signal word, and H-statements'},
      {'title': 'Are spill kits available nearby?', 'desc': 'Appropriate absorbent for chemical type; disposal bags'},
    ],
    'msds': [
      {'title': 'Are Safety Data Sheets available for all chemicals?', 'desc': 'Current 16-section SDS within reach of users'},
      {'title': 'Have workers read the SDS for chemicals they use?', 'desc': 'Signed acknowledgement or toolbox talk record'},
    ],
    'exposure control': [
      {'title': 'Are exposure controls in place as per COSHH assessment?', 'desc': 'LEV, enclosure, substitution, or reduced time measures'},
      {'title': 'Is local exhaust ventilation (LEV) tested annually?', 'desc': 'TExT or equivalent; certificate displayed'},
      {'title': 'Is air monitoring carried out where required?', 'desc': 'Personal sampling for dusts, vapours, or fumes'},
    ],

    // ────── Loading Bay / Dock ──────
    'dock leveller': [
      {'title': 'Are dock levellers functioning and maintained?', 'desc': 'Smooth operation; serviced per manufacturer schedule'},
      {'title': 'Are dock edges clearly marked?', 'desc': 'Yellow/black chevrons and height markers'},
    ],
    'wheel chock': [
      {'title': 'Are wheel chocks used on all stationary vehicles?', 'desc': 'Chocks placed before dock leveller deployed'},
      {'title': 'Are sufficient chocks available at each bay?', 'desc': 'Minimum one pair per active bay'},
    ],

    // ────── Vehicle / Fleet ──────
    'tyre': [
      {'title': 'Are tyre treads above legal minimum depth?', 'desc': '1.6mm minimum; check all four tyres and spare'},
      {'title': 'Are tyre pressures correct?', 'desc': 'Match manufacturer specification on door plate'},
      {'title': 'Are there any visible tyre defects (cuts, bulges)?', 'desc': 'Inspect sidewalls and tread surface'},
    ],
    'brake': [
      {'title': 'Do brakes operate effectively?', 'desc': 'Test at low speed; no pulling, vibration, or noise'},
      {'title': 'Is brake fluid at the correct level?', 'desc': 'Between MIN and MAX on reservoir'},
      {'title': 'Is the handbrake holding on an incline?', 'desc': 'Should hold vehicle on a reasonable slope'},
    ],
    'light': [
      {'title': 'Do all headlights, indicators, and brake lights work?', 'desc': 'Walk-around check; ask someone to press brake'},
      {'title': 'Are reversing lights and warning beeper operational?', 'desc': 'Select reverse gear and check'},
    ],
    'driver document': [
      {'title': 'Does the driver hold a valid licence for the vehicle class?', 'desc': 'Check licence expiry and category entitlements'},
      {'title': 'Is insurance documentation current?', 'desc': 'Green card or certificate; covers business use'},
    ],

    // ────── Water / Legionella ──────
    'water system': [
      {'title': 'Is the water system schematic up to date?', 'desc': 'Shows all tanks, calorifiers, TMVs, and dead legs'},
      {'title': 'Are monthly temperature checks being done?', 'desc': 'Cold < 20°C, hot > 50°C at outlets'},
    ],
    'dead leg': [
      {'title': 'Have dead legs been identified and addressed?', 'desc': 'Cap off or flush weekly; mark on schematic'},
    ],
    'treatment log': [
      {'title': 'Are water treatment records current?', 'desc': 'Dosing levels, biocide application, dip slide results'},
      {'title': 'Is the responsible person identified?', 'desc': 'Named duty holder with competency records'},
    ],

    // ────── Asbestos ──────
    'register': [
      {'title': 'Is an asbestos management survey documented?', 'desc': 'Type 2 survey for non-domestic premises'},
      {'title': 'Is the asbestos register accessible to contractors?', 'desc': 'Available at reception or site office; briefed before work'},
    ],
    'condition assessment': [
      {'title': 'Has the condition of ACMs been reassessed in the last 12 months?', 'desc': 'Algorithm score updated; no deterioration?'},
      {'title': 'Are damaged or deteriorating ACMs labelled or encapsulated?', 'desc': 'Warning stickers and management action recorded'},
    ],
    'management plan': [
      {'title': 'Is an asbestos management plan in place?', 'desc': 'Reviewed annually; sets out monitoring, access control, and removal priorities'},
    ],

    // ══════════════════════════════════════════════════════════════
    // UK HSE REGULATORY — fully compliant inspection questions
    // ══════════════════════════════════════════════════════════════

    // ────── UK1: CDM 2015 Welfare Facilities (Schedule 2) ──────
    'sanitary conveniences': [
      {'title': 'Are adequate sanitary conveniences provided (min 1 per 7 workers)?', 'desc': 'CDM 2015 Schedule 2 para 2; ratio includes urinals counted as 2/3'},
      {'title': 'Are conveniences sufficiently ventilated and lit?', 'desc': 'Natural or mechanical ventilation; minimum 100 lux at floor level'},
      {'title': 'Are facilities maintained in a clean and orderly condition?', 'desc': 'Cleaning schedule posted; supplies replenished daily'},
      {'title': 'Are separate conveniences provided for men and women (or lockable rooms)?', 'desc': 'Separate facilities or self-contained lockable cubicles with full-height partitions'},
      {'title': 'Is there an adequate supply of toilet paper and hand-drying facilities?', 'desc': 'Paper dispensers stocked; bins provided and emptied regularly'},
      {'title': 'Are facilities connected to suitable drainage or chemical treatment?', 'desc': 'Mains drainage preferred; chemical toilets serviced at agreed frequency'},
    ],
    'washing facilities': [
      {'title': 'Are wash basins with clean hot and cold (or warm) running water provided?', 'desc': 'CDM 2015 Schedule 2 para 3; minimum one basin per 10 workers'},
      {'title': 'Are basins large enough for effective washing of face, hands and forearms?', 'desc': 'Industrial-type basins; not domestic hand-rinse style'},
      {'title': 'Is soap or other suitable cleansing agent provided?', 'desc': 'Liquid soap dispensers preferred; abrasive paste where heavy soiling occurs'},
      {'title': 'Are towels or other suitable means of drying provided?', 'desc': 'Paper towels, roller towels, or warm-air dryers; communal towels prohibited'},
      {'title': 'Are showers provided where required by the nature of the work?', 'desc': 'Required for work with hazardous substances, heavy physical labour, or extreme conditions'},
    ],
    'drinking water provision': [
      {'title': 'Is an adequate supply of wholesome drinking water provided?', 'desc': 'CDM 2015 Schedule 2 para 4; mains supply or bottled water with dispenser'},
      {'title': 'Is drinking water readily accessible at suitable places?', 'desc': 'Within reasonable distance of all work areas; not inside contaminated zones'},
      {'title': 'Are drinking water outlets conspicuously marked?', 'desc': 'Signage reading "Drinking Water" where non-potable supplies also exist'},
      {'title': 'Are cups or drinking vessels provided unless water is via upward jet?', 'desc': 'Disposable cups next to dispenser; no shared vessels'},
      {'title': 'Is water supply protected against contamination?', 'desc': 'No back-siphonage risk; supply isolated from industrial water circuits'},
    ],
    'rest & welfare': [
      {'title': 'Are suitable and sufficient rest facilities provided at readily accessible places?', 'desc': 'CDM 2015 Schedule 2 para 5; weatherproof, heated, with seating'},
      {'title': 'Do rest areas include means of heating food or access to a canteen?', 'desc': 'Microwave or kettle provided; canteen within reasonable walking distance'},
      {'title': 'Are rest areas adequately heated, ventilated and lit?', 'desc': 'Thermostat ≥ 15°C; ventilation to prevent condensation; ≥ 200 lux'},
      {'title': 'Are rest areas maintained in a clean and orderly condition?', 'desc': 'Cleaning rota posted; tables wiped down between shifts'},
      {'title': 'Are seats with backs provided in sufficient numbers?', 'desc': 'Minimum one seat per worker expected to use rest room at peak time'},
      {'title': 'Is separate rest provision available for pregnant women and nursing mothers?', 'desc': 'Private area with lockable door, comfortable seating, and a flat surface'},
    ],
    'changing & drying': [
      {'title': 'Are adequate changing facilities provided where workers wear special clothing?', 'desc': 'CDM 2015 Schedule 2 para 6; separate from work areas, with privacy'},
      {'title': 'Are drying facilities provided for wet work clothing?', 'desc': 'Heated drying room or cabinet; clothing should be dry by start of next shift'},
      {'title': 'Are changing facilities adequately separated for men and women?', 'desc': 'Separate rooms or time-segregated use with locks on doors'},
      {'title': 'Can personal clothing be stored securely when not worn during work?', 'desc': 'Lockers or lockable pegs; separated from contaminated work clothing'},
      {'title': 'Is there provision for drying personal clothing that becomes wet?', 'desc': 'Drying area accessible; not mixing personal and contaminated items'},
    ],

    // ────── UK2: LOLER 1998 Thorough Examination ──────
    'equipment identity': [
      {'title': 'Is the equipment clearly identified with a unique serial or reference number?', 'desc': 'LOLER Reg 9; indelible marking or permanently attached plate'},
      {'title': 'Is the Safe Working Load (SWL) clearly and durably marked?', 'desc': 'Visible from the operator position; legible and not obscured by paint or dirt'},
      {'title': 'Is the CE or UKCA marking present where required?', 'desc': 'Required for equipment first placed on the market under the Supply of Machinery Regulations'},
      {'title': 'Is the last thorough examination report available and in date?', 'desc': 'LOLER Reg 10; report valid for 6 months (lifting persons) or 12 months (other)'},
      {'title': 'Is a written scheme of examination in place for this equipment?', 'desc': 'LOLER Reg 9(2); drawn up by a competent person; defines examination scope & intervals'},
      {'title': 'Is the equipment examination history log available on site?', 'desc': 'Kept until equipment disposed of; includes all defect reports and remedial actions'},
    ],
    'structural integrity': [
      {'title': 'Are all structural members free from visible cracks, distortion or corrosion?', 'desc': 'Visual inspection followed by NDT where damage is suspected'},
      {'title': 'Are welds free from defects (cracks, porosity, undercut)?', 'desc': 'MPI or DPI on critical welds per competent person written scheme'},
      {'title': 'Is there any evidence of overloading or permanent deformation?', 'desc': 'Compare with original geometry drawings; measure boom/jib deflection'},
      {'title': 'Are pivot pins, bushings and bearings in serviceable condition?', 'desc': 'Acceptable wear limits per manufacturer; check for play or seizure'},
      {'title': 'Are all bolted connections tight with no missing or damaged fasteners?', 'desc': 'Torque-check critical joints; replace corroded or stretched bolts'},
      {'title': 'Is protective paint or coating intact and providing adequate corrosion protection?', 'desc': 'Touch up bare metal; schedule full repaint where coating loss exceeds 15%'},
    ],
    'overload & limit': [
      {'title': 'Is the overload protection device fitted, functional and tested?', 'desc': 'Must cut motion before rated capacity is exceeded; test at 110% SWL'},
      {'title': 'Are all limit switches operational (hoist, slew, travel limits)?', 'desc': 'Function-test each limit before first lift of the shift'},
      {'title': 'Is the emergency stop function operational and clearly marked?', 'desc': 'Red mushroom-head button, yellow surround; test by activation'},
      {'title': 'Is the load moment indicator (LMI) calibrated and reading accurately?', 'desc': 'Annual calibration certificate; cross-check with known test weights'},
      {'title': 'Are anti-two-block devices fitted and functional where applicable?', 'desc': 'Prevents hook block striking the boom tip sheave; audio and visual alarm'},
      {'title': 'Are wind speed indicators fitted and alarming at the set threshold?', 'desc': 'Alarm at manufacturer specified limit (typically 38 mph for tower cranes)'},
    ],
    'wire rope': [
      {'title': 'Are wire ropes free from broken wires exceeding discard criteria?', 'desc': 'BS ISO 4309; count broken wires per reference length; discard if exceeding table values'},
      {'title': 'Are wire ropes properly lubricated and free from kinking or bird-caging?', 'desc': 'Re-lubricate per manufacturer schedule; any kinking = immediate discard'},
      {'title': 'Are chain slings free from stretching beyond 5% of original pitch?', 'desc': 'Measure pitch; compare against original certificate; discard if over 5%'},
      {'title': 'Are hooks fitted with functional safety catches or latches?', 'desc': 'Gate must close automatically; spring intact; no distortion or gap'},
      {'title': 'Are all slings within examination date and free from visible damage?', 'desc': 'Colour-code system recommended; check stitching on webbing slings'},
      {'title': 'Are shackles, eyebolts and other accessories of correct WLL and condition?', 'desc': 'Stamped WLL legible; pin threads clean; no distortion or excessive wear'},
    ],
    'load testing': [
      {'title': 'Do all motions (hoist, lower, slew, luff, travel) operate smoothly?', 'desc': 'Test under no-load and rated load; listen for unusual noise; check for jerking'},
      {'title': 'Are brakes holding effectively under rated load?', 'desc': 'Hoist brake must hold 125% SWL; slew brake must prevent wind weathervaning'},
      {'title': 'Are controls clearly labelled and functioning in the correct direction?', 'desc': 'ISO direction markings; controls return to neutral when released'},
      {'title': 'Is the operator view adequate or are suitable aids provided?', 'desc': 'Mirrors, CCTV, or signaller where direct view is obstructed'},
      {'title': 'Is the rated capacity chart displayed and legible from the operator position?', 'desc': 'Laminated chart; shows capacity at all radii and jib configurations'},
      {'title': 'Is the equipment logbook up to date with all defects recorded?', 'desc': 'Daily pre-use check entries; defect close-out signatures; no outstanding reds'},
    ],

    // ────── UK3: LEV Thorough Examination (COSHH Reg 9) ──────
    'capture point': [
      {'title': 'Is the hood positioned correctly relative to the emission source?', 'desc': 'Capture distance within design envelope; no draughts competing with extraction'},
      {'title': 'Is the face velocity adequate when measured with an anemometer?', 'desc': 'Minimum 0.5 m/s for low-toxicity dusts; ≥ 1.0 m/s for high-toxicity agents'},
      {'title': 'Are hood flanges and enclosure panels intact and undamaged?', 'desc': 'No holes, cracks, or modifications that bypass the designed airflow path'},
      {'title': 'Is the capture zone geometry consistent with the design specification?', 'desc': 'Cross-reference with HSG258 commissioning data; no obstructions within zone'},
      {'title': 'Are there visual indicators confirming airflow (streamers, tell-tales)?', 'desc': 'Ribbons or manometer readings visible to operators during use'},
    ],
    'ductwork': [
      {'title': 'Are all duct joints secure with no visible gaps or air leaks?', 'desc': 'Smoke test at joints; seal with mastic or clamps where leakage found'},
      {'title': 'Is ductwork free from dents, crushing or excessive corrosion?', 'desc': 'Any restriction > 10% of cross-section = corrective action required'},
      {'title': 'Are access points provided and functional for internal cleaning?', 'desc': 'Access panels at every change of direction and at max 3 m intervals'},
      {'title': 'Is the duct transport velocity sufficient to prevent settling?', 'desc': 'Minimum 15–20 m/s for heavy dust; 10 m/s for fumes; verify with pitot traverse'},
      {'title': 'Are flexible connections in good condition without kinks or collapse?', 'desc': 'Flexible sections kept as short as possible; replace if inner lining is torn'},
    ],
    'filter & collector': [
      {'title': 'Is the filter or collector unit operating within design parameters?', 'desc': 'Differential pressure on gauge within green zone per manufacturer specs'},
      {'title': 'Is the differential pressure within acceptable limits?', 'desc': 'Record reading; compare against commissioning baseline; > 2× baseline = investigate'},
      {'title': 'Are filter elements in serviceable condition (no tears or blockages)?', 'desc': 'Inspect bags/cartridges during planned maintenance; replace per schedule'},
      {'title': 'Is the waste collection and disposal system functioning correctly?', 'desc': 'Hopper emptied regularly; disposal route compliant with waste regulations'},
      {'title': 'Is the condensate drain (if fitted) clear and operational?', 'desc': 'Check drain trap not blocked; condensate routed to correct discharge point'},
    ],
    'fan & motor': [
      {'title': 'Is the fan rotating in the correct direction?', 'desc': 'Verify against directional arrow on casing; reverse rotation = near-zero extraction'},
      {'title': 'Are fan bearings running smoothly without excessive noise or vibration?', 'desc': 'Stethoscope or vibration meter; compare with baseline commissioning levels'},
      {'title': 'Is the drive belt (if fitted) correctly tensioned and in good condition?', 'desc': 'Maximum 25 mm deflection under thumb pressure; no cracking or glazing'},
      {'title': 'Is the motor running without overheating?', 'desc': 'Infrared thermometer check; surface temp should not exceed motor class rating'},
      {'title': 'Is the electrical supply and isolation correct and labelled?', 'desc': 'Isolation switch adjacent to motor; labelled with equipment identity'},
    ],
    'airflow': [
      {'title': 'Does the system achieve the design airflow at the commissioning standard?', 'desc': 'Pitot traverse at main duct; result within ±10% of HSG258 commissioning record'},
      {'title': 'Are static pressure readings at control points within specification?', 'desc': 'Read installed manometers; compare against commissioning data sheet'},
      {'title': 'Is the system achieving adequate control of the airborne contaminant?', 'desc': 'Occupational hygiene assessment confirms exposure below WEL at operator position'},
      {'title': 'Are all indicator gauges and manometers reading correctly?', 'desc': 'Zero check when system off; full-range check against reference gauge annually'},
      {'title': 'Has the engineer recorded all measurements in the LEV log book?', 'desc': 'COSHH Reg 9 requires records kept for at least 5 years; log accessible on site'},
    ],

    // ────── UK4: Legionella L8 Compliance Audit (HSG274 / ACoP L8) ──────
    'cold water tank': [
      {'title': 'Are cold water storage tanks fitted with tight-fitting, sealed lids?', 'desc': 'ACoP L8 para 2.82; lids must be insect-proof and resist wind displacement'},
      {'title': 'Is cold water stored and distributed below 20°C?', 'desc': 'Measure at tank outlet and furthest sentinel tap; > 20°C triggers investigation'},
      {'title': 'Are tanks insulated and protected from heat sources?', 'desc': 'Pipework lagged where it passes through warm spaces; no solar gain on tank'},
      {'title': 'Is there evidence of stagnation in any part of the cold water system?', 'desc': 'Check for unusually warm water at under-used outlets; flush programme in place'},
      {'title': 'Are overflow and warning pipes screened to prevent ingress?', 'desc': 'Fine mesh screen on open ends; prevents birds, insects, and debris entering tank'},
      {'title': 'Is the tank material suitable and the interior surfaces in good condition?', 'desc': 'GRP or lined steel; no corrosion, biofilm, or sediment accumulation on base'},
    ],
    'calorifier': [
      {'title': 'Is hot water stored at 60°C or above in the calorifier?', 'desc': 'ACoP L8 para 2.84; measure with thermocouple at calorifier stat pocket'},
      {'title': 'Is hot water distributed at 50°C or above within one minute at outlets?', 'desc': 'Run hot tap for 60 seconds; measure temperature with digital probe'},
      {'title': 'Are calorifiers drained, inspected and de-scaled on the prescribed schedule?', 'desc': 'Annual bottom drain and internal inspection; record sludge volume'},
      {'title': 'Is the bottom drain temperature of the calorifier at or above 60°C?', 'desc': 'Critical check — base is the coolest zone; low temp = Legionella growth risk'},
      {'title': 'Are thermostatic mixing valves (TMVs) maintained and operating correctly?', 'desc': 'TMV outlet 38–43°C; failsafe tested; cleaned and descaled per TMV scheme'},
    ],
    'stagnation': [
      {'title': 'Have all dead legs been identified, mapped and addressed?', 'desc': 'Dead legs > 2× pipe diameter should be removed or flushed weekly; marked on schematic'},
      {'title': 'Are little-used outlets flushed weekly and is this recorded?', 'desc': 'Run each outlet for 2 minutes minimum; log date, outlet ID, and person responsible'},
      {'title': 'Are showers and spray-generating taps descaled and disinfected quarterly?', 'desc': 'Remove heads; soak in descaler; disinfect; record date and head serial'},
      {'title': 'Are rubber and natural materials minimised throughout the system?', 'desc': 'Flexible hoses, washers, gaskets; replace with WRAS-approved synthetic where possible'},
      {'title': 'Are point-of-use filters installed at high-risk outlets (e.g. augmented care)?', 'desc': 'Filters changed per manufacturer schedule (typically monthly); log replacements'},
    ],
    'legionella sampling': [
      {'title': 'Is a written scheme of control in place and reviewed at least every 2 years?', 'desc': 'ACoP L8 para 2.36; documented risk assessment reviewed by competent person'},
      {'title': 'Are monthly temperature monitoring checks conducted and recorded?', 'desc': 'Sentinel taps (nearest and furthest) + representative selection; digital probe'},
      {'title': 'Are routine Legionella water samples taken and results within acceptable limits?', 'desc': 'Quarterly sampling per HSG274; action level ≥ 100 cfu/L; alert > 1000 cfu/L'},
      {'title': 'Are laboratory sample results reviewed and acted upon promptly?', 'desc': 'Results within 10 working days; positive results trigger investigation and remedial action'},
      {'title': 'Are all maintenance actions documented in the water log book?', 'desc': 'Includes TMV servicing, tank cleans, temperature anomalies, flushing records'},
    ],
    'l8 duties': [
      {'title': 'Is there a named Responsible Person for Legionella management?', 'desc': 'ACoP L8 para 2.13; dutyholder must appoint someone with authority and competence'},
      {'title': 'Has the Responsible Person received Legionella awareness training?', 'desc': 'City & Guilds or equivalent; refreshed every 3 years minimum'},
      {'title': 'Are maintenance staff trained in the hazards and control measures?', 'desc': 'Toolbox talk or formal course covering sampling, flushing, temperature monitoring'},
      {'title': 'Is there a documented outbreak response (contingency) plan?', 'desc': 'Details notification to PHE, sampling escalation, communication plan, and system shutdown'},
      {'title': 'Are contact details for the local Health Protection Team available?', 'desc': 'PHE regional office; displayed in the water management file and building reception'},
    ],

    // ────── UK5: Confined Space Entry Audit (CS Regulations 1997) ──────
    'entry risk assessment': [
      {'title': 'Is a specific risk assessment in place for this confined space entry?', 'desc': 'CS Regs Reg 3; must identify all foreseeable risks before work begins'},
      {'title': 'Have all foreseeable hazards been identified (toxic, flammable, O₂ depletion, engulfment)?', 'desc': 'Consider residues, connected plant, activities nearby, weather conditions'},
      {'title': 'Has the hierarchy of control been applied — is entry truly necessary?', 'desc': 'CS Regs Reg 3; work from outside using remote tools where reasonably practicable'},
      {'title': 'Are the risk assessment findings communicated to all personnel entering?', 'desc': 'Briefing signed by all entrants; covers hazards, controls, and emergency actions'},
      {'title': 'Is the risk assessment signed and dated by a competent person?', 'desc': 'Competent = training + experience + current knowledge of the space and substances'},
    ],
    'permit-to-work': [
      {'title': 'Is a written permit-to-work (PTW) in operation for this entry?', 'desc': 'CS Regs Reg 4; safe system of work documented and authorised before entry'},
      {'title': 'Does the permit clearly specify the work to be done and its time limits?', 'desc': 'Scope, duration, shift boundaries; permit cancelled and reissued for each shift'},
      {'title': 'Are lockout/tagout (LOTO) procedures applied to all energy sources?', 'desc': 'Mechanical, electrical, hydraulic, pneumatic, process isolation verified'},
      {'title': 'Is the space purged and/or ventilated before and during entry?', 'desc': 'Forced ventilation with fresh air; minimum 5 complete air changes before entry'},
      {'title': 'Are all sources of ingress of hazardous substances isolated?', 'desc': 'Blank flanges, spade isolations, locked valves; signed off by authorised person'},
      {'title': 'Is the permit displayed at the entry point and visible to all workers?', 'desc': 'Weatherproof sleeve; includes emergency contact numbers and gas readings'},
    ],
    'gas testing': [
      {'title': 'Has pre-entry atmospheric testing been conducted and recorded?', 'desc': 'Test at multiple levels (top, middle, bottom); record exact readings on permit'},
      {'title': 'Is the oxygen level between 19.5% and 23.5%?', 'desc': 'Below 19.5% = O₂ deficient; above 23.5% = enriched (fire/explosion risk)'},
      {'title': 'Are flammable gas levels below 10% of the Lower Explosive Limit (LEL)?', 'desc': 'If between 10–25% LEL additional controls required; > 25% LEL = do not enter'},
      {'title': 'Are toxic gas levels below the relevant Workplace Exposure Limit (WEL)?', 'desc': 'Check EH40 for substance-specific WEL; CO, H₂S are common confined space hazards'},
      {'title': 'Is continuous atmospheric monitoring in place during the entire entry period?', 'desc': 'Fixed or personal multi-gas monitor; alarm thresholds set; calibration in date'},
    ],
    'entrant competence': [
      {'title': 'Are all entrants trained and assessed as competent for confined space work?', 'desc': 'Formal training qualification; assessed against a competency standard'},
      {'title': 'Is a trained top-person stationed at the entry point at all times?', 'desc': 'Must maintain communication with entrants and be able to raise the alarm'},
      {'title': 'Is suitable RPE (respiratory protective equipment) available and face-fit tested?', 'desc': 'BA sets or powered respirators; individual face-fit test certificate valid'},
      {'title': 'Are all entrants wearing appropriate PPE for the identified hazards?', 'desc': 'Hard hat, harness, gloves, eye protection as per risk assessment'},
      {'title': 'Has a body count (tally) system been established to track who is inside?', 'desc': 'Name board at entry point; tallies in/out; no entry without top-person logging'},
    ],
    'retrieval & emergency': [
      {'title': 'Is a specific rescue plan written for this confined space?', 'desc': 'CS Regs Reg 5; cannot rely on emergency services alone; plan must be tested'},
      {'title': 'Has the rescue plan been communicated and rehearsed?', 'desc': 'Drill before first entry; all rescuers briefed; timing recorded'},
      {'title': 'Is rescue equipment (tripod, inertia reel, winch, harness) set up and tested?', 'desc': 'Positioned at entry point ready for immediate deployment; in-date inspection'},
      {'title': 'Can rescue be initiated without rescuers having to enter the space?', 'desc': 'Non-entry rescue is the preferred option; use fall-arrest/retrieval system from outside'},
      {'title': 'Are means of communication between entrants and top-person tested and working?', 'desc': 'Radios, hard-wired intercom, or visual signals; tested before entry begins'},
    ],

    // ────── UK6: Asbestos Management Review (CAR 2012) ──────
    'acm survey': [
      {'title': 'Is a comprehensive management survey available for the premises?', 'desc': 'CAR 2012 Reg 4; Type 2 management survey for all non-domestic premises'},
      {'title': 'Has the survey been conducted by a UKAS-accredited laboratory/surveyor?', 'desc': 'Surveyor holds P402/P405 qualification; lab UKAS accredited for bulk analysis'},
      {'title': 'Does the survey identify location, type and condition of all ACMs?', 'desc': 'Floor plans marked; each ACM assigned a unique reference number'},
      {'title': 'Is the register accessible to all who need it (building users, contractors)?', 'desc': 'Copy at reception, site office, or available digitally; briefed before work starts'},
      {'title': 'Has the register been reviewed and updated within the last 12 months?', 'desc': 'Annual review documented; includes any new areas surveyed or ACMs removed'},
    ],
    'acm scoring': [
      {'title': 'Are all identified ACMs assessed using the material assessment algorithm?', 'desc': 'HSG264 scoring: product type, damage, surface treatment, asbestos type → score 2–12'},
      {'title': 'Is the asbestos type identified (chrysotile, amosite, crocidolite)?', 'desc': 'Bulk sample analysis; crocidolite = highest risk; affects management priority'},
      {'title': 'Have surface treatments been recorded (painted, sealed, encapsulated)?', 'desc': 'Encapsulation may reduce fibre release; condition of treatment noted'},
      {'title': 'Are damaged or deteriorating ACMs photographed and documented?', 'desc': 'Before and after photos; damage extent recorded as a percentage of surface area'},
      {'title': 'Has a priority assessment been carried out based on occupant activity?', 'desc': 'HSG264 priority algorithm: location, accessibility, extent, maintenance activity → score'},
    ],
    'asbestos management': [
      {'title': 'Is there a written asbestos management plan in place?', 'desc': 'CAR 2012 Reg 4(7); reviewed annually; assigns dutyholder responsibilities'},
      {'title': 'Does the plan assign a named dutyholder with clear responsibilities?', 'desc': 'Building owner or tenant per lease; documented acceptance of duty'},
      {'title': 'Are ACMs in good condition left in situ and subject to periodic monitoring?', 'desc': 'Labelled "Asbestos — do not disturb"; re-inspected at defined intervals'},
      {'title': 'Are damaged ACMs repaired, sealed, enclosed or removed by a licensed contractor?', 'desc': 'Licensed removal for licensable ACMs; NNLW notification for non-licensed work'},
      {'title': 'Is there a permit-to-work system for any work that may disturb ACMs?', 'desc': 'PTW checked against register before drilling, cabling, or maintenance work'},
    ],
    're-inspection & clearance': [
      {'title': 'Are periodic re-inspections conducted at defined intervals (typically annually)?', 'desc': 'Walk-through inspection of all ACMs; compare condition against previous records'},
      {'title': 'Is air monitoring conducted after any ACM disturbance or licensed removal?', 'desc': 'Four-stage clearance per HSG248; reassurance air test using PCM method'},
      {'title': 'Is a four-stage clearance certificate obtained after licensed removal work?', 'desc': 'Issued by independent analyst; site not reoccupied until certificate received'},
      {'title': 'Are all monitoring results and removal records retained for at least 40 years?', 'desc': 'CAR 2012 Reg 19; records available to HSE on request; stored securely'},
    ],
    'asbestos awareness': [
      {'title': 'Have all workers who may disturb ACMs received asbestos awareness training?', 'desc': 'CAR 2012 Reg 10; minimum Category A awareness for maintenance, IT, cleaning staff'},
      {'title': 'Is training recorded and refreshed at appropriate intervals (typically annually)?', 'desc': 'Certificate or training record with date, provider, attendee signature'},
      {'title': 'Are contractors provided with register information before starting work?', 'desc': 'Register extract relevant to work area; permit cross-checked before tools break ground'},
      {'title': 'Is there a procedure for reporting suspected asbestos finds?', 'desc': 'Stop work, evacuate area, report to dutyholder; do not touch or sample'},
      {'title': 'Are warning labels affixed to all accessible ACMs?', 'desc': 'HSE standard label: blue/white asbestos warning sign; updated as ACMs are remediated'},
    ],

    // ────── UK7: PUWER 1998 Work Equipment Inspection ──────
    'equipment suitability': [
      {'title': 'Is the equipment suitable for its intended use and working conditions?', 'desc': 'PUWER Reg 4; consider the specific task, location, environmental factors'},
      {'title': 'Has account been taken of specific risks in the workplace?', 'desc': 'Wet, explosive, confined, outdoor, or corrosive environments require rated equipment'},
      {'title': 'Is the equipment CE/UKCA marked where required?', 'desc': 'Required at point of supply; declaration of conformity available from manufacturer'},
      {'title': 'Is the original instruction manual available on site?', 'desc': 'PUWER Reg 24; must be in a language the operators can understand'},
      {'title': 'Has a pre-use risk assessment been completed for this equipment?', 'desc': 'MHSWR Reg 3; covers all foreseeable hazards and control measures'},
    ],
    'guards & interlock': [
      {'title': 'Are all dangerous parts of machinery provided with suitable guards?', 'desc': 'PUWER Reg 11; fixed guards preferred; interlocked guards where access needed'},
      {'title': 'Are guards of suitable construction (sturdy, not easily defeated)?', 'desc': 'BS EN ISO 14120; no sharp edges; material adequate to withstand foreseeable impact'},
      {'title': 'Do interlocked guards stop the machine before access to danger zone is possible?', 'desc': 'Guard opening cuts power; run-down time covered by guard-locking device if needed'},
      {'title': 'Are all guard interlocks and safety switches tested and functional?', 'desc': 'Monthly function test; record date, tester, result; replace faulty switches immediately'},
      {'title': 'Is access to nip points, entanglement points and ejection zones fully prevented?', 'desc': 'Minimum distances per BS EN ISO 13857; assess from all operator positions'},
    ],
    'maintenance log': [
      {'title': 'Is the equipment maintained in an efficient state, in working order and good repair?', 'desc': 'PUWER Reg 5; planned preventive maintenance schedule followed'},
      {'title': 'Is a maintenance log book kept and up to date?', 'desc': 'Records all PPM, breakdowns, parts replaced; signed by engineer'},
      {'title': 'Are defect reporting procedures in place and actively used?', 'desc': 'Defect tags, register, or digital system; management review of open defects'},
      {'title': 'Is maintenance carried out only by competent persons?', 'desc': 'Trained and assessed; holds relevant qualifications (e.g. CompEx, NVQ)'},
      {'title': 'Are maintenance activities themselves risk-assessed (lockout, isolation)?', 'desc': 'PUWER Reg 22; safe system of work for every maintenance intervention'},
    ],
    'emergency stop': [
      {'title': 'Are emergency stop controls provided and clearly identifiable?', 'desc': 'PUWER Reg 16; red mushroom button on yellow background; within arm reach'},
      {'title': 'Do emergency stops operate correctly when tested?', 'desc': 'Monthly test; latching type requiring deliberate reset; audible confirmation'},
      {'title': 'Is there a clearly identifiable means of isolating the equipment from energy?', 'desc': 'PUWER Reg 19; lockable isolation switch; energy stored in system safely dissipated'},
      {'title': 'Are control systems safe (fail-safe principle applied)?', 'desc': 'PUWER Reg 18; failure of control system does not create a dangerous condition'},
      {'title': 'Are start controls designed to prevent accidental operation?', 'desc': 'PUWER Reg 14; recessed, shrouded, or requiring two-hand activation'},
    ],
    'operator training': [
      {'title': 'Have all operators received adequate training for this equipment?', 'desc': 'PUWER Reg 9; specific to machine type; records retained'},
      {'title': 'Are written safe operating procedures (SOPs) available at the point of use?', 'desc': 'Laminated procedure displayed; includes start-up, operation, shutdown, emergency'},
      {'title': 'Are operators aware of the hazards and the required precautions?', 'desc': 'Toolbox talk signed attendance; covers specific risks identified in the risk assessment'},
      {'title': 'Is refresher training provided at appropriate intervals?', 'desc': 'Typically annually or after significant absence, incident, or equipment modification'},
      {'title': 'Are young persons (under 18) given additional risk assessment consideration?', 'desc': 'MHSWR Reg 19; lack of experience, awareness, or maturity; may need restricted access'},
    ],

    // ────── UK8: Scaffold Inspection (NASC TG20 / WAH 2005) ──────
    'base plate': [
      {'title': 'Are base plates bearing on suitable sole boards (min 225 mm wide)?', 'desc': 'TG20 Table 4.3; softwood min 35 mm thick × scaffold bay width; no bricks as packing'},
      {'title': 'Is the ground firm, level and capable of supporting the imposed scaffold load?', 'desc': 'Assess ground bearing capacity; compacted hardcore or concrete preferred'},
      {'title': 'Are base plates centred on sole boards with no overhang?', 'desc': 'Plate must sit fully on sole board; sole board extends both sides of the standard'},
      {'title': 'Are adjustable base jacks extended no more than 300 mm?', 'desc': 'Maximum 300 mm exposed thread; over-extension reduces stability'},
      {'title': 'Is there adequate protection from vehicle impact at ground level?', 'desc': 'Kentledge blocks, barriers, or hi-vis boarding where vehicles pass nearby'},
    ],
    'ledger': [
      {'title': 'Are standards plumb and in line (visually checked)?', 'desc': 'Maximum out-of-plumb 1:200 height; check with spirit level at base and mid-height'},
      {'title': 'Are all spigot joints secure with pins or clips in place?', 'desc': 'Each spigot pin present and locked; joint not free to separate under load'},
      {'title': 'Are ledgers level and secured to every standard with right-angle couplers?', 'desc': 'Every intersection fixed; no loose or missing couplers'},
      {'title': 'Are intermediate transoms provided at maximum 1.2 m centres?', 'desc': 'Support the boards over the span; closer centres for heavier loads'},
      {'title': 'Are all couplers tightened to the correct torque and in good condition?', 'desc': 'Spanner-tight; no cracked castings, stripped threads, or corroded bolts'},
      {'title': 'Is the lift height consistent and not exceeding 2.0 m (unless by design)?', 'desc': 'Standard lift height 2.0 m; any variation must be engineer-designed'},
    ],
    'bracing & tie': [
      {'title': 'Is facade bracing provided at the required intervals?', 'desc': 'TG20 guidance: diagonal braces at alternate bays minimum; continuous for wind loading'},
      {'title': 'Is plan bracing installed at the top lift and at alternate lifts?', 'desc': 'Diagonal across the plan; prevents racking and ensures lateral stability'},
      {'title': 'Are all brace couplers tight and in good condition?', 'desc': 'Swivel couplers for diagonal braces; secure and no signs of slippage'},
      {'title': 'Are ties installed at the specified pattern per TG20 or scaffold design?', 'desc': 'Through-ties or box-ties preferred; reveal ties only with engineer approval'},
      {'title': 'Is each tie tested for adequacy (push-pull test)?', 'desc': 'Apply 6.25 kN test load; no movement at tie point; record result'},
    ],
    'scaffold board': [
      {'title': 'Are scaffold boards in good condition (no splits, excessive knots, or warping)?', 'desc': 'BS 2482 class boards; reject if knot > 1/3 board width; max bow 25 mm'},
      {'title': 'Is the platform fully boarded with no gaps exceeding 25 mm?', 'desc': 'Gaps between boards ≤ 25 mm; no missing boards in the working area'},
      {'title': 'Are boards properly supported and overhang between 50–150 mm?', 'desc': 'Minimum 4 supports across a 3.9 m bay; overhang prevents tipping but not tripping'},
      {'title': 'Are boards secured against displacement by wind or accidental load?', 'desc': 'End clips, wire ties, or proprietary board clamps at each end'},
      {'title': 'Is the maximum permissible platform loading displayed on a load notice?', 'desc': 'TG20 or design load class; notice at each access point; workers briefed on limits'},
      {'title': 'Are trap-door boards fitted and operational at internal access points?', 'desc': 'Close when not in use; prevent fall of persons and materials through opening'},
    ],
    'edge protection': [
      {'title': 'Are guard rails fitted at a minimum height of 950 mm above the platform?', 'desc': 'Work at Height Regs 2005 Schedule 3; measured from the working surface'},
      {'title': 'Are intermediate guard rails or brick guards fitted to prevent falls between guardrail and toeboard?', 'desc': 'No unprotected gap exceeding 470 mm; mesh guards preferred on public-facing sides'},
      {'title': 'Are toe boards at least 150 mm high and properly secured?', 'desc': 'Prevents materials falling from platform; secured at each end'},
      {'title': 'Is internal ladder access provided at intervals not exceeding 9 m?', 'desc': 'Ladder at each access point; route clearly signed; hatches provided'},
      {'title': 'Do access ladders extend at least 1 m above the landing platform?', 'desc': 'Provides handhold when stepping off; ladder tied at top and base'},
    ],

    // ════════════════════════════════════════════════════════════════
    // US OSHA — 29 CFR Compliant Questions
    // ════════════════════════════════════════════════════════════════

    // US1: Scaffolding Inspection (29 CFR 1926.451)
    'foundation & sill': [
      {'title': 'Are scaffold foundations on firm, level surfaces capable of supporting the load?', 'desc': '29 CFR 1926.451(c)(2); no unstable objects used as base support'},
      {'title': 'Are base plates and mudsills installed under all scaffold legs?', 'desc': '1926.451(c)(2)(ii); mudsills sized to distribute load without settling'},
      {'title': 'Are scaffold legs plumb and braced to prevent displacement?', 'desc': '1926.451(c)(1); legs must be set on base plates; braced from bottom'},
      {'title': 'Is the ground graded to prevent water accumulation at the base?', 'desc': 'Standing water undermines sill bearing capacity; drainage required'},
      {'title': 'Are adjustable screw jacks used instead of unstable shimming?', 'desc': '1926.451(c)(2)(i); blocking used for levelling must be solid, rigid'},
    ],
    'planking & platform': [
      {'title': 'Are scaffold platforms fully planked between front uprights and guardrail?', 'desc': '1926.451(b)(1); maximum gap of 1 inch except at scaffold frame connections'},
      {'title': 'Do platform planks extend at least 6 inches beyond the support bearers?', 'desc': '1926.451(b)(5); overhang must not exceed 12 inches unless cleated'},
      {'title': 'Are platform planks free from cracks, knots, or other defects?', 'desc': '1926.451(a)(6); Scaffold Grade lumber or equivalent strength required'},
      {'title': 'Is the maximum intended load clearly posted and not exceeded?', 'desc': '1926.451(a)(1); 4:1 safety factor for suspension scaffolds'},
      {'title': 'Are platform units properly secured to prevent displacement?', 'desc': '1926.451(b)(9); wind, equipment, or worker movement must not shift planks'},
    ],
    'guardrail & midrail': [
      {'title': 'Are guardrails installed on all open sides at 38-45 inches above the platform?', 'desc': '1926.451(g)(4)(i); personal fall arrest or nets are acceptable alternatives'},
      {'title': 'Is an intermediate midrail installed approximately midway between toeboard and top rail?', 'desc': '1926.451(g)(4)(ii); equivalent protection via mesh or intermediate members'},
      {'title': 'Are toeboards at least 3.5 inches high installed on all scaffold edges?', 'desc': '1926.451(h)(1); prevents tools and materials from falling off'},
      {'title': 'Can guardrails withstand a 200-pound force applied in any direction?', 'desc': '1926.451(g)(4)(vii); toprail must not deflect below 39 inches'},
      {'title': 'Is wire mesh or screen infill installed between guardrail and toeboard where required?', 'desc': '1926.451(g)(4)(iv); prevents small objects from falling through open guardrail system'},
    ],
    'access points & climbing': [
      {'title': 'Are safe access points (ladders, stairs, ramps) provided at scaffold?', 'desc': '1926.451(e)(1); climbing cross-braces prohibited unless designed for climbing'},
      {'title': 'Are stairways or ladder-type access installed when scaffold platform is >2 feet above/below?', 'desc': '1926.451(e)(1); direct access also acceptable when close to another surface'},
      {'title': 'Are portable ladders tied off and extending 3 feet above the access level?', 'desc': '1926.1053(b)(1); side rails extend above upper landing surface'},
      {'title': 'Are internal stairways or ladder-type access installed for scaffolds exceeding 4 frames in height?', 'desc': '1926.451(e)(2); stair tower or equivalent climbing provisions required'},
      {'title': 'Are rest platforms provided at vertical intervals not exceeding 35 feet?', 'desc': '1926.451(e)(5); prevents fatigue-related falls during ascent/descent'},
    ],
    'capacity & load compliance': [
      {'title': 'Is the scaffold designed by a qualified person and rated to support 4x maximum load?', 'desc': '1926.451(a)(1); suspension scaffolds require 6:1 design factor'},
      {'title': 'Are employees and their tools within the scaffold load rating?', 'desc': '1926.451(f)(1); load calculations documented; no overloading'},
      {'title': 'Is the scaffold inspected before each shift by a competent person?', 'desc': '1926.451(f)(3); must inspect after any occurrence that could compromise structural integrity'},
      {'title': 'Is a site-specific erection/disassembly plan followed and supervised by a competent person?', 'desc': '1926.451(f)(7); erection sequence must prevent unstable intermediate configurations'},
    ],
    'fall protection & competent person': [
      {'title': 'Are employees on scaffolds >10 feet protected by guardrails or PFAS?', 'desc': '1926.451(g)(1); employees on single/two-point suspension scaffolds must wear PFAS'},
      {'title': 'Is a competent person designated and on site to direct scaffold work?', 'desc': '1926.451(f)(7); competent person must supervise erection, moving, and dismantling'},
      {'title': 'Have all scaffold workers received training per 1926.454?', 'desc': '1926.454(a); training covers hazards, load limits, fall protection, and scaffold use'},
      {'title': 'Are tag lines used to control loads being hoisted onto scaffold?', 'desc': '1926.451(f)(13); prevents swinging loads from striking scaffold or workers'},
    ],

    // US2: Permit-Required Confined Space (29 CFR 1910.146)
    'space classification': [
      {'title': 'Has each workplace been evaluated to identify all permit-required confined spaces?', 'desc': '1910.146(c)(1); limited entry/exit, not designed for continuous occupancy'},
      {'title': 'Are all PRCS posted with danger signs warning of hazardous conditions?', 'desc': '1910.146(c)(2); signs must inform employees of the existing hazard'},
      {'title': 'Is a current inventory of all confined spaces maintained and reviewed?', 'desc': 'Inventory includes location, classification, known hazards, and entry history'},
      {'title': 'Are spaces reclassified when conditions change?', 'desc': '1910.146(c)(7); alternate entry allowed only when all hazards eliminated'},
      {'title': 'Is there a written PRCS entry program available to all employees?', 'desc': '1910.146(c)(4); program defines means for compliance with the standard'},
      {'title': 'Are non-permit confined spaces periodically re-evaluated for new hazards?', 'desc': '1910.146(c)(6); re-evaluation required when changes could increase hazard potential'},
    ],
    'written program & permits': [
      {'title': 'Does the entry permit list the space, purpose, date, and authorized entrants?', 'desc': '1910.146(f)(2); permit valid for duration of task only'},
      {'title': 'Are completed permits posted at or near the entry point?', 'desc': '1910.146(e)(5); allows entrants and attendants to verify conditions'},
      {'title': 'Does the permit specify acceptable atmospheric conditions?', 'desc': '1910.146(f)(4); O2 19.5-23.5%, LEL <10%, toxics below PELs'},
      {'title': 'Are permits cancelled when entry operations are completed or conditions change?', 'desc': '1910.146(e)(7); cancelled permits reviewed within 1 year'},
      {'title': 'Is there a procedure for closing out and recording permit data?', 'desc': '1910.146(e)(6); retained for at least 1 year'},
    ],
    'atmospheric testing procedures': [
      {'title': 'Is the atmosphere tested prior to entry with a calibrated direct-reading instrument?', 'desc': '1910.146(d)(5)(ii); test for O2, combustibles, toxics in that order'},
      {'title': 'Is continuous atmospheric monitoring provided during entry?', 'desc': '1910.146(d)(5)(ii); continuous or periodic as sufficient to ensure safety'},
      {'title': 'Are instruments calibrated per manufacturer recommendations?', 'desc': 'Calibration records maintained; bump-tested before each use'},
      {'title': 'Is ventilation provided to maintain safe atmospheric conditions?', 'desc': '1910.146(d)(4); mechanical ventilation documented on permit'},
      {'title': 'Are entrants trained to recognise symptoms of atmospheric hazards?', 'desc': '1910.146(g)(4); entrants must alert attendant of warning signs'},
    ],
    'attendant & communication': [
      {'title': 'Is a trained attendant stationed outside the space at all times during entry?', 'desc': '1910.146(i)(1); attendant must never enter the space'},
      {'title': 'Does the attendant have communication equipment to contact entrants and rescue?', 'desc': '1910.146(i)(5); voice, radio, visual signals as appropriate'},
      {'title': 'Can the attendant order entrants to evacuate immediately?', 'desc': '1910.146(i)(6); attendant authorised to deny or terminate entry'},
      {'title': 'Does the attendant monitor activities inside and outside the space?', 'desc': '1910.146(i)(3); track entrants; prevent unauthorised persons from entering'},
      {'title': 'When one attendant monitors multiple spaces, are procedures ensuring adequate coverage in place?', 'desc': '1910.146(i)(7); attendant must be able to respond to each space without compromising others'},
    ],
    'rescue & emergency services': [
      {'title': 'Has a rescue team been designated or arranged with local services?', 'desc': '1910.146(d)(9); team must respond within a timeframe suitable for the hazards'},
      {'title': 'Does the rescue team practice permit space rescue at least annually?', 'desc': '1910.146(k)(1)(iii); practice with manikin or actual person'},
      {'title': 'Is non-entry retrieval equipment (tripod and winch) available?', 'desc': '1910.146(d)(9)(iii); retrieval line attached to entrant unless it creates a hazard'},
      {'title': 'Are entrants provided with and trained on self-rescue equipment?', 'desc': '1910.146(k)(1)(i); body harness with retrieval line'},
      {'title': 'Has the local medical facility been informed of confined space hazards and potential rescue needs?', 'desc': '1910.146(d)(9); hospital notification ensures preparedness for specific exposure injuries'},
    ],

    // US3: Lockout/Tagout (29 CFR 1910.147)
    'energy control program': [
      {'title': 'Does the facility have a written energy control program?', 'desc': '1910.147(c)(1); covers procedures, training, and periodic inspections'},
      {'title': 'Does the program address all forms of hazardous energy (electrical, hydraulic, pneumatic, thermal, chemical, gravity)?', 'desc': '1910.147(c)(1); all energy sources must be identified and controlled'},
      {'title': 'Are machine-specific energy control procedures documented for each piece of equipment?', 'desc': '1910.147(c)(4)(i); must detail steps for shutting down, isolating, and verifying'},
      {'title': 'Are procedures reviewed and updated when equipment or processes change?', 'desc': '1910.147(c)(4)(ii); procedures must reflect current conditions'},
      {'title': 'Are affected employees notified before and after LOTO application?', 'desc': '1910.147(c)(9); notification includes type, magnitude of energy and method of control'},
    ],
    'lock & tag device': [
      {'title': 'Are lockout devices standardized by colour, shape, or size within the facility?', 'desc': '1910.147(c)(5)(ii)(A); must be identifiable as lockout devices'},
      {'title': 'Is each authorized employee assigned their own individually keyed lock?', 'desc': '1910.147(c)(5)(i); personal locks; no master key override during LOTO'},
      {'title': 'Are tagout devices weather-resistant and non-reusable?', 'desc': '1910.147(c)(5)(ii)(B); tags warn against hazardous conditions; attached at isolation point'},
      {'title': 'Are tags supplemented with at least one additional measure (lock, block, disconnect)?', 'desc': '1910.147(c)(3)(ii); tagout alone requires equivalent safety measures'},
      {'title': 'Are lockout/tagout devices substantial enough to prevent removal without excessive force?', 'desc': '1910.147(c)(5)(ii)(C); nylon cable ties are not acceptable as locks'},
    ],
    'machine-specific procedures': [
      {'title': 'Does each procedure identify the specific machine or equipment covered?', 'desc': '1910.147(c)(4)(ii)(A); name, location, and type of energy'},
      {'title': 'Are all energy isolation points for the machine identified and listed?', 'desc': '1910.147(c)(4)(ii)(B); disconnects, valves, blocks, interlocks, etc.'},
      {'title': 'Does the procedure include verification of zero-energy state?', 'desc': '1910.147(d)(6); try-start, voltage testing, pressure gauge checks'},
      {'title': 'Is stored or residual energy addressed (bleeding, repositioning, blocking)?', 'desc': '1910.147(d)(7); springs released, capacitors discharged, pressure bled'},
      {'title': 'Does the procedure address group lockout when multiple employees are servicing?', 'desc': '1910.147(f)(3); primary authorized employee coordinates group LOTO'},
    ],
    'periodic inspection records': [
      {'title': 'Is a periodic inspection of the energy control program conducted at least annually?', 'desc': '1910.147(c)(6)(i); must cover each machine-specific procedure'},
      {'title': 'Is the inspection performed by an authorized employee who is NOT using the procedure?', 'desc': '1910.147(c)(6)(i)(A); independent review ensures objectivity'},
      {'title': 'Does the inspection certification include date, equipment, employees, and inspector identity?', 'desc': '1910.147(c)(6)(i)(D); documentation retained (no specific retention period)'},
      {'title': 'Are deficiencies identified in inspections corrected before LOTO procedures are reused?', 'desc': 'Corrective actions documented and tracked to closure'},
      {'title': 'Is the inspection process reviewed with each authorized and affected employee?', 'desc': '1910.147(c)(6)(i)(B/C); reinforces employee responsibilities'},
    ],
    'employee training & authorisation': [
      {'title': 'Are authorized employees trained on recognition of hazardous energy and LOTO steps?', 'desc': '1910.147(c)(7)(i)(A); must know purpose and function of the program'},
      {'title': 'Are affected employees trained on their role and the prohibition against restoring energy?', 'desc': '1910.147(c)(7)(i)(B); should not attempt to start locked-out equipment'},
      {'title': 'Is retraining provided when procedures change, new hazards arise, or inspections reveal gaps?', 'desc': '1910.147(c)(7)(iii); documented as initial training'},
      {'title': 'Are training records maintained (name, date, trainer)?', 'desc': 'Best practice: maintain records per OSHA training documentation guidance'},
      {'title': 'Are contractors informed of the host employer LOTO program and vice versa?', 'desc': '1910.147(f)(2); coordination ensures no one is exposed during service'},
    ],

    // US4: Fall Protection Compliance (29 CFR 1926.501)
    'leading edge & unprotected': [
      {'title': 'Are employees on walking/working surfaces with unprotected sides 6+ feet above lower level protected?', 'desc': '1926.501(b)(1); guardrails, safety nets, or PFAS required'},
      {'title': 'Is fall protection provided at leading edges during construction activities?', 'desc': '1926.501(b)(2); PFAS or guardrails; safety monitoring only if others infeasible'},
      {'title': 'Are employees working near wall openings with drops >6 feet protected?', 'desc': '1926.501(b)(14); guardrails or fall restraint systems required'},
      {'title': 'Are ramps, runways, and walkways with openings properly guarded?', 'desc': '1926.502(c); open sides require guardrails; toeboards if workers below'},
      {'title': 'Is a written fall protection plan in place where conventional methods are infeasible?', 'desc': '1926.502(k); site-specific; maintained at job site; identifies alternative measures'},
      {'title': 'Are employees performing overhand bricklaying 6+ feet above lower level protected from falls?', 'desc': '1926.501(b)(9); guardrails, PFAS, or safety nets required for masonry activities'},
    ],
    'hole covers & guardrail systems': [
      {'title': 'Are all floor holes covered with material capable of supporting 2x the expected load?', 'desc': '1926.502(i)(3); covers secured and marked "HOLE" or "COVER"'},
      {'title': 'Are guardrails 42 inches (+/- 3 inches) high with midrails at midpoint?', 'desc': '1926.502(b)(1); toprail must withstand 200 lbs force outward or downward'},
      {'title': 'Are guardrail system surfaces smooth to prevent punctures, lacerations, or snagging?', 'desc': '1926.502(b)(3); steel banding and manila rope guardrails prohibited'},
      {'title': 'Are toeboards at least 3.5 inches high when employees work below?', 'desc': '1926.502(b)(2); prevents objects from falling on workers below'},
      {'title': 'Are skylight screens installed to withstand at least 200 lbs applied force?', 'desc': '1926.502(i)(4); standard guardrail or screen protection required'},
      {'title': 'Are employees on formwork or reinforcing steel above 6 feet protected from falls?', 'desc': '1926.501(b)(5); fall protection required during formwork, rebar, and post-tensioning work'},
    ],
    'personal fall arrest systems': [
      {'title': 'Are anchor points capable of supporting 5,000 lbs per attached employee?', 'desc': '1926.502(d)(15); or safety factor of 2 when designed by a qualified person'},
      {'title': 'Are full-body harnesses (not body belts) used as the body wear component?', 'desc': '1926.502(d)(1); body belts banned for fall arrest since 1998'},
      {'title': 'Is total fall distance calculated to ensure no contact with lower level?', 'desc': '1926.502(d)(16)(iii); consider lanyard length + deceleration distance + harness stretch'},
      {'title': 'Are PFAS components inspected before each use and defective units removed?', 'desc': '1926.502(d)(21); inspect for cuts, tears, fraying, corrosion, deformation'},
      {'title': 'Are shock-absorbing lanyards or SRLs (self-retracting lifelines) properly rated?', 'desc': '1926.502(d)(4); max arrest force 1,800 lbs; max deceleration distance 3.5 feet'},
    ],
    'safety net & controlled access': [
      {'title': 'Are safety nets installed as close as practicable under the work surface?', 'desc': '1926.502(c)(1); max 30 feet below; net must extend outward from edge'},
      {'title': 'Are controlled access zones set up with a control line 6-25 feet from the edge?', 'desc': '1926.502(g)(1); only authorised personnel within zone; flagged every 6 feet'},
      {'title': 'Is a safety monitor designated and positioned to warn workers in controlled zones?', 'desc': '1926.502(h); monitor must be competent, on the same surface, within visual/voice range'},
      {'title': 'Are warning lines erected 6 feet from roof edges during roofing on low-slope roofs?', 'desc': '1926.502(f)(1); wire, rope, or chain 34-39 inches high; flagged every 6 feet'},
      {'title': 'Has the safety net been drop-tested with a 400 lb sandbag within the last 6 months?', 'desc': '1926.502(c)(4); test certifies net integrity; re-test after repair or relocation'},
    ],
    'rescue planning & training': [
      {'title': 'Is a prompt rescue plan in place so fallen employees can be reached quickly?', 'desc': '1926.502(d)(20); suspension trauma is life-threatening; rescue within minutes'},
      {'title': 'Have employees been trained to recognize fall hazards and proper protection use?', 'desc': '1926.503(a)(1); training by competent person; re-training when conditions change'},
      {'title': 'Are training records maintained with employee name, date, and trainer signature?', 'desc': '1926.503(b); latest training certification kept; available for inspection'},
      {'title': 'Is self-rescue or assisted-rescue equipment available and accessible?', 'desc': 'Equipment may include rescue descent devices, aerial lifts, or ladder access'},
      {'title': 'Is there a documented procedure for addressing suspension trauma after a fall arrest event?', 'desc': 'Suspension intolerance (orthostatic shock) can be fatal; rapid rescue and positioning critical'},
    ],

    // US5: Hazard Communication (29 CFR 1910.1200)
    'written hazcom program': [
      {'title': 'Is a written Hazard Communication program maintained at each workplace?', 'desc': '1910.1200(e)(1); includes list of hazardous chemicals and methods employer uses for each element'},
      {'title': 'Does the program include a current chemical inventory listing all hazardous chemicals?', 'desc': '1910.1200(e)(1)(i); cross-referenced with SDS file; updated when new chemicals are introduced'},
      {'title': 'Does the program describe methods used to inform employees of the hazards of non-routine tasks?', 'desc': '1910.1200(e)(1)(ii); special procedures for infrequent tasks with chemical exposure'},
      {'title': 'Are multi-employer workplace provisions included (contractors, tenants)?', 'desc': '1910.1200(e)(2); host must share SDS, labelling system, and protective measures'},
      {'title': 'Is the written program made available during work hours to all employees?', 'desc': '1910.1200(e)(1); electronic or physical access acceptable'},
      {'title': 'Is the written HazCom program reviewed annually or when processes and chemicals change?', 'desc': '1910.1200(e)(1); program must reflect current workplace conditions and chemical inventory'},
    ],
    'safety data sheet management': [
      {'title': 'Is an SDS available for every hazardous chemical present in the workplace?', 'desc': '1910.1200(g)(1); 16-section GHS format; employer must obtain missing SDS'},
      {'title': 'Are SDS documents readily accessible to all employees during each shift?', 'desc': '1910.1200(g)(8); electronic access requires backup in case of computer failure'},
      {'title': 'Are SDS documents updated when manufacturers issue new versions?', 'desc': '1910.1200(g)(5); SDSs must not be older than 3 years without verification'},
      {'title': 'Are SDS documents maintained for chemicals even after they are no longer used?', 'desc': 'OSHA Access to Employee Exposure and Medical Records: 30-year retention per 1910.1020'},
      {'title': 'Are incoming SDS documents checked for all 16 required GHS sections before filing?', 'desc': '1910.1200(g)(2); incomplete SDS must be returned to manufacturer for correction'},
      {'title': 'If SDS access is electronic, is a backup system available in case of power or IT failure?', 'desc': '1910.1200(g)(8); paper copies or offline access ensures uninterrupted availability'},
    ],
    'container labelling & ghs': [
      {'title': 'Are all containers of hazardous chemicals labelled with GHS-compliant labels?', 'desc': '1910.1200(f)(1); product name, signal word, hazard statement, pictograms, precautionary statements'},
      {'title': 'Are labels legible, written in English, and prominently displayed?', 'desc': '1910.1200(f)(6); additional languages acceptable; labels must not be defaced'},
      {'title': 'Are secondary (workplace) containers labelled with product identity and hazard warnings?', 'desc': '1910.1200(f)(6); immediate-use containers exempt if under control of single employee'},
      {'title': 'Are incoming containers checked for proper labelling upon receipt?', 'desc': '1910.1200(f)(5); employer must not accept unlabelled or mislabelled containers'},
      {'title': 'Are pipe markings or placards used for stationary process containers?', 'desc': '1910.1200(f)(6)(ii); signs, placards, or other written communication acceptable'},
      {'title': 'Are damaged, faded, or illegible labels identified and replaced promptly during inspections?', 'desc': '1910.1200(f)(9); label maintenance ensures ongoing hazard communication effectiveness'},
    ],
    'employee training & information': [
      {'title': 'Are employees trained at the time of initial assignment on hazardous chemicals present?', 'desc': '1910.1200(h)(1); training before first potential exposure'},
      {'title': 'Is training provided when a new chemical hazard is introduced to the workplace?', 'desc': '1910.1200(h)(1); must cover new hazard and updated protective measures'},
      {'title': 'Does training cover how to read labels and access and interpret SDS documents?', 'desc': '1910.1200(h)(3)(iii); employees must understand physical and health hazards'},
      {'title': 'Are employees informed of the location and availability of the written HazCom program?', 'desc': '1910.1200(h)(2)(i); includes chemical inventory and procedures'},
      {'title': 'Are training records maintained with content covered, attendees, and date?', 'desc': 'Best practice documentation; OSHA may request during inspection'},
      {'title': 'Is refresher training conducted at defined intervals or when deficiencies are observed?', 'desc': '1910.1200(h)(1); ongoing competency ensures workers stay current with chemical hazards'},
    ],

    // ════════════════════════════════════════════════════════════════
    // AU WHS — Safe Work Australia / WHS Act 2011
    // ════════════════════════════════════════════════════════════════

    // AU1: Working at Heights (WHS Regs Ch 6)
    'fall prevention hierarchy': [
      {'title': 'Has the PCBU applied the hierarchy of control: eliminate, substitute, isolate, engineer, admin, PPE?', 'desc': 'WHS Regs s 36; work at height must be eliminated where reasonably practicable'},
      {'title': 'Has a Safe Work Method Statement (SWMS) been prepared for the high-risk construction work?', 'desc': 'WHS Regs s 299; SWMS required before high-risk work commences'},
      {'title': 'Are fall prevention devices (guardrails, barriers) given priority over fall arrest?', 'desc': 'WHS Regs s 79(2); passive systems preferred over active/reactive systems'},
      {'title': 'Has a risk assessment been conducted specific to the fall hazard and documented?', 'desc': 'WHS Act s 17; duty to identify, assess, and control risks'},
      {'title': 'Are workers consulted about the fall prevention measures before work begins?', 'desc': 'WHS Act s 47; workers and HSRs must be consulted on health and safety matters'},
      {'title': 'Have all workers signed onto the SWMS before commencing work at height?', 'desc': 'WHS Regs s 300; signed SWMS must be available on site and reviewed if conditions change'},
    ],
    'scaffold & ewp condition': [
      {'title': 'Is the scaffold erected by a licensed scaffolder and in accordance with AS/NZS 1576?', 'desc': 'WHS Regs s 80(2)(b); scaffold must comply with Australian Standards'},
      {'title': 'Has the scaffold been inspected and tagged by a competent person before use?', 'desc': 'Green tag = fit for use; red tag = do not use; yellow = restricted use'},
      {'title': 'Are Elevated Work Platforms (EWPs) operated by persons holding the correct HRWL ticket?', 'desc': 'WHS Regs s 82; boom-type EWP >11m requires WP licence'},
      {'title': 'Are pre-start checks completed on all EWPs before each shift?', 'desc': 'Log book entries; check controls, guardrails, outriggers, emergency descent'},
      {'title': 'Are exclusion zones established below the scaffold/EWP to protect persons below?', 'desc': 'WHS Regs s 78; prevent objects falling on workers at lower levels'},
      {'title': 'Is the scaffold re-inspected and re-tagged after any alteration, adverse weather, or period of non-use?', 'desc': 'AS/NZS 1576; scaffold tag status must be updated to reflect current condition'},
    ],
    'edge protection & penetrations': [
      {'title': 'Are all unprotected edges, openings, and penetrations guarded or covered?', 'desc': 'WHS Regs s 78(2); covers secured, load-rated, and clearly marked'},
      {'title': 'Do guardrails comply with AS/NZS 1657 (top rail 900mm, mid rail, kickboard)?', 'desc': 'Fixed platforms and walkways; temporary guardrails to comparable standard'},
      {'title': 'Are fragile surfaces (skylights, fibre cement sheeting) identified and protected?', 'desc': 'WHS Regs s 78; warning signs + physical barriers; no walking on fragile surfaces'},
      {'title': 'Are stairwell openings and lift shaft openings secured with temporary barricades?', 'desc': 'Physical barrier or signage alone is insufficient; positive physical protection required'},
      {'title': 'Are there adequate controls for work near open edges during high winds?', 'desc': 'SWA Code of Practice: Managing Risk of Falls; work stopped in unsafe conditions'},
    ],
    'anchor points & harness': [
      {'title': 'Are anchor points rated to AS/NZS 1891.4 and certified (min 15 kN)?', 'desc': 'WHS Regs s 79(3); anchor points installed and tested by competent person'},
      {'title': 'Are full-body harnesses compliant with AS/NZS 1891.1 and inspected before each use?', 'desc': 'Check stitching, webbing, D-rings, buckles; replace if damaged or past service life'},
      {'title': 'Is free-fall distance limited to 2 metres maximum with personal arrest equipment?', 'desc': 'AS/NZS 1891.4 Table 2.1; includes lanyard deployment + energy absorber + harness stretch'},
      {'title': 'Are lanyards and energy absorbers within their service life and free from damage?', 'desc': 'Replace after deployment or if cut, frayed, or UV degraded per AS/NZS 1891.1'},
      {'title': 'Have workers been trained in the correct fitting, use, and limitations of harness systems?', 'desc': 'WHS Regs s 39; competent person must provide instruction in fall arrest systems'},
    ],
    'emergency rescue provisions': [
      {'title': 'Is a rescue plan documented and communicated to all workers at height?', 'desc': 'WHS Regs s 80(1)(c); rescue must be achievable within 20 minutes of a fall arrest'},
      {'title': 'Is designated rescue equipment (descent devices, haul kits, stretchers) available on site?', 'desc': 'Equipment inspected, maintained, and accessible at the work location'},
      {'title': 'Have rescue personnel been trained and practised in the rescue procedures?', 'desc': 'Annual drill minimum; scenario-based training for each type of fall arrest used'},
      {'title': 'Is emergency services contact information displayed prominently?', 'desc': 'Site emergency plan includes 000 contact, site address, nearest hospital, first aider'},
      {'title': 'Are workers trained to recognise suspension trauma and provide first aid?', 'desc': 'Suspension intolerance can be fatal within 30 minutes; awareness training critical'},
    ],

    // AU2: Confined Space Entry (AS 2865 / WHS Regs)
    'confined space risk assessment': [
      {'title': 'Has a documented risk assessment been completed for the specific confined space?', 'desc': 'WHS Regs s 66; must identify atmospheric, engulfment, entrapment hazards'},
      {'title': 'Has the space been classified as per AS 2865 (hazardous atmosphere, restricted entry)?', 'desc': 'AS 2865 s 1.4.2; classification determines control measures required'},
      {'title': 'Are all hazards identified and controls documented in the SWMS?', 'desc': 'WHS Regs s 299; SWMS required for confined space entry as high-risk work'},
      {'title': 'Has the risk assessment been reviewed since the last entry or change in conditions?', 'desc': 'WHS Regs s 38; review required when controls no longer effective'},
      {'title': 'Is the risk assessment signed off by the PCBU or responsible person?', 'desc': 'AS 2865 s 2.3; authorisation of entry based on documented assessment'},
      {'title': 'Have workers and HSRs been consulted on the confined space risk assessment findings?', 'desc': 'WHS Act s 47; worker consultation on risk controls is a legal obligation'},
    ],
    'entry permit & signage': [
      {'title': 'Is a current entry permit issued before any person enters the confined space?', 'desc': 'WHS Regs s 67; permit specifies space, duration, entrants, and conditions'},
      {'title': 'Are proper warning signs and barricades erected at all entry points?', 'desc': 'AS 2865 s 3.1; "DANGER - CONFINED SPACE" signage prominently displayed'},
      {'title': 'Does the permit list all control measures including isolation, ventilation, PPE?', 'desc': 'WHS Regs s 67(2); specific to the space and the work being performed'},
      {'title': 'Is the permit duration limited and re-issued for extended work periods?', 'desc': 'Best practice: shift-length maximum; night shift re-issue required'},
      {'title': 'Are cancelled permits filed for review and audit?', 'desc': 'WHS Regs s 67(4); retain records for compliance verification'},
    ],
    'atmospheric monitoring equipment': [
      {'title': 'Is atmospheric monitoring conducted before and during entry with a 4-gas detector?', 'desc': 'AS 2865 s 4.2; test O2, LEL, CO, H2S as minimum; additional gases as identified'},
      {'title': 'Is the gas detector currently calibrated and bump-tested before each use?', 'desc': 'AS 2865 s 4.2.3; manufacturer calibration schedule; bump test daily'},
      {'title': 'Are alarm set points correct (O2: 19.5%-23.5%, LEL: <10%, CO: <30ppm)?', 'desc': 'AS 2865 Table 4.1; TWA PELs per WES (Workplace Exposure Standards)'},
      {'title': 'Is continuous monitoring provided during entry where atmospheric hazard exists?', 'desc': 'WHS Regs s 68(1)(d); monitor must be positioned at breathing zone of entrant'},
      {'title': 'Are gas monitoring records maintained on the entry permit?', 'desc': 'AS 2865 s 4.2.5; pre-entry and periodic readings documented'},
    ],
    'standby person & communication': [
      {'title': 'Is a trained standby person stationed at the entry point at all times during entry?', 'desc': 'WHS Regs s 68(1)(e); standby must not enter the space or leave the post'},
      {'title': 'Is reliable communication maintained between entrant and standby person?', 'desc': 'AS 2865 s 5.3; voice, radio, tug-line depending on space configuration'},
      {'title': 'Does the standby person have authority to order immediate evacuation?', 'desc': 'WHS Regs s 68(1)(f); no hesitation permitted when conditions deteriorate'},
      {'title': 'Is the standby person trained in emergency response procedures?', 'desc': 'WHS Regs s 39; trained in use of rescue equipment and first response'},
      {'title': 'Are entry and exit times logged by the standby person?', 'desc': 'AS 2865 s 5.4; accountability register maintained throughout entry'},
    ],
    'emergency & rescue procedure': [
      {'title': 'Is a written emergency and rescue procedure documented for the specific space?', 'desc': 'WHS Regs s 69; procedure reviewed before each entry; communicated to all'},
      {'title': 'Is non-entry rescue (retrieval line, mechanical advantage) the first option?', 'desc': 'AS 2865 s 6.2; entry rescue only when non-entry is impracticable'},
      {'title': 'Are rescue personnel competent and equipped with SCBA if atmospheric hazard exists?', 'desc': 'WHS Regs s 69(2); rescue team must not become additional casualties'},
      {'title': 'Is rescue equipment (harness, retrieval line, tripod/davit) available at the entry point?', 'desc': 'AS 2865 s 6.3; equipment inspected before each entry; functionally tested'},
      {'title': 'Has a rescue drill been conducted within the last 12 months?', 'desc': 'Best practice: annual drill minimum; document participants and outcomes'},
    ],

    // AU3: Asbestos Management Plan Review (WHS Regs Ch 8)
    'asbestos register completeness': [
      {'title': 'Is an asbestos register maintained and available at the workplace?', 'desc': 'WHS Regs s 425; register identifies location, type, condition of all known/assumed ACM'},
      {'title': 'Has the register been prepared or reviewed by a competent person?', 'desc': 'WHS Regs s 422; competent person as defined in the WHS Regs'},
      {'title': 'Does the register include a site plan/diagram showing ACM locations?', 'desc': 'WHS Regs s 425(1)(b); accessible to all workers and contractors'},
      {'title': 'Is the register reviewed and updated when refurbishment or demolition is planned?', 'desc': 'WHS Regs s 425(4); re-assessment required before work that may disturb ACM'},
      {'title': 'Are inaccessible areas noted as assumed to contain asbestos?', 'desc': 'WHS Regs s 422(2); material must be assumed ACM unless tested'},
    ],
    'management plan & pcbu duties': [
      {'title': 'Is there a current asbestos management plan for the workplace?', 'desc': 'WHS Regs s 429; plan maintained while ACM is present; reviewed every 5 years'},
      {'title': 'Does the plan assign responsibility for control measures and monitoring?', 'desc': 'WHS Regs s 429(2); PCBU duties; nominated competent person identified'},
      {'title': 'Does the plan set out a schedule for condition monitoring of ACM?', 'desc': 'WHS Regs s 429(2)(c); frequency depends on condition and risk; typically annual'},
      {'title': 'Are workers and contractors informed of ACM locations before work begins?', 'desc': 'WHS Regs s 426; PCBU must provide register to any person who requests it'},
      {'title': 'Is the plan reviewed after any incident, removal, or change in condition?', 'desc': 'WHS Regs s 429(5); continuous improvement obligation'},
    ],
    'identification & labelling': [
      {'title': 'Are all identified ACM labelled with clear asbestos warning signs?', 'desc': 'WHS Regs s 427; labels at or near ACM; must not be obscured'},
      {'title': 'Have samples been analysed by a NATA-accredited laboratory where required?', 'desc': 'WHS Regs s 422(4); only NATA labs can provide definitive identification'},
      {'title': 'Are warning signs displayed at entrances to areas containing ACM?', 'desc': 'WHS Regs s 427(2); signs in accordance with AS 1319'},
      {'title': 'Is friable asbestos distinctly identified from non-friable (bonded) asbestos?', 'desc': 'WHS Regs s 419; friable = crumble by hand; much higher risk classification'},
      {'title': 'Are all contractors required to check the register before commencing work?', 'desc': 'WHS Regs s 426; PCBU must ensure the register is accessible'},
    ],
    'air monitoring & exposure': [
      {'title': 'Is air monitoring conducted when ACM is being disturbed or removed?', 'desc': 'WHS Regs s 444; sampling by licenced assessor; results compared to exposure standard'},
      {'title': 'Are exposure standards met (<0.1 fibres/mL for all types of asbestos)?', 'desc': 'WHS Regs s 420; TWA 8-hour; PCBU must ensure no exceedance'},
      {'title': 'Is personal protective equipment (P2 respirator minimum) provided during work near ACM?', 'desc': 'WHS Regs s 442; RPE selection based on fibre levels and duration'},
      {'title': 'Are decontamination facilities provided when asbestos removal is underway?', 'desc': 'WHS Regs s 472; three-stage decontamination unit for friable removal'},
      {'title': 'Are air monitoring results retained for at least 30 years?', 'desc': 'WHS Regs s 449; health monitoring and exposure records retained'},
    ],
    'clearance certificates & records': [
      {'title': 'Is a clearance certificate issued by a licenced assessor after asbestos removal?', 'desc': 'WHS Regs s 473; area must not be re-occupied until clearance is received'},
      {'title': 'Are removal records retained including waste disposal documentation?', 'desc': 'WHS Regs s 458; transport and disposal at licenced facility; tracking certificate'},
      {'title': 'Is the asbestos register updated to reflect removal or encapsulation?', 'desc': 'WHS Regs s 425(4); register must reflect current state of ACM in the workplace'},
      {'title': 'Are worker health monitoring records maintained for those exposed?', 'desc': 'WHS Regs s 435; medical practitioner report retained 40 years per Sch 19'},
      {'title': 'Is proof of Class A or Class B asbestos removal licence held by the contractor?', 'desc': 'WHS Regs s 458; Class A for friable; Class B for >10m2 non-friable'},
    ],

    // AU4: Plant & Equipment Risk Assessment (WHS Regs Ch 5)
    'design registration & compliance': [
      {'title': 'Is registered plant (pressure equipment, cranes, hoists) current with design registration?', 'desc': 'WHS Regs s 243; design registration with regulator for high-risk plant items'},
      {'title': 'Does the plant comply with relevant Australian Standards (AS 4024, AS 1418, AS 3990)?', 'desc': 'WHS Regs s 209; PCBU must ensure plant designed and constructed to applicable standards'},
      {'title': 'Is documentation (compliance plates, SWL plates) affixed to the plant?', 'desc': 'WHS Regs s 249; plant must not be used without required plates and markings'},
      {'title': 'Are modifications to plant documented and assessed for compliance impact?', 'desc': 'WHS Regs s 210; modifications may require re-registration or engineering sign-off'},
      {'title': 'Is a current record of plant registration maintained and accessible?', 'desc': 'WHS Regs s 245; registration number, plant type, location, and responsible person'},
      {'title': 'Is there a documented procedure for isolating, tagging, and decommissioning plant no longer in service?', 'desc': 'WHS Regs s 214; decommissioned plant must be rendered safe and clearly identified'},
    ],
    'guarding & safety devices': [
      {'title': 'Are all power-operated moving parts guarded against access?', 'desc': 'WHS Regs s 208(2); guard to prevent contact with nip points, rotating parts, cutting edges'},
      {'title': 'Are interlocked guards functional and not bypassed?', 'desc': 'AS 4024.1601; interlock must stop hazardous motion when guard is opened'},
      {'title': 'Are emergency stop devices fitted and accessible from each operator position?', 'desc': 'AS 4024.1604; red mushroom-head on yellow background; manual reset'},
      {'title': 'Are safety devices (light curtains, two-hand controls, pressure mats) tested regularly?', 'desc': 'WHS Regs s 213; functional testing documented per manufacturer recommendations'},
      {'title': 'Are warning signs posted where residual risk remains after guarding?', 'desc': 'AS 1319; signs supplement (not replace) physical guarding measures'},
    ],
    'maintenance & inspection records': [
      {'title': 'Is a maintenance schedule in place for all plant items?', 'desc': 'WHS Regs s 213; preventive maintenance per manufacturer and risk assessment'},
      {'title': 'Are inspection and service records kept for each plant item?', 'desc': 'WHS Regs s 235; records of inspection, maintenance, and any defects found'},
      {'title': 'Are major inspections conducted at intervals not exceeding those in Sch 10?', 'desc': 'WHS Regs Sch 10; specific intervals for pressure vessels, cranes, lifts'},
      {'title': 'Are defective plant items tagged out and isolated until repaired?', 'desc': 'WHS Regs s 215; PCBU must not allow use of defective plant'},
      {'title': 'Are maintenance workers trained and competent for the plant they service?', 'desc': 'WHS Regs s 39; competent person; LOTO procedures applied during maintenance'},
    ],
    'operator competency & licensing': [
      {'title': 'Do operators hold the correct High Risk Work Licence (HRWL) for the plant?', 'desc': 'WHS Regs s 82; licence classes: CN, CV, CB, DG, O1-O7, RB, RI, SB, etc.'},
      {'title': 'Are operator licences current and verified before commencing work?', 'desc': 'WHS Regs s 84; PCBU must not direct unlicensed persons to operate licensed plant'},
      {'title': 'Have operators received site-specific induction for the plant they will operate?', 'desc': 'WHS Regs s 39; general induction + specific plant familiarisation'},
      {'title': 'Are supervision arrangements in place for trainees and apprentice operators?', 'desc': 'WHS Regs s 83; trainee must be under direct supervision of licensed person'},
      {'title': 'Is refresher training provided at documented intervals?', 'desc': 'Best practice: annual refresher; mandatory if involved in incident or near miss'},
    ],
    'risk control hierarchy': [
      {'title': 'Has the hierarchy of control been applied to all identified plant risks?', 'desc': 'WHS Act s 17 + WHS Regs s 36; eliminate > substitute > isolate > engineer > admin > PPE'},
      {'title': 'Are engineering controls given priority over administrative controls and PPE?', 'desc': 'SWA Code of Practice: Managing Risks of Plant; higher-order controls preferred'},
      {'title': 'Are residual risks documented and communicated to operators?', 'desc': 'Risk register maintained; operators informed of controls and limitations'},
      {'title': 'Is the risk assessment reviewed when incidents occur or plant conditions change?', 'desc': 'WHS Regs s 38; ongoing obligation to review and revise controls'},
      {'title': 'Are workers consulted in the development of risk control measures?', 'desc': 'WHS Act s 47; consultation with workers and Health and Safety Representatives'},
    ],

    // AU5: Excavation & Trenching Audit (WHS Regs Ch 7)
    'geotechnical assessment': [
      {'title': 'Has a geotechnical assessment been conducted for excavations >1.5m deep?', 'desc': 'WHS Regs s 306; assessment of soil type, water table, and stability'},
      {'title': 'Is the soil classification documented (Type A, B, or C equivalent)?', 'desc': 'AS 4678 / Geotechnical report; clay vs sand vs fill determines support required'},
      {'title': 'Have adjacent structures and their foundation depths been assessed?', 'desc': 'WHS Regs s 305; surcharge loads from buildings, roads, stockpiles considered'},
      {'title': 'Are ground conditions re-assessed after rain, flooding, or vibration events?', 'desc': 'WHS Regs s 306(3); dynamic conditions require ongoing reassessment'},
      {'title': 'Is the geotechnical report available on site and referenced in the SWMS?', 'desc': 'WHS Regs s 299; SWMS must reference geotechnical findings'},
    ],
    'shoring, benching & battering': [
      {'title': 'Is adequate shoring, benching, or battering installed for excavations >1.5m?', 'desc': 'WHS Regs s 306(2)(a); method selected based on soil type and depth'},
      {'title': 'Is the shoring system designed by a competent person or engineer?', 'desc': 'WHS Regs s 307; engineering design for depths >3m or complex conditions'},
      {'title': 'Are trench shields/boxes correctly positioned and rated for the depth?', 'desc': 'Manufacturer SWL ratings; shield must extend above trench batter line'},
      {'title': 'Is the batter angle appropriate for the soil type (e.g., 1:1 for Type C soil)?', 'desc': 'AS 4678 Table values; steeper angles require engineering justification'},
      {'title': 'Are spoil heaps placed at least 1m back from the edge of the excavation?', 'desc': 'WHS Regs s 305(2); surcharge loading affects trench wall stability'},
    ],
    'edge protection & barricading': [
      {'title': 'Is the excavation perimeter barricaded or fenced to prevent falls?', 'desc': 'WHS Regs s 78; physical barricade min 900mm high; high-visibility markers'},
      {'title': 'Are excavations near public areas secured with hoarding and signage?', 'desc': 'Local council requirements; "DANGER OPEN EXCAVATION" signage per AS 1319'},
      {'title': 'Are vehicle barriers (concrete blocks, rail) installed where vehicles could approach?', 'desc': 'WHS Regs s 305(3); vehicle setback distance based on vehicle weight and speed'},
      {'title': 'Are warning lights or reflectors installed for night-time visibility?', 'desc': 'Traffic management plan; solar-powered lights on barricades'},
      {'title': 'Are pedestrian walkways maintained clear around the excavation perimeter?', 'desc': 'WHS Regs s 305; persons must not approach the edge unless protected'},
    ],
    'underground services location': [
      {'title': 'Has a Dial Before You Dig (DBYD) request been lodged and plans received?', 'desc': 'WHS Regs s 304(1)(a); DBYD enquiry for assets in the vicinity'},
      {'title': 'Have underground services been physically located by non-destructive methods (GPR, cable locator)?', 'desc': 'WHS Regs s 304(1)(b); pot-holing by hand/vacuum excavation near services'},
      {'title': 'Are all identified services marked on the ground and on the site plan?', 'desc': 'Colour-coded marking: red=electric, yellow=gas, blue=water, white=comms'},
      {'title': 'Is hand digging or vacuum excavation used within the tolerance zone of services?', 'desc': 'WHS Regs s 304(2); no machine excavation within 500mm of any service'},
      {'title': 'Have service asset owners been contacted for specific requirements?', 'desc': 'WHS Regs s 304(3); special conditions for high-pressure gas, high-voltage cable'},
    ],
    'access, egress & dewatering': [
      {'title': 'Is safe access/egress provided within 25m of any worker in the excavation?', 'desc': 'WHS Regs s 306(2)(c); ladder, ramp, or stairway; extend 1m above ground level'},
      {'title': 'Are ladders secured at the top and bottom and positioned at correct angle (4:1)?', 'desc': 'AS/NZS 1892.1; ladder must extend 1m above landing; non-slip feet'},
      {'title': 'Is dewatering equipment adequate to control groundwater or rainwater ingress?', 'desc': 'Sump pump capacity; well-pointing for high water table; maintain stable conditions'},
      {'title': 'Are workers protected from hazards of pumped water discharge?', 'desc': 'Discharge away from excavation edge; erosion protection for adjacent ground'},
      {'title': 'Is the excavation inspected by a competent person before each shift and after weather events?', 'desc': 'WHS Regs s 306(3); daily inspection documented; after rain, vibration, etc.'},
    ],

    // ════════════════════════════════════════════════════════════════
    // Additional US OSHA — High-Volume Templates
    // ════════════════════════════════════════════════════════════════

    // US6: NFPA 70E Electrical Safety Audit
    'arc flash hazard analysis': [
      {'title': 'Has an arc flash hazard analysis been performed for all electrical equipment?', 'desc': 'NFPA 70E 130.5; incident energy analysis or arc flash PPE category method required'},
      {'title': 'Are arc flash boundary distances calculated and documented?', 'desc': 'NFPA 70E 130.5(A); boundary = distance where incident energy = 1.2 cal/cm²'},
      {'title': 'Is the hazard analysis reviewed when modifications affect the electrical system?', 'desc': 'NFPA 70E 130.5(C); changes in fault current, clearing times, or system configuration'},
      {'title': 'Are short-circuit current and protective device clearing times documented?', 'desc': 'IEEE 1584 calculation methodology; upstream coordination study required'},
      {'title': 'Has the analysis been updated within the last 5 years?', 'desc': 'NFPA 70E 130.5(C); periodic review required; best practice every 3-5 years'},
    ],
    'energized electrical work permits': [
      {'title': 'Is work on energized circuits only performed when de-energizing creates a greater hazard?', 'desc': 'NFPA 70E 130.2(A); de-energize as the default — energized work is the exception'},
      {'title': 'Is an Energized Electrical Work Permit (EEWP) completed before live work?', 'desc': 'NFPA 70E 130.2(B); permit documents justification, hazards, PPE, and approach limits'},
      {'title': 'Does the EEWP include a detailed job safety plan with shock and arc flash boundaries?', 'desc': 'NFPA 70E 130.2(B)(2); limited, restricted, and arc flash boundaries identified'},
      {'title': 'Is the EEWP signed by an authorized management representative?', 'desc': 'NFPA 70E 130.2(B)(3); approval authority defined in the electrical safety program'},
      {'title': 'Are completed EEWPs retained as part of the electrical safety program records?', 'desc': 'Employer documentation; permits filed for compliance verification and auditing'},
    ],
    'approach boundaries & ppe selection': [
      {'title': 'Are limited, restricted, and prohibited approach boundaries posted or communicated?', 'desc': 'NFPA 70E Table 130.4(E)(a); boundaries based on voltage level'},
      {'title': 'Is arc-rated PPE selected based on incident energy at the working distance?', 'desc': 'NFPA 70E 130.5(G) and Table 130.7(C)(15)(a); PPE category 1 through 4'},
      {'title': 'Are voltage-rated gloves and leather protectors matched to the voltage class?', 'desc': 'NFPA 70E Table 130.7(C)(7)(a); Class 00 through Class 4; tested per ASTM D120'},
      {'title': 'Is insulated tooling rated for the voltage being worked on?', 'desc': 'NFPA 70E 130.7(D)(1); tools tested per IEC 60900; double-insulated preferred'},
      {'title': 'Are face shields and arc-rated balaclava used when incident energy exceeds 4 cal/cm²?', 'desc': 'NFPA 70E Table 130.7(C)(15)(b); category 2+ requires full face and head protection'},
    ],
    'equipment labelling & documentation': [
      {'title': 'Is all electrical equipment labelled with arc flash and shock hazard warnings?', 'desc': 'NFPA 70E 130.5(H); label includes available incident energy or PPE category'},
      {'title': 'Do labels include nominal system voltage and arc flash boundary distance?', 'desc': 'NFPA 70E 130.5(H)(1)-(3); date of analysis and equipment identification'},
      {'title': 'Are single-line diagrams current and accessible?', 'desc': 'Diagrams show protective device settings, transformer impedances, and cable lengths'},
      {'title': 'Are lockout/tagout points clearly identified on each piece of equipment?', 'desc': 'NFPA 70E 120.2; isolation points labelled and referenced in lock-out procedures'},
      {'title': 'Is the written electrical safety program accessible to all qualified workers?', 'desc': 'NFPA 70E 110.3; program controls safety-related work practices and procedures'},
    ],
    'training & qualification records': [
      {'title': 'Are all electrical workers classified as qualified or unqualified per NFPA 70E?', 'desc': 'NFPA 70E 110.6(A); qualified persons trained on specific voltage and equipment'},
      {'title': 'Have qualified workers received training on shock and arc flash hazard recognition?', 'desc': 'NFPA 70E 110.6(A)(1); skills and techniques for safe work around energized parts'},
      {'title': 'Is retraining provided when new equipment or procedures are introduced?', 'desc': 'NFPA 70E 110.6(B); also required when audit reveals deficiency or after incident'},
      {'title': 'Are CPR and AED training records current for all electrical workers?', 'desc': 'NFPA 70E 110.6(C); at least one person trained per work crew'},
      {'title': 'Are training certifications documented with name, date, content, and trainer?', 'desc': 'NFPA 70E 110.6(D); records maintained by employer; available for audit'},
    ],

    // US7: OSHA Powered Industrial Trucks (29 CFR 1910.178)
    'pre-shift truck condition check': [
      {'title': 'Is a documented pre-operation inspection performed before each shift?', 'desc': '1910.178(q)(7); check forks, tyres, mast, hydraulics, horn, lights, seat belt'},
      {'title': 'Are forks free from cracks, bending, or excessive wear?', 'desc': 'Fork arm wear >10% of original thickness requires replacement; check for heel cracks'},
      {'title': 'Are fluid levels (hydraulic, engine oil, coolant) checked and adequate?', 'desc': 'Manufacturer maintenance schedule; leaked fluids create slip hazards'},
      {'title': 'Is the seat belt / operator restraint system functional?', 'desc': '1910.178(l)(6); restraint prevents operator being thrown from cab during tip-over'},
      {'title': 'Are defective trucks immediately tagged out and removed from service?', 'desc': '1910.178(q)(7); shall not be placed in service until restored to safe condition'},
    ],
    'operator training & certification': [
      {'title': 'Has each operator completed formal training per 1910.178(l)?', 'desc': '1910.178(l)(1); truck-related topics, workplace-related topics, and practical evaluation'},
      {'title': 'Is a practical driving evaluation completed for each truck type operated?', 'desc': '1910.178(l)(2)(ii); conducted in the workplace by a qualified trainer'},
      {'title': 'Is refresher training provided at least every 3 years?', 'desc': '1910.178(l)(4)(iii); evaluation to confirm competence at 3-year intervals'},
      {'title': 'Is retraining provided after an accident, near miss, or observed unsafe operation?', 'desc': '1910.178(l)(4)(ii); also required when assigned a different truck type'},
      {'title': 'Are training records maintained showing name, date, trainer, and evaluation results?', 'desc': '1910.178(l)(6); certification that training and evaluation have been completed'},
    ],
    'travel & operating rules': [
      {'title': 'Are speed limits posted and enforced in pedestrian and high-traffic areas?', 'desc': '1910.178(n)(1); speed appropriate for conditions; slow at intersections'},
      {'title': 'Are trucks operated with forks lowered and mast tilted back when traveling?', 'desc': '1910.178(n)(4); load just high enough to clear road surface'},
      {'title': 'Are operators sounding horn at blind corners and intersections?', 'desc': '1910.178(n)(6); audible warning at cross-aisles and obstructed views'},
      {'title': 'Is the truck operated on grades with load upgrade and within tilt limits?', 'desc': '1910.178(n)(7); drive up ramps with load forward; reverse down when loaded'},
      {'title': 'Are riders prohibited unless the truck is designed for passenger transport?', 'desc': '1910.178(n)(3); no person shall ride on the forks or stand under elevated load'},
    ],
    'load handling & stability': [
      {'title': 'Are loads centered and within the rated capacity for the truck?', 'desc': '1910.178(o)(2); capacity plate rating must not be exceeded; check load center distance'},
      {'title': 'Are unstable or oddly shaped loads properly secured before lifting?', 'desc': 'Banding, wrapping, or caging required; tilted loads create tip-over risk'},
      {'title': 'Is load height checked against overhead clearances (sprinklers, lights, ductwork)?', 'desc': 'Minimum clearance maintained; crush hazards from overhead obstructions'},
      {'title': 'Are forks fully inserted under the load before lifting?', 'desc': '1910.178(o)(3); partial insertion creates instability and risk of load slipping'},
      {'title': 'Are attachment accessories (clamps, extensions, side-shifters) inspected and rated?', 'desc': 'Attachments alter truck capacity; de-rating plate must reflect reduced capacity'},
    ],
    'pedestrian safety & awareness': [
      {'title': 'Are pedestrian walkways separated from forklift routes with physical barriers?', 'desc': 'Floor markings, guardrails, and bollards; intersections controlled with mirrors or lights'},
      {'title': 'Are blue safety lights or audible alarms fitted to trucks in busy areas?', 'desc': 'Blue spot lights project a visible warning ahead of the moving truck'},
      {'title': 'Are all personnel trained on forklift interaction awareness?', 'desc': 'Pedestrian training covers eye contact, right-of-way, and keep-clear zones'},
      {'title': 'Is there a no-walk zone established around operating trucks?', 'desc': 'Minimum 3-foot clearance from any moving forklift; never walk between racking and truck'},
      {'title': 'Are loading dock procedures coordinated to prevent truck-pedestrian conflicts?', 'desc': 'Dock locks engaged, wheel chocks in place, green light system before truck enters'},
    ],

    // US8: DOT Pre-Trip Vehicle Inspection (49 CFR 396.13)
    'engine, cab & mirrors': [
      {'title': 'Does the engine start and idle without unusual noise or excessive smoke?', 'desc': '49 CFR 396.3(a)(1); engine in safe operating condition; no fluid leaks'},
      {'title': 'Are all gauges and warning lights operational (oil, temp, air pressure, voltage)?', 'desc': '49 CFR 393.51; all instruments functioning; air pressure builds to governor cutout'},
      {'title': 'Are windshield and windows free from cracks that impair visibility?', 'desc': '49 CFR 393.60(b); no obstruction in the area cleaned by wipers'},
      {'title': 'Are all mirrors (rear-view, side-mounted, convex) intact, adjusted, and clean?', 'desc': '49 CFR 393.80; two rear-vision mirrors, one on each side of the vehicle'},
      {'title': 'Are windshield wipers and washers operational?', 'desc': '49 CFR 393.78; automatic wipers in working condition; washer fluid filled'},
    ],
    'brakes, tyres & wheels': [
      {'title': 'Is brake pedal firm and do brakes stop the vehicle without pulling left or right?', 'desc': '49 CFR 396.3(a)(1); service brake system in proper adjustment and safe condition'},
      {'title': 'Is air brake compressor building pressure within acceptable time?', 'desc': '49 CFR 393.42; governor cut-in ~100 psi, cut-out ~125 psi; build-up within 3 minutes'},
      {'title': 'Are all tyres inflated and free from cuts, bulges, and exposed cord?', 'desc': '49 CFR 393.75(a); minimum 4/32" tread on steer axle, 2/32" on other positions'},
      {'title': 'Are lug nuts tight and wheel rims free from cracks or damage?', 'desc': '49 CFR 393.75(g); check for rust trails from loose nuts; no missing lugs'},
      {'title': 'Is the parking/emergency brake holding the vehicle securely?', 'desc': '49 CFR 393.42; spring brakes engaged when air drops below 60 psi'},
    ],
    'lights, signals & reflectors': [
      {'title': 'Are headlights (low and high beam) functional?', 'desc': '49 CFR 393.24; two steady-burning white headlights properly aimed'},
      {'title': 'Are brake lights, turn signals, and hazard flashers all operational?', 'desc': '49 CFR 393.25; red stop lamps visible from 300 feet; amber turn signals'},
      {'title': 'Are clearance and marker lights present and functioning?', 'desc': '49 CFR 393.11; amber front, red rear; ID lamps on vehicles over 80 inches wide'},
      {'title': 'Are all required reflectors and conspicuity tape in place and clean?', 'desc': '49 CFR 393.13; red/white retroreflective sheeting; not obscured by dirt or damage'},
      {'title': 'Is the backup alarm or reverse signal operational?', 'desc': 'OSHA general duty clause; audible alarm when vehicle is in reverse gear'},
    ],
    'steering, suspension & coupling': [
      {'title': 'Is steering free of excessive play and responsive?', 'desc': '49 CFR 393.209; max 2" play for power steering on 20" wheel; check for fluid leaks'},
      {'title': 'Are suspension components (springs, air bags, u-bolts) intact and not cracked?', 'desc': '49 CFR 393.207; no missing, broken, or displaced leaves; air bags not leaking'},
      {'title': 'Is the fifth wheel coupling secure with no visible gaps or cracks?', 'desc': '49 CFR 393.134; jaws closed and locked; release handle in locked position'},
      {'title': 'Are air and electrical connections between tractor and trailer secure?', 'desc': '49 CFR 393.71; glad hands sealed, no leaks; 7-way connector fully engaged'},
      {'title': 'Are safety chains or cables attached on towed vehicles?', 'desc': '49 CFR 393.71(h); two chains crossed under drawbar; sufficient to hold vehicle on grade'},
    ],
    'emergency equipment & documentation': [
      {'title': 'Is a fully charged fire extinguisher (minimum 5BC) accessible?', 'desc': '49 CFR 393.95(a); securely mounted; gauge in green zone; inspection tag current'},
      {'title': 'Are three emergency warning devices (triangles) present and in good condition?', 'desc': '49 CFR 393.95(f); placed 10, 100, and 200 feet behind vehicle in emergency'},
      {'title': 'Is the driver carrying a valid CDL and medical certificate?', 'desc': '49 CFR 383.23; licence class matches vehicle type; medical card not expired'},
      {'title': 'Is the vehicle registration and insurance documentation current and in the cab?', 'desc': '49 CFR 392.2; operating authority documentation available for inspection'},
      {'title': 'Is the previous DVIR (Driver Vehicle Inspection Report) reviewed and signed?', 'desc': '49 CFR 396.13(b); driver must review last report; certify defects corrected or none noted'},
    ],

    // US9: OSHA Respiratory Protection Program (29 CFR 1910.134)
    'written program & administration': [
      {'title': 'Is a written respiratory protection program maintained and available?', 'desc': '1910.134(c)(1); covers selection, use, cleaning, maintenance, training, and evaluation'},
      {'title': 'Is a program administrator designated with appropriate qualifications?', 'desc': '1910.134(c)(3); authority and responsibility for the respirator program'},
      {'title': 'Is the program reviewed and updated at least annually?', 'desc': '1910.134(l)(1); ensure effectiveness; address deficiencies identified in workplace evaluations'},
      {'title': 'Are voluntary respirator use provisions documented where applicable?', 'desc': '1910.134(c)(2); Appendix D information provided to voluntary dust mask users'},
      {'title': 'Are procedures for IDLH atmospheres documented and communicated?', 'desc': '1910.134(g)(3); buddy system, rescue provisions, and communication required'},
    ],
    'hazard evaluation & respirator selection': [
      {'title': 'Have workplace exposure assessments identified the specific contaminants?', 'desc': '1910.134(d)(1)(iii); identify chemical state, physical form, and concentration levels'},
      {'title': 'Are respirators selected based on the nature of the hazard and assigned protection factor?', 'desc': '1910.134(d)(1); APF per Table 1; HEPA for particles, cartridge for gases/vapours'},
      {'title': 'Are NIOSH-certified respirators used exclusively?', 'desc': '1910.134(d)(1)(ii); only NIOSH-approved respirators under 42 CFR Part 84'},
      {'title': 'Is the assigned protection factor adequate for the measured exposure ratio?', 'desc': '1910.134(d)(3)(i)(A); workplace protection factor must be ≥ MUC/PEL'},
      {'title': 'Are SCBA or airline respirators provided for oxygen-deficient or IDLH atmospheres?', 'desc': '1910.134(d)(2)(i); SCBA with full facepiece or combination SAR with escape SCBA'},
    ],
    'medical evaluation & fit testing': [
      {'title': 'Have all employees required to wear respirators received a medical evaluation?', 'desc': '1910.134(e)(1); Appendix C questionnaire or physician/PLHCP exam before fit testing'},
      {'title': 'Is the medical evaluation performed by a PLHCP at no cost to the employee?', 'desc': '1910.134(e)(4); includes information about respirator type and working conditions'},
      {'title': 'Is fit testing conducted before initial use and at least annually thereafter?', 'desc': '1910.134(f)(1)-(2); QLFT (saccharin, Bitrex) or QNFT protocol per Appendix A'},
      {'title': 'Is fit testing repeated when a different respirator model or size is assigned?', 'desc': '1910.134(f)(2); each make, model, size, and style must be separately fit tested'},
      {'title': 'Are employees with facial hair that interferes with the respirator seal prohibited from use?', 'desc': '1910.134(g)(1)(i)(A); tight-fitting respirators require clean-shaven seal area'},
    ],
    'respirator use & maintenance': [
      {'title': 'Are respirators cleaned and disinfected after each use (or daily for shared units)?', 'desc': '1910.134(h)(1); cleaning per Appendix B-2 or manufacturer equivalent method'},
      {'title': 'Are respirators stored in a clean, dry location protected from damage?', 'desc': '1910.134(h)(2)(ii); storage to prevent deformation of facepiece and exhalation valve'},
      {'title': 'Are filters, cartridges, and canisters replaced on schedule and labelled with install date?', 'desc': '1910.134(d)(3)(iii)(B); change schedule based on service life or end-of-service indicators'},
      {'title': 'Are emergency-use respirators inspected monthly and after each use?', 'desc': '1910.134(h)(3)(i); inspection documented; SCBA air cylinder pressure checked'},
      {'title': 'Is a user seal check performed by the wearer each time the respirator is put on?', 'desc': '1910.134(g)(1)(iii); positive and negative pressure checks per Appendix B-1'},
    ],
    'training & program evaluation': [
      {'title': 'Are employees trained on respirator hazards, selection, use, limitations, and maintenance?', 'desc': '1910.134(k)(1); training before initial use; covers why respirator is needed'},
      {'title': 'Is retraining provided when workplace conditions or respirator type changes?', 'desc': '1910.134(k)(5); also required when knowledge gaps observed or after incident'},
      {'title': 'Can employees demonstrate putting on, adjusting, and performing seal checks?', 'desc': '1910.134(k)(1)(v); hands-on demonstration required; verbal training is insufficient'},
      {'title': 'Is the respiratory protection program evaluated for effectiveness?', 'desc': '1910.134(l)(1); regular consultations with employees regarding comfort and problems'},
      {'title': 'Are training records maintained with name, date, topics, and trainer credentials?', 'desc': 'Employer documentation per OSHA training record guidelines; available for inspection'},
    ],

    // US10: OSHA Stairways & Ladders (29 CFR 1926 Subpart X)
    'stairway construction & handrails': [
      {'title': 'Are stairways with 4 or more risers or rising >30 inches equipped with handrails?', 'desc': '1926.1052(c)(1); at least one handrail; both sides if >44 inches wide'},
      {'title': 'Are stair handrails 30-37 inches in height measured from the stair tread nosing?', 'desc': '1926.1052(c)(6); capable of withstanding 200 lbs applied in any direction at any point'},
      {'title': 'Are stairway treads uniform in height and depth (max ¼ inch variation)?', 'desc': '1926.1052(a)(2); rise not more than 9.5 inches; tread run not less than 9.5 inches'},
      {'title': 'Are temporary stairs on construction sites stable and properly secured?', 'desc': '1926.1052(a)(1); stairs provided before personnel use the structure'},
      {'title': 'Are stairways kept clear of obstructions, stored materials, and debris?', 'desc': '1926.1060(a); slippery conditions eliminated as soon as possible; adequate lighting'},
    ],
    'portable ladder condition & use': [
      {'title': 'Are portable ladders inspected before each use for defects?', 'desc': '1926.1053(b)(15); bent rails, broken rungs, missing feet, cracked fibreglass'},
      {'title': 'Are ladders set at the correct 4:1 angle (75.5 degrees)?', 'desc': '1926.1053(b)(5)(i); base 1 foot out for every 4 feet of height'},
      {'title': 'Do ladders extend at least 3 feet above the upper landing surface?', 'desc': '1926.1053(b)(1); side rails extend above the upper support surface'},
      {'title': 'Are employees maintaining three points of contact while climbing?', 'desc': '1926.1053(b)(21); no carrying of bulky or heavy loads that prevent proper grip'},
      {'title': 'Are metal ladders prohibited near energized electrical equipment?', 'desc': '1926.1053(b)(12); non-conductive ladders required within voltage proximity'},
    ],
    'fixed ladder & cage systems': [
      {'title': 'Are fixed ladders over 24 feet equipped with cage, well, or fall arrest system?', 'desc': '1926.1053(a)(19); self-retracting lifeline acceptable in lieu of cage for new installations'},
      {'title': 'Are rest platforms provided at 150-foot intervals for caged fixed ladders?', 'desc': '1926.1053(a)(20); offset platforms to prevent objects falling on climbers'},
      {'title': 'Are ladder rungs uniformly spaced not more than 12 inches apart?', 'desc': '1926.1053(a)(3)(i); minimum clear width of 16 inches between side rails'},
      {'title': 'Is the ladder structurally sound with no corrosion, missing rungs, or loose connections?', 'desc': '1926.1053(b)(15); defective ladders tagged out and removed from service'},
      {'title': 'Is the landing platform adequate for safe dismounting at the top?', 'desc': '1926.1053(a)(13); grab bars provided at or above the top of the ladder'},
    ],
    'ladder placement & securing': [
      {'title': 'Are ladders placed on stable, level surfaces or secured against displacement?', 'desc': '1926.1053(b)(6); non-slip base or tethered at top to prevent kick-out'},
      {'title': 'Are ladders placed to avoid contact with power lines (>10 ft for ≤50kV)?', 'desc': '1926.1053(b)(12); consult 1926.416 for voltage-specific clearance distances'},
      {'title': 'Are area(s) around the top and bottom of the ladder kept clear?', 'desc': '1926.1053(b)(4); unobstructed access; door openings do not swing into the ladder'},
      {'title': 'Are extension ladders overlapping the correct number of sections?', 'desc': '1926.1053(b)(9); 3 rung overlap up to 36 ft; 4 rungs for 36-48 ft; 5 for 48-60 ft'},
      {'title': 'Are self-supporting (A-frame) ladders fully opened with spreaders locked?', 'desc': '1926.1053(b)(7); never used in partially closed position; rated load visible'},
    ],
    'training & competent person': [
      {'title': 'Are employees trained to recognize hazards associated with ladders and stairways?', 'desc': '1926.1060(a); training by competent person; covers each hazard addressed by the standard'},
      {'title': 'Is a competent person designated to inspect stairways and ladders at the site?', 'desc': '1926.1060(b); able to identify existing and predictable hazards; authority to correct'},
      {'title': 'Is retraining provided when changes in the workplace create new hazards?', 'desc': '1926.1060(b); also when deficiencies in employee knowledge are observed'},
      {'title': 'Do employees understand load capacity limits for each ladder type?', 'desc': 'Type IA (300 lbs), I (250 lbs), II (225 lbs), III (200 lbs); duty rating on label'},
      {'title': 'Are damaged or defective ladders tagged and removed from service immediately?', 'desc': '1926.1053(b)(16); repaired to meet original design criteria or destroyed'},
    ],

    // ════════════════════════════════════════════════════════════════
    // Additional AU WHS — High-Volume Templates
    // ════════════════════════════════════════════════════════════════

    // AU6: Electrical Test & Tag (AS/NZS 3760)
    'visual inspection & condition': [
      {'title': 'Is the equipment free from visible damage (cracked casing, exposed wires, burn marks)?', 'desc': 'AS/NZS 3760 s 2.2; visual inspection must precede electrical testing'},
      {'title': 'Is the supply lead free from cuts, kinks, fraying, or taped repairs?', 'desc': 'AS/NZS 3760 s 2.2.2; damaged leads must be replaced, not repaired with tape'},
      {'title': 'Is the plug in good condition with no cracked pins, loose backing, or damage?', 'desc': 'AS/NZS 3760 s 2.2.1; check all pins present and straight; earth pin intact'},
      {'title': 'Is the appropriate strain relief or cord grip intact at both plug and appliance?', 'desc': 'Prevents internal conductor stress; grip must clamp the outer sheath, not inner wires'},
      {'title': 'Are ventilation openings unblocked and cooling fans free from obstruction?', 'desc': 'Overheating risk; dust accumulation in heaters, drills, and IT equipment'},
    ],
    'earth continuity testing': [
      {'title': 'Is earth continuity measured at ≤1.0 ohm for Class I equipment?', 'desc': 'AS/NZS 3760 Table 4; measured from earth pin to accessible metal parts'},
      {'title': 'Is the test conducted with an instrument calibrated per manufacturer recommendations?', 'desc': 'AS/NZS 3760 s 4.2; calibration certificate current; test current 200mA-25A'},
      {'title': 'Are extension leads and power boards tested for earth continuity end-to-end?', 'desc': 'AS/NZS 3760 s 4.3; each socket outlet tested independently'},
      {'title': 'Are double-insulated (Class II) items exempted from earth continuity testing?', 'desc': 'AS/NZS 3760 s 4.4; only insulation resistance and polarity tests apply'},
      {'title': 'Are failed items immediately removed from service and tagged accordingly?', 'desc': 'Failed items must be repaired by a licensed electrician before return to service'},
    ],
    'insulation resistance testing': [
      {'title': 'Is insulation resistance ≥1.0 MΩ at 500V DC for all appliances?', 'desc': 'AS/NZS 3760 Table 4; measured between active+neutral shorted and earth'},
      {'title': 'Is the test instrument rated for the required test voltage and calibrated?', 'desc': 'AS/NZS 3760 s 4.5; insulation tester capable of 500V DC output'},
      {'title': 'Are heating elements or surge protectors tested with appropriate method?', 'desc': 'AS/NZS 3760 Appendix J; some equipment requires modified test procedure'},
      {'title': 'Is polarity confirmed on earthed appliances (active to active, neutral to neutral)?', 'desc': 'AS/NZS 3760 s 4.6; reversed polarity creates shock hazard on switched appliances'},
      {'title': 'Are test results recorded against each appliance serial number or asset tag?', 'desc': 'AS/NZS 3760 s 5; test log maintained for compliance auditing'},
    ],
    'rcd testing & functionality': [
      {'title': 'Are portable RCDs (safety switches) tested at the test button before each use?', 'desc': 'AS/NZS 3760 s 2.4; push-button test confirms mechanical operation'},
      {'title': 'Is the RCD tripping time ≤30ms at rated residual current (30mA)?', 'desc': 'AS/NZS 3760 Table 4; measured with calibrated RCD tester'},
      {'title': 'Are fixed RCDs on circuits supplying portable equipment tested every 6 months?', 'desc': 'AS/NZS 3760 Table 2; construction sites require 3-monthly testing'},
      {'title': 'Is the RCD trip current verified at the rated sensitivity (typically 30mA)?', 'desc': 'Ramp test confirms actual trip threshold; must trip between 50-100% of rated current'},
      {'title': 'Are non-tripping RCDs immediately replaced or the circuit taken out of service?', 'desc': 'AS/NZS 3000; RCD failure creates life-threatening shock risk on the entire circuit'},
    ],
    'tagging, records & compliance': [
      {'title': 'Is a durable tag affixed showing test date, retest date, technician, and result?', 'desc': 'AS/NZS 3760 s 5.2; colour-coded by testing interval; tag not to be removed'},
      {'title': 'Is the testing interval appropriate for the environment?', 'desc': 'AS/NZS 3760 Table 2; construction site = 3 months; factory = 6 months; office = 12 months'},
      {'title': 'Is a register of all tested equipment maintained and available for audit?', 'desc': 'AS/NZS 3760 s 5.3; includes asset ID, description, test results, and retest date'},
      {'title': 'Are personal items (phone chargers, fans, heaters) included in the testing regime?', 'desc': 'WHS Regs s 164; all electrical equipment used at the workplace must be tested'},
      {'title': 'Is the testing performed by a competent person (licensed electrician or trained tester)?', 'desc': 'AS/NZS 3760 s 1.4; competent person definition; state licensing requirements apply'},
    ],

    // AU7: Fire Systems Compliance (AS 1851)
    'fire extinguisher servicing': [
      {'title': 'Have all fire extinguishers been serviced at 6-monthly intervals per AS 1851?', 'desc': 'AS 1851 Table 15.2.2; 6-monthly routine service check by competent person'},
      {'title': 'Are extinguishers located within required travel distances (max 20m)?', 'desc': 'BCA/NCC E1.6; maximum travel distance to an extinguisher in any direction'},
      {'title': 'Are extinguisher ratings matched to the fire risks present (A, B, C, D, E, F)?', 'desc': 'AS 2444; extinguisher selection based on hazard classification of the area'},
      {'title': 'Are extinguishers mounted at correct height (handle 1.2m max from floor)?', 'desc': 'AS 2444 s 4.2; visible, accessible, and not obstructed; signage per AS 1319'},
      {'title': 'Are pressure gauge readings in the green zone and safety pins intact?', 'desc': 'AS 1851 s 15.2; physical condition check; tamper seal unbroken'},
    ],
    'hydrant & hose reel systems': [
      {'title': 'Are fire hydrant booster connections accessible and clearly identified?', 'desc': 'AS 1851 Table 12.2; booster assembly free from damage; caps in place'},
      {'title': 'Are internal hose reels functional with nozzle, guide arm, and full retraction?', 'desc': 'AS 1851 Table 13.2; monthly check: lay flat hose deployed and re-wound'},
      {'title': 'Has the hydrant system been flow-tested within the required interval?', 'desc': 'AS 1851 Table 12.3; annual flow and pressure test by accredited fire service provider'},
      {'title': 'Are hydrant cabinets and landing valves unobstructed and signposted?', 'desc': 'AS 1851 s 12; signage per AS 1319; clear zone maintained around hydrant point'},
      {'title': 'Are hose fittings compatible with the attending fire service (Storz or threaded)?', 'desc': 'AS 1851 Table 12.2; regional FRS requirements for coupling type'},
    ],
    'sprinkler & suppression systems': [
      {'title': 'Are sprinkler system control valves locked open and alarm connected?', 'desc': 'AS 1851 Table 4.2; weekly check: valves in correct position; tamper switch functional'},
      {'title': 'Is the sprinkler system supplied with adequate water pressure and flow?', 'desc': 'AS 1851 Table 4.3; annual flow test confirming design pressure at the most remote head'},
      {'title': 'Are sprinkler heads unobstructed with minimum 500mm clear space below deflectors?', 'desc': 'AS 2118; storage must not impede spray pattern; no shelving within clear zone'},
      {'title': 'Are spare sprinkler heads and a wrench stored on site per AS 2118?', 'desc': 'AS 2118 s 9.5; minimum 6 spare heads of each type and temperature rating installed'},
      {'title': 'Has the system been inspected by an accredited practitioner within required interval?', 'desc': 'AS 1851 Table 4.4; 5-year internal pipe inspection; 25-year system functionality assessment'},
    ],
    'detection, alarm & warning': [
      {'title': 'Is the fire detection and alarm system monitored by an accredited monitoring centre?', 'desc': 'AS 1851 Table 10.2; 24/7 monitoring; signal transmission within 90 seconds'},
      {'title': 'Are smoke detectors clean, unobstructed, and within their replacement lifecycle?', 'desc': 'AS 1851 Table 10.2; sensitivity testing required; photoelectric detectors replaced at 10 years'},
      {'title': 'Is the fire indicator panel (FIP) in normal operating condition with no active faults?', 'desc': 'AS 1851 s 10.2; daily check: no fault, isolate, or alarm conditions displayed'},
      {'title': 'Are manual call points accessible and clearly identified at each exit?', 'desc': 'AS 1670.1; red break-glass units at every exit and within 40m travel distance'},
      {'title': 'Are alarm notification appliances (bells, sounders, strobes) audible and visible throughout?', 'desc': 'AS 1670.4; minimum 65 dBA or 15 dBA above ambient; visual alert for hearing-impaired'},
    ],
    'emergency lighting & exit signs': [
      {'title': 'Are emergency/exit lights tested at the prescribed intervals per AS 2293?', 'desc': 'AS 2293.2; 6-monthly simulated failure test (90-minute duration); 6-yearly full discharge'},
      {'title': 'Are exit signs illuminated, visible, and correctly oriented towards exits?', 'desc': 'AS 2293.1; green running-man pictogram per AS/NZS 3862; visible from all points'},
      {'title': 'Do emergency lights illuminate the path of travel adequately (min 0.2 lux)?', 'desc': 'AS 2293.1 s 3; escape route luminaire spacing per design; minimum floor-level illuminance'},
      {'title': 'Are battery-backed luminaires showing healthy charge indicator (green LED)?', 'desc': 'AS 2293.2; units showing fault indicators must be repaired within 24 hours'},
      {'title': 'Are testing records maintained in a log book or electronic system?', 'desc': 'AS 2293.2 s 4; documented records of all testing and maintenance activities'},
    ],

    // AU8: Traffic Management Plan (WHS Regs s 314)
    'tmp documentation & approval': [
      {'title': 'Is a written Traffic Management Plan (TMP) prepared for the workplace?', 'desc': 'WHS Regs s 314; TMP required where there is a risk of collision between plant/vehicles and persons'},
      {'title': 'Has the TMP been prepared by a competent person familiar with the site?', 'desc': 'WHS Regs s 315; plan must address all foreseeable traffic hazards on the site'},
      {'title': 'Does the TMP include a site layout map showing roads, paths, and exclusion zones?', 'desc': 'Clear diagram of vehicle routes, pedestrian paths, delivery areas, and parking'},
      {'title': 'Has the TMP been communicated to all workers and visitors on site?', 'desc': 'WHS Act s 47; worker consultation; TMP displayed at site entry and in induction pack'},
      {'title': 'Is the TMP reviewed when site conditions, layout, or activities change?', 'desc': 'WHS Regs s 38; ongoing obligation to review and revise risk controls'},
    ],
    'pedestrian & vehicle separation': [
      {'title': 'Are pedestrian walkways physically separated from vehicle routes?', 'desc': 'Barriers, bollards, jersey kerbs, or equivalent physical separation measures'},
      {'title': 'Are designated crossing points provided where pedestrians must cross vehicle routes?', 'desc': 'Controlled crossings with give-way rules, rumble strips, or stop signs'},
      {'title': 'Are exclusion zones established around operating plant and vehicles?', 'desc': 'No-go zones during reversing, loading, and lifting operations; spotter required'},
      {'title': 'Are high-visibility clothing requirements enforced for all persons on site?', 'desc': 'AS/NZS 4602 Class D/N garments; site-specific colour requirements may apply'},
      {'title': 'Are vehicles fitted with reversing cameras or proximity detection systems?', 'desc': 'WHS COP Managing Risks of Plant; technology controls supplement procedural controls'},
    ],
    'signage & speed controls': [
      {'title': 'Are speed limit signs posted at site entry and throughout the site?', 'desc': 'Typical construction site limit: 10-15 km/h; speed bumps or chicanes to enforce'},
      {'title': 'Are regulatory and warning signs compliant with AS 1742 and clearly visible?', 'desc': 'AS 1742; standard road signs adapted for workplace; reflective and maintained'},
      {'title': 'Are temporary traffic control devices in good condition and correctly placed?', 'desc': 'Delineators, cones, barrier boards per AS 1742.3; not faded, damaged, or displaced'},
      {'title': 'Are flag/stop-go operators (traffic controllers) holding current TC tickets?', 'desc': 'WorkSafe/SafeWork accreditation required; blue card / white card depending on state'},
      {'title': 'Is adequate lighting provided for vehicle and pedestrian routes during low-light conditions?', 'desc': 'AS/NZS 1680 minimum illuminance levels; portable LED towers for temporary areas'},
    ],
    'plant & vehicle movement': [
      {'title': 'Are all plant and vehicles on site roadworthy and compliant with pre-start checks?', 'desc': 'WHS Regs s 213; daily pre-start inspection documented; defective plant not used'},
      {'title': 'Are operators of plant holding the required HRWL or competency tickets?', 'desc': 'WHS Regs s 82; licence verified before operation; site-specific induction completed'},
      {'title': 'Are loading and unloading zones designated with clear ground markings?', 'desc': 'Level ground, adequate space for vehicle manoeuvring, and exclusion during loading'},
      {'title': 'Are reversing operations controlled by a spotter or eliminated by one-way systems?', 'desc': 'WHS COP Managing Risks of Plant; reversing is the #1 cause of plant-pedestrian incidents'},
      {'title': 'Are delivery vehicles directed by a designated traffic controller on arrival?', 'desc': 'Gate control; visitor and delivery vehicles follow defined routes; no free-roaming'},
    ],
    'monitoring & review': [
      {'title': 'Are regular TMP compliance audits conducted by the site supervisor?', 'desc': 'Weekly walkthrough; observations recorded; non-compliance corrected immediately'},
      {'title': 'Are traffic incidents and near misses reported, investigated, and actioned?', 'desc': 'WHS Regs s 35; incident register maintained; root cause analysis for each event'},
      {'title': 'Are changes to site layout or activities reflected in an updated TMP?', 'desc': 'New deliveries, crane operations, or excavation may alter traffic routes'},
      {'title': 'Are all workers and subcontractors inducted on the current TMP at site induction?', 'desc': 'Induction register signed; refresher when TMP is significantly revised'},
      {'title': 'Is the TMP retained as a project record for compliance verification?', 'desc': 'Accessible for WorkSafe or principal contractor audit; retained per project duration'},
    ],

    // AU9: General Workplace WHS Audit (WHS Act 2011)
    'hazard identification & risk': [
      {'title': 'Has the PCBU identified all reasonably foreseeable hazards at the workplace?', 'desc': 'WHS Act s 17-19; systematic hazard identification covering all work activities'},
      {'title': 'Are risk assessments documented and current for identified hazards?', 'desc': 'WHS Regs s 34; written risk assessment required for specific high-risk activities'},
      {'title': 'Is the hierarchy of control applied to all risk controls?', 'desc': 'WHS Regs s 36; eliminate > substitute > isolate > engineer > admin > PPE'},
      {'title': 'Are Safe Work Method Statements (SWMS) prepared for all high-risk construction work?', 'desc': 'WHS Regs s 299; 19 categories of high-risk construction work require a SWMS'},
      {'title': 'Are hazard and risk registers maintained and regularly reviewed?', 'desc': 'WHS Regs s 38; review when control is no longer effective or new information becomes available'},
      {'title': 'Is PPE provided free of charge and maintained in good condition?', 'desc': 'WHS Regs s 44; PPE as a last resort; training in correct use and limitations'},
    ],
    'consultation & communication': [
      {'title': 'Are workers consulted on WHS matters that directly affect them?', 'desc': 'WHS Act s 47; consultation before changes to work, plant, substances, or procedures'},
      {'title': 'Is a Health and Safety Representative (HSR) elected where requested?', 'desc': 'WHS Act s 50; workers in a work group may request election of an HSR'},
      {'title': 'Is a Health and Safety Committee (HSC) established where required?', 'desc': 'WHS Act s 75; committee required if requested by HSR or 5+ workers'},
      {'title': 'Are WHS policies, procedures, and updates communicated effectively?', 'desc': 'Toolbox talks, notice boards, induction packs, and digital platforms'},
      {'title': 'Are multilingual or translated WHS materials provided where needed?', 'desc': 'WHS Act s 46; duty to ensure information is provided in formats workers can understand'},
    ],
    'incident reporting & investigation': [
      {'title': 'Are notifiable incidents reported to the regulator immediately?', 'desc': 'WHS Act s 35-39; death, serious injury/illness, or dangerous incident notified without delay'},
      {'title': 'Is the incident scene preserved until a regulator inspector releases it?', 'desc': 'WHS Act s 39; site preservation obligation after notifiable incident'},
      {'title': 'Is an incident investigation conducted for each notifiable event and near miss?', 'desc': 'Root cause analysis; corrective actions assigned with due dates and responsible persons'},
      {'title': 'Are incident and hazard report forms accessible to all workers?', 'desc': 'Paper or digital reporting; non-punitive reporting culture encouraged'},
      {'title': 'Is an incident register maintained and available for regulatory inspection?', 'desc': 'WHS Regs s 42; retained for at least 5 years; available to inspector on request'},
    ],
    'emergency preparedness': [
      {'title': 'Is a written emergency plan prepared for the workplace?', 'desc': 'WHS Regs s 43; covers evacuation, fire, chemical spill, medical emergency, and natural events'},
      {'title': 'Are emergency drills conducted at prescribed intervals?', 'desc': 'WHS Regs s 43(2); frequency appropriate to the risk; typically 6-monthly or annually'},
      {'title': 'Are first aid facilities and trained first aiders available on site?', 'desc': 'WHS Regs s 42; first aid assessment per SWA First Aid Code of Practice'},
      {'title': 'Is emergency contact information prominently displayed?', 'desc': '000, nearest hospital, fire service, poisons information centre, site emergency controller'},
      {'title': 'Are fire extinguishers, spill kits, and emergency equipment inspected regularly?', 'desc': 'AS 1851 for fire; spill kits restocked after use; AEDs checked monthly'},
    ],
    'whs documentation & records': [
      {'title': 'Is the WHS policy signed by senior management and communicated to workers?', 'desc': 'WHS Act s 17; PCBU must ensure health and safety of workers and others'},
      {'title': 'Are training records maintained for all WHS-related training provided?', 'desc': 'Name, date, content, trainer, assessment result; retained for employment duration + 5 years'},
      {'title': 'Are workplace inspection and audit reports retained and acted upon?', 'desc': 'Corrective action tracking; findings closed out within agreed timeframes'},
      {'title': 'Are SDS (Safety Data Sheets) current, accessible, and within the 5-year review period?', 'desc': 'WHS Regs s 344; SDS must be current version from manufacturer; available at point of use'},
      {'title': 'Is the WHS management system reviewed at planned intervals?', 'desc': 'ISO 45001 s 9.3 or equivalent; management review of objectives, KPIs, and system effectiveness'},
    ],

    // AU10: Hazardous Chemical Register & SDS (WHS Regs Ch 7)
    'chemical register & manifest': [
      {'title': 'Is a register of all hazardous chemicals at the workplace maintained?', 'desc': 'WHS Regs s 346; register lists every hazardous chemical used, handled, or stored'},
      {'title': 'Does the register include product name, quantity, and location for each chemical?', 'desc': 'Cross-referenced with SDS file; updated when new chemicals are introduced or removed'},
      {'title': 'Is a hazardous chemical manifest prepared where threshold quantities are exceeded?', 'desc': 'WHS Regs s 347; manifest required when aggregate quantities exceed Schedule 11 thresholds'},
      {'title': 'Has the manifest been provided to emergency services (fire brigade)?', 'desc': 'WHS Regs s 347(3); manifest available at or near the main entrance to the workplace'},
      {'title': 'Is the register reviewed and updated when chemicals change?', 'desc': 'WHS Regs s 346(2); ongoing obligation; out-of-date entries removed'},
    ],
    'sds availability & currency': [
      {'title': 'Is an SDS readily accessible for every hazardous chemical on the register?', 'desc': 'WHS Regs s 344; at the point of use and accessible to workers during working hours'},
      {'title': 'Are all SDS documents in the current GHS 16-section format?', 'desc': 'WHS Regs s 340; GHS format mandatory; not older than 5 years without verification'},
      {'title': 'Are SDS documents obtained from the manufacturer or importer before first use?', 'desc': 'WHS Regs s 341; PCBU must not use a hazardous chemical without a current SDS'},
      {'title': 'Are SDS accessible electronically with backup in case of system failure?', 'desc': 'Paper copies at point of use or offline-capable electronic system'},
      {'title': 'Are workers trained on how to locate and interpret SDS documents?', 'desc': 'WHS Regs s 39; understanding hazard statements, first aid, and PPE requirements'},
    ],
    'ghs labelling compliance': [
      {'title': 'Are all containers of hazardous chemicals labelled per GHS requirements?', 'desc': 'WHS Regs s 335; product name, signal word, hazard statements, pictograms, precautionary statements'},
      {'title': 'Are workplace labels applied to decanted or transferred chemicals?', 'desc': 'WHS Regs s 337; workplace label includes product name and hazard information'},
      {'title': 'Are labels legible, durable, and not obscured by dirt or damage?', 'desc': 'WHS Regs s 335(4); labels checked during routine inspections; replaced if deteriorated'},
      {'title': 'Are GHS pictograms displayed correctly on all primary and secondary containers?', 'desc': 'WHS Regs Schedule 9; red diamond border on white; minimum size requirements'},
      {'title': 'Are unlabelled containers excluded from the workplace?', 'desc': 'WHS Regs s 336; PCBU must not use a hazardous chemical from an unlabelled container'},
    ],
    'storage & segregation': [
      {'title': 'Are incompatible chemicals segregated according to dangerous goods classes?', 'desc': 'AS 3833 Storage and Handling of Mixed Classes; segregation table compliance'},
      {'title': 'Is the chemical storage area ventilated, bunded, and fire-protected?', 'desc': 'WHS Regs s 356; bunding to contain 110% of largest container; ventilation adequate for LEL'},
      {'title': 'Are flammable liquids stored in approved cabinets or stores?', 'desc': 'AS 1940; flammable liquid store construction and signage; max 250L in a single cabinet'},
      {'title': 'Are spill containment kits available near chemical storage and use areas?', 'desc': 'Appropriate absorbent material for the chemical type; PPE for spill responders'},
      {'title': 'Are HAZCHEM placards displayed on storage areas as required?', 'desc': 'AS 1216; placards show UN number, HAZCHEM code, and emergency contact'},
    ],
    'exposure monitoring & health surveillance': [
      {'title': 'Is exposure monitoring conducted for chemicals listed in Schedule 14?', 'desc': 'WHS Regs s 50; atmospheric monitoring to compare against Workplace Exposure Standards'},
      {'title': 'Are exposure monitoring records retained for at least 30 years?', 'desc': 'WHS Regs s 51; records of who was monitored, when, results, and controls in place'},
      {'title': 'Is health surveillance provided for workers exposed to Schedule 14 chemicals?', 'desc': 'WHS Regs s 368; health monitoring by a registered medical practitioner'},
      {'title': 'Are health monitoring reports provided to the PCBU and the worker?', 'desc': 'WHS Regs s 370; results communicated; concerns escalated to the regulator if needed'},
      {'title': 'Are engineering controls (LEV, enclosure, substitution) prioritised over PPE?', 'desc': 'WHS Regs s 36; hierarchy of control applied; PPE as last resort only'},
    ],

    // ════════════════════════════════════════════════════════════════
    // Canada OHS — Provincial Regulations
    // ════════════════════════════════════════════════════════════════

    // CA1: Workplace JHSC Inspection (OHSA s 9)
    'workplace hazard walkthrough': [
      {'title': 'Have all work areas been physically walked through and visually inspected?', 'desc': 'OHSA s 9(23); JHSC must inspect the physical condition of the workplace at least monthly'},
      {'title': 'Are all machinery, equipment, and tools in safe operating condition?', 'desc': 'OHSA s 25(1)(b); employer duty to maintain equipment in good condition'},
      {'title': 'Are chemical hazards identified and WHMIS controls in place?', 'desc': 'OHSA s 25(2)(a); SDS available, labels intact, worker training current'},
      {'title': 'Are ergonomic hazards (repetitive motions, awkward postures) identified?', 'desc': 'OHSA s 25(2)(h); duty to take every precaution reasonable for worker protection'},
      {'title': 'Are noise, temperature, and ventilation conditions acceptable?', 'desc': 'O. Reg. 851 s 127-131; maximum noise exposure 85 dBA TWA; adequate ventilation'},
    ],
    'housekeeping & organisation': [
      {'title': 'Are floors clean, dry, and free from trip hazards?', 'desc': 'O. Reg. 851 s 11; walking surfaces maintained to prevent slips, trips, and falls'},
      {'title': 'Are aisles and passageways clear and properly marked?', 'desc': 'O. Reg. 851 s 12; minimum 600mm clearance; yellow floor markings recommended'},
      {'title': 'Is waste disposed of regularly and receptacles not overflowing?', 'desc': 'OHSA s 25(2)(h); maintain orderly workplace; fire hazard from accumulated waste'},
      {'title': 'Are storage areas organised with heavy items at accessible heights?', 'desc': 'OHSA s 25(1)(b); racking and shelving maintained; stacking height limits observed'},
      {'title': 'Is lighting adequate for the tasks being performed?', 'desc': 'O. Reg. 851 s 21; minimum illumination levels per task type; no flickering or dark spots'},
    ],
    'emergency equipment & exits': [
      {'title': 'Are fire extinguishers in place, inspected monthly, and serviced annually?', 'desc': 'Ontario Fire Code s 6.2; correct type for hazards; travel distance within 23m'},
      {'title': 'Are emergency exits clearly marked, illuminated, and unobstructed?', 'desc': 'Ontario Fire Code s 2.7; exit signs illuminated; no locks or obstructions on exit routes'},
      {'title': 'Is the fire alarm system tested and functional?', 'desc': 'Ontario Fire Code s 6.3; annual inspection; monthly supervisory test of alarm stations'},
      {'title': 'Are first aid kits stocked per Regulation 1101 requirements?', 'desc': 'WSIB Reg. 1101; kit contents based on number of workers per shift'},
      {'title': 'Are eye wash stations and emergency showers functional and tested weekly?', 'desc': 'CSA Z358; 15 minutes of tepid flushing fluid; accessible within 10 seconds travel'},
    ],
    'ppe compliance & availability': [
      {'title': 'Is required PPE provided, maintained, and used by all workers?', 'desc': 'O. Reg. 851 s 79-87; hard hats, eye protection, hearing protection, safety footwear'},
      {'title': 'Are workers trained on the correct use, limitations, and care of PPE?', 'desc': 'OHSA s 25(2)(a); instruction and information provided on PPE requirements'},
      {'title': 'Is PPE inspected before each use and defective items replaced?', 'desc': 'O. Reg. 851 s 80; damaged or expired PPE must be removed from service'},
      {'title': 'Are safety glasses, goggles, or face shields used where eye hazards exist?', 'desc': 'O. Reg. 851 s 80; CSA Z94.3 certified eye and face protection'},
      {'title': 'Is respiratory protection provided and fit-tested where airborne hazards exist?', 'desc': 'O. Reg. 851 s 128; CSA Z94.4 respirator selection and use'},
    ],
    'documentation & jhsc records': [
      {'title': 'Are monthly workplace inspection reports documented and posted?', 'desc': 'OHSA s 9(23); report includes findings, recommendations, and targeted completion dates'},
      {'title': 'Are JHSC meeting minutes recorded and available to workers?', 'desc': 'OHSA s 9(22); minutes posted in the workplace; retained for at least 2 years'},
      {'title': 'Are JHSC recommendations tracked with employer responses documented?', 'desc': 'OHSA s 9(18)-(20); employer responds within 21 days; reasons given if not adopting'},
      {'title': 'Are training records maintained for all health and safety training?', 'desc': 'OHSA s 25(2)(a); name, date, content, instructor; retained for employment + 1 year'},
      {'title': 'Is the health and safety policy signed, dated, and posted in the workplace?', 'desc': 'OHSA s 25(2)(j); required for workplaces with 6+ workers; reviewed annually'},
    ],

    // CA2: Confined Space Entry (O. Reg. 632/05)
    'space hazard assessment': [
      {'title': 'Has each confined space been assessed to identify all actual and potential hazards?', 'desc': 'O. Reg. 632/05 s 5; atmospheric, engulfment, entrapment, physical, biological hazards'},
      {'title': 'Is the assessment documented and available at the point of entry?', 'desc': 'O. Reg. 632/05 s 5(3); assessment in writing; accessible to all entry personnel'},
      {'title': 'Has the assessment been reviewed when conditions change?', 'desc': 'O. Reg. 632/05 s 5(4); process changes, new chemicals, structural modifications'},
      {'title': 'Are all energy sources identified and procedures for isolation documented?', 'desc': 'O. Reg. 632/05 s 8; lockout of electrical, mechanical, hydraulic, pneumatic energy'},
      {'title': 'Has the space been classified as permit-required or non-permit?', 'desc': 'O. Reg. 632/05 s 1; classification determines level of controls'},
    ],
    'entry plan & permits': [
      {'title': 'Is a written entry plan prepared for each confined space entry?', 'desc': 'O. Reg. 632/05 s 6(1); plan covers hazard controls, equipment, communication, rescue'},
      {'title': 'Is an entry permit issued and posted at the point of entry?', 'desc': 'O. Reg. 632/05 s 10; permit valid for the duration specified; conditions verified'},
      {'title': 'Does the permit list isolation methods, ventilation, and PPE requirements?', 'desc': 'O. Reg. 632/05 s 10(2); specific to the space and the work being performed'},
      {'title': 'Is the entry plan coordinated with all affected employers on multi-employer sites?', 'desc': 'OHSA s 30; constructors and employers share responsibility for worker safety'},
      {'title': 'Are cancelled and completed permits retained and available for review?', 'desc': 'O. Reg. 632/05 s 10(5); permit records maintained for at least 1 year'},
    ],
    'atmospheric testing & monitoring': [
      {'title': 'Is the atmosphere tested before entry for O2, LEL, and toxic gases?', 'desc': 'O. Reg. 632/05 s 7(1); test from outside the space; O2 19.5-23%, LEL <25%'},
      {'title': 'Is continuous monitoring provided during entry?', 'desc': 'O. Reg. 632/05 s 7(2); alarm set points for immediate evacuation'},
      {'title': 'Is the gas detector calibrated and bump-tested before each use?', 'desc': 'Manufacturer recommendations; calibration records maintained; functional test daily'},
      {'title': 'Is mechanical ventilation provided to maintain safe atmospheric conditions?', 'desc': 'O. Reg. 632/05 s 8; forced-air ventilation documented on entry permit'},
      {'title': 'Are all test results recorded on the entry permit?', 'desc': 'Time, location, and readings documented; pre-entry and periodic readings'},
    ],
    'rescue procedures & equipment': [
      {'title': 'Is a written rescue procedure in place before entry begins?', 'desc': 'O. Reg. 632/05 s 11; non-entry rescue (retrieval system) as the first option'},
      {'title': 'Is rescue equipment (tripod, winch, harness, retrieval line) available at the entry?', 'desc': 'O. Reg. 632/05 s 11(3); equipment inspected and functionally tested before each entry'},
      {'title': 'Is a rescue team trained and equipped to perform entry rescue if required?', 'desc': 'O. Reg. 632/05 s 11(4); rescue trained in CPR, first aid, and SCBA use'},
      {'title': 'Can the rescue team reach the entrants within a timeframe suitable for the hazards?', 'desc': 'Response time appropriate to atmospheric conditions; typically within 3-5 minutes'},
      {'title': 'Has a rescue drill been conducted within the last 12 months?', 'desc': 'Annual practice; scenario-based drill documented with participants and outcomes'},
    ],
    'worker training & competency': [
      {'title': 'Are all entrants, attendants, and supervisors trained on confined space hazards?', 'desc': 'O. Reg. 632/05 s 4; training before first entry; covers specific hazards of the space'},
      {'title': 'Can workers demonstrate proper use of gas detectors and PPE?', 'desc': 'Hands-on competency assessment; verbal instruction alone is insufficient'},
      {'title': 'Is refresher training provided annually or when procedures change?', 'desc': 'O. Reg. 632/05 s 4(3); also required after incident or observed deficiency'},
      {'title': 'Are training records maintained with name, date, content, and trainer?', 'desc': 'Employer documentation; records available for MOL inspector review'},
      {'title': 'Are workers aware of their right to refuse unsafe work per OHSA s 43?', 'desc': 'OHSA s 43; no reprisal for exercising the right to refuse; investigation required'},
    ],

    // CA3: Fall Protection (O. Reg. 213/91 s 26)
    'guardrail systems & covers': [
      {'title': 'Are guardrails installed on all open edges where a worker could fall 2.4m or more?', 'desc': 'O. Reg. 213/91 s 26.1(1); 1070-1070mm top rail with mid-rail; toe board where required'},
      {'title': 'Are floor opening covers in place, secured, and clearly marked?', 'desc': 'O. Reg. 213/91 s 26.3(4); cover supports 2x expected load; marked "DANGER — OPENING"'},
      {'title': 'Are guardrails capable of resisting the required loads without failure?', 'desc': 'O. Reg. 213/91 s 26.3(1); top rail withstands 890N applied at any point'},
      {'title': 'Are guardrails provided at the edges of formwork and concrete structures?', 'desc': 'O. Reg. 213/91 s 26.1; includes ramps, runways, and temporary walkways'},
      {'title': 'Are roof edge guardrails extending 1070mm above the working surface?', 'desc': 'O. Reg. 213/91 s 26.3(2); continuous top rail with vertical intermediate members'},
    ],
    'travel restraint systems': [
      {'title': 'Are travel restraint systems configured to prevent the worker from reaching the edge?', 'desc': 'O. Reg. 213/91 s 26.4; lanyard length prevents approach to unprotected edge'},
      {'title': 'Are anchors for travel restraint capable of withstanding required loads?', 'desc': 'O. Reg. 213/91 s 26.4(3); adequate strength for the intended restraint force'},
      {'title': 'Are full-body harnesses used with travel restraint connections?', 'desc': 'CSA Z259.10; body belts acceptable only for travel restraint, not fall arrest'},
      {'title': 'Is the travel restraint lanyard the correct length for the site geometry?', 'desc': 'Length calculation: distance from anchor to edge minus harness D-ring extension'},
      {'title': 'Are travel restraint components inspected before each use?', 'desc': 'CSA Z259.10; check stitching, hardware, lanyard condition; remove damaged items'},
    ],
    'fall arrest systems & anchors': [
      {'title': 'Are fall arrest anchors capable of supporting a 3,600 lb (16 kN) static load?', 'desc': 'O. Reg. 213/91 s 26.7(4)(a); or designed by a professional engineer at 2x max arrest force'},
      {'title': 'Are CSA-certified full-body harnesses used as the body wear component?', 'desc': 'CSA Z259.10; body belts prohibited for fall arrest; check CSA certification label'},
      {'title': 'Is total fall distance calculated to ensure worker does not contact a lower level?', 'desc': 'O. Reg. 213/91 s 26.7(4)(b); lanyard + deceleration device + harness stretch + safety margin'},
      {'title': 'Are shock-absorbing lanyards or SRLs (self-retracting lifelines) properly rated?', 'desc': 'CSA Z259.11; max arrest force 8 kN (1,800 lbs); max deceleration distance 1.07m'},
      {'title': 'Are fall arrest components inspected by a competent person before each use?', 'desc': 'CSA Z259.10; document inspection; remove from service after a fall arrest event'},
    ],
    'safety nets & work positioning': [
      {'title': 'Are safety nets installed where fall arrest and guardrails are impracticable?', 'desc': 'O. Reg. 213/91 s 26.8; nets tested per CSA Z259.16; max opening size 150mm'},
      {'title': 'Are work positioning systems used only on surfaces with a slope ≤70°?', 'desc': 'O. Reg. 213/91 s 26.5; two independent means of support; backup fall arrest required'},
      {'title': 'Are control zones established at roofing edges when safety monitor is used?', 'desc': 'O. Reg. 213/91 s 26.6; control zone boundary 2m from edge; competent safety monitor'},
      {'title': 'Is fall arrest provided within the control zone for workers at the edge?', 'desc': 'O. Reg. 213/91 s 26.6(3); travel restraint or fall arrest within the control zone'},
      {'title': 'Are scaffolding platforms and work platforms equipped with proper edge protection?', 'desc': 'O. Reg. 213/91 s 26.1; guardrails or equivalent on all open sides of platforms'},
    ],
    'rescue plans & training': [
      {'title': 'Is a written rescue plan in place before work at height begins?', 'desc': 'O. Reg. 213/91 s 26.1(4); prompt rescue to prevent suspension trauma'},
      {'title': 'Have all workers received training on fall protection systems before first use?', 'desc': 'O. Reg. 213/91 s 26.2(1); covers hazards, equipment, inspection, and emergency procedures'},
      {'title': 'Is a competent person designated to inspect fall protection equipment?', 'desc': 'O. Reg. 213/91 s 26.1(2); competent in identification of hazards and corrective measures'},
      {'title': 'Are training records maintained for all fall protection training?', 'desc': 'OHSA s 25(2)(a); name, date, content, instructor; retained for employment period'},
      {'title': 'Are fall arrest systems removed from service after a fall arrest event and inspected?', 'desc': 'CSA Z259.10; post-fall inspection by manufacturer or competent person; replacement if in doubt'},
    ],

    // CA4: WHMIS 2015 Compliance Audit (HPR)
    'sds availability & 16-section format': [
      {'title': 'Is a current SDS available for every hazardous product in the workplace?', 'desc': 'HPR s 14; GHS 16-section format; obtained from supplier before first use'},
      {'title': 'Are SDS documents accessible to all workers during working hours?', 'desc': 'OHSA s 25(2)(a); electronic or physical; backup access in case of IT failure'},
      {'title': 'Are SDS documents not older than 3 years from the date of issue?', 'desc': 'HPR s 14(2); supplier must update SDS when significant new data becomes available'},
      {'title': 'Is a central SDS file maintained in a consistent and organised system?', 'desc': 'Alphabetical, by location, or by department; cross-referenced with chemical inventory'},
      {'title': 'Are SDS reviewed for newly purchased products before introduction to work area?', 'desc': 'HPR s 14; no hazardous product used without an SDS; supervisor verification'},
    ],
    'supplier label compliance': [
      {'title': 'Do supplier labels include all 6 required WHMIS 2015/GHS elements?', 'desc': 'HPR s 3; product identifier, signal word, hazard statements, pictograms, precautionary statements, supplier identifier'},
      {'title': 'Are GHS pictograms (red diamonds) displayed correctly and legibly?', 'desc': 'HPR s 3(1)(d); minimum size proportional to container; not obscured or faded'},
      {'title': 'Is the label in both English and French (federal requirement)?', 'desc': 'HPR s 3(6); bilingual labelling for products sold nationally in Canada'},
      {'title': 'Are incoming containers checked for proper labelling at receiving?', 'desc': 'Employer responsibility to verify labels; reject or re-label non-compliant containers'},
      {'title': 'Are label exemptions properly documented where applicable?', 'desc': 'HPR s 5; certain laboratory chemicals and research products may have reduced labelling'},
    ],
    'workplace label requirements': [
      {'title': 'Are workplace labels applied to all secondary and decanted containers?', 'desc': 'OHSA s 37; product name + safe handling information; reference to SDS'},
      {'title': 'Are workplace labels durable and legible for the expected container life?', 'desc': 'Labels resistant to the chemical contents; water-proof labels for aqueous products'},
      {'title': 'Are pipes, tanks, and process vessels containing hazardous products identified?', 'desc': 'OHSA s 37; placards, colour-coding, or other means of identification'},
      {'title': 'Are labels replaced when they become illegible or detach from the container?', 'desc': 'Routine inspection; damaged labels replaced immediately'},
      {'title': 'Are containers for immediate use exempted only under the correct conditions?', 'desc': 'Exemption: under control of the person who filled it; used during the same shift'},
    ],
    'worker education & training': [
      {'title': 'Have all workers received WHMIS 2015 education covering GHS changes?', 'desc': 'OHSA s 42; general WHMIS education + workplace-specific training'},
      {'title': 'Can workers identify GHS pictograms and explain what each means?', 'desc': 'Flammable, oxidizer, corrosive, acute toxicity, health hazard, environment, etc.'},
      {'title': 'Do workers know how to locate and read an SDS for products they handle?', 'desc': 'Section 2 (hazard identification), Section 4 (first aid), Section 8 (exposure controls/PPE)'},
      {'title': 'Is workplace-specific training provided for hazardous products in each area?', 'desc': 'OHSA s 42(1); training specific to the products and processes in their work area'},
      {'title': 'Are training records maintained and refresher training provided when needed?', 'desc': 'Annual refresher recommended; mandatory when new products introduced or procedures change'},
    ],
    'chemical inventory & records': [
      {'title': 'Is a complete inventory of all hazardous products maintained and current?', 'desc': 'Inventory cross-referenced with SDS file; includes quantity, location, and usage'},
      {'title': 'Are product quantities tracked to ensure safe storage limits are not exceeded?', 'desc': 'National Fire Code of Canada; maximum quantities per area based on hazard class'},
      {'title': 'Are incompatible chemicals stored separately per the SDS recommendations?', 'desc': 'Section 7 (handling and storage); Section 10 (stability and reactivity)'},
      {'title': 'Are outdated or unused hazardous products disposed of properly?', 'desc': 'Provincial environmental regulations; hazardous waste generator requirements'},
      {'title': 'Is the chemical inventory reviewed at least annually?', 'desc': 'Best practice; reconcile physical stock with register; remove products no longer on site'},
    ],

    // CA5: Construction Health & Safety (O. Reg. 213/91)
    'project registration & notice': [
      {'title': 'Has the project been registered with the Ministry of Labour where required?', 'desc': 'O. Reg. 213/91 s 6; notice of project for projects lasting >14 days and ≥5 workers'},
      {'title': 'Is the notice of project posted at the construction site?', 'desc': 'O. Reg. 213/91 s 6(3); visible at the main entrance; includes project details'},
      {'title': 'Is the constructor and employer contact information posted on site?', 'desc': 'O. Reg. 213/91 s 7; names and addresses of constructor and all employers'},
      {'title': 'Are all employers and subcontractors operating under a health and safety policy?', 'desc': 'OHSA s 25(2)(j); written policy required for workplaces with 6+ workers'},
      {'title': 'Is a qualified supervisor designated for the project per OHSA s 14?', 'desc': 'OHSA s 14; competent supervisor who understands the OHS Act and applicable regulations'},
    ],
    'site signage & access control': [
      {'title': 'Is the construction site fenced or barricaded to prevent unauthorized entry?', 'desc': 'O. Reg. 213/91 s 65; perimeter protection appropriate to the site hazards'},
      {'title': 'Are "Construction Area — Unauthorized Entry Prohibited" signs posted?', 'desc': 'O. Reg. 213/91 s 65(1); signage at all access points; bilingual where required'},
      {'title': 'Are PPE requirement signs posted at the site entrance?', 'desc': 'Hard hat, safety boots, high-visibility — mandatory PPE zones clearly identified'},
      {'title': 'Is a site visitor sign-in log maintained at the main entrance?', 'desc': 'Emergency muster accountability; construction induction verification'},
      {'title': 'Are delivery and vehicle entry points controlled and supervised?', 'desc': 'O. Reg. 213/91 s 67; traffic routes defined; flag persons where required'},
    ],
    'housekeeping & material storage': [
      {'title': 'Is the site maintained in an orderly condition to prevent hazards?', 'desc': 'O. Reg. 213/91 s 35; debris cleared daily; waste sorted and removed regularly'},
      {'title': 'Are materials stored to prevent tipping, falling, or collapsing?', 'desc': 'O. Reg. 213/91 s 36; stacking height limits; secure storage on sloped ground'},
      {'title': 'Are combustible materials separated from ignition sources?', 'desc': 'Ontario Fire Code s 5.6; no smoking signs posted; hot work permits where required'},
      {'title': 'Are access routes and egress paths kept clear at all times?', 'desc': 'O. Reg. 213/91 s 35(1); corridors, stairs, ladders, and emergency exits unobstructed'},
      {'title': 'Are waste chutes or enclosed containers used for disposal from upper levels?', 'desc': 'O. Reg. 213/91 s 37; no throwing or dropping of materials from height'},
    ],
    'protective equipment & clothing': [
      {'title': 'Are hard hats worn by all persons on the construction site?', 'desc': 'O. Reg. 213/91 s 22; CSA Z94.1 Type 1 or 2; exemptions only in fully enclosed offices'},
      {'title': 'Is safety footwear (CSA green triangle) worn at all times?', 'desc': 'O. Reg. 213/91 s 23; Grade 1 protective toe cap and sole puncture protection'},
      {'title': 'Are high-visibility garments worn when exposed to vehicular traffic?', 'desc': 'O. Reg. 213/91 s 69.1; fluorescent with retroreflective stripes; Class 2 or 3'},
      {'title': 'Is fall protection equipment worn and properly connected when working at height?', 'desc': 'O. Reg. 213/91 s 26; full-body harness, lanyard, and adequate anchor'},
      {'title': 'Is hearing protection provided where noise exceeds 85 dBA?', 'desc': 'O. Reg. 213/91 s 21.1; audiometric testing for exposed workers'},
    ],
    'scaffolding, trenching & electrical': [
      {'title': 'Are scaffolds erected, altered, and dismantled by competent persons?', 'desc': 'O. Reg. 213/91 s 125; design by professional engineer if >15m or unusual configuration'},
      {'title': 'Are excavations deeper than 1.2m shored, sloped, or supported?', 'desc': 'O. Reg. 213/91 s 228; support system designed for soil type; daily inspection'},
      {'title': 'Is underground locating completed (Ontario One Call) before excavation?', 'desc': 'O. Reg. 213/91 s 228.1; Ontario One Call 3 business days notice; hand dig within tolerance'},
      {'title': 'Are temporary electrical installations in compliance with the Electrical Safety Code?', 'desc': 'O. Reg. 213/91 s 181-195; GFCI protection on all temporary circuits, 6mA trip'},
      {'title': 'Are overhead and underground power lines identified and protective measures in place?', 'desc': 'O. Reg. 213/91 s 187-188; minimum clearance 3m from ≤750V; seek disconnection or protection'},
    ],

    // ════════════════════════════════════════════════════════════════
    // New Zealand HSWA 2015 — HSW Regulations 2016
    // ════════════════════════════════════════════════════════════════

    // NZ1: General Workplace HSWA Audit
    'pcbu duties & risk management': [
      {'title': 'Is the PCBU meeting their primary duty of care under HSWA s 36?', 'desc': 'HSWA s 36; so far as is reasonably practicable, ensure health and safety of workers'},
      {'title': 'Are all reasonably foreseeable hazards identified and assessed?', 'desc': 'HSW (GRWM) Regs s 5; systematic hazard identification across all work activities'},
      {'title': 'Are risks managed using the hierarchy of controls?', 'desc': 'HSW (GRWM) Regs s 6; eliminate > minimise (substitution, isolation, engineering, admin, PPE)'},
      {'title': 'Are risk assessments documented and reviewed when conditions change?', 'desc': 'HSW (GRWM) Regs s 9; review after incident, near miss, or new information'},
      {'title': 'Is the health and safety management system appropriate for the size and nature of work?', 'desc': 'HSWA s 36; PCBU to provide and maintain a safe work environment'},
    ],
    'worker engagement & participation': [
      {'title': 'Are workers engaged in decisions that affect their health and safety?', 'desc': 'HSWA s 58; must engage with workers and any health and safety representatives (HSRs)'},
      {'title': 'Are Health and Safety Representatives (HSRs) elected where requested?', 'desc': 'HSWA s 62; workers in a work group may request election of an HSR'},
      {'title': 'Is a Health and Safety Committee established where required?', 'desc': 'HSWA s 66; committee required if requested by HSR or 5+ workers; meets at least quarterly'},
      {'title': 'Are workers given reasonable opportunities to raise health and safety concerns?', 'desc': 'HSWA s 59; worker participation practices appropriate to the workplace'},
      {'title': 'Is protection from discrimination or disadvantage provided for raising concerns?', 'desc': 'HSWA s 89-101; no adverse conduct against workers exercising H&S rights'},
    ],
    'hazard identification & control': [
      {'title': 'Are workplace inspections conducted at regular intervals?', 'desc': 'Best practice: monthly; document findings, assign corrective actions, track closure'},
      {'title': 'Are chemical hazards identified and SDS maintained per HSW (Hazardous Substances) Regs?', 'desc': 'HSW (HS) Regulations 2017; inventory, labelling, SDS, and emergency procedures'},
      {'title': 'Are manual handling tasks assessed and controls applied?', 'desc': 'HSW (GRWM) Regs s 12; awkward postures, repetition, heavy loads, and vibration'},
      {'title': 'Are noise exposures assessed and controlled where workers are exposed >85 dBA?', 'desc': 'HSW (GRWM) Regs Part 2 Subpart 1; hearing protection and monitoring programme'},
      {'title': 'Is plant and equipment maintained in safe working condition?', 'desc': 'HSW (GRWM) Regs s 18-22; maintenance schedules, pre-start checks, operator competence'},
    ],
    'notifiable event procedures': [
      {'title': 'Are notifiable events (death, notifiable injury/illness, notifiable incident) reported to WorkSafe NZ?', 'desc': 'HSWA s 56; as soon as possible after becoming aware; online notification or 0800 030 040'},
      {'title': 'Is the scene of a notifiable event preserved until released by an inspector?', 'desc': 'HSWA s 57; no disturbance except to save life, prevent serious harm, or maintain essential services'},
      {'title': 'Are incident investigation procedures in place for all events and near misses?', 'desc': 'Root cause analysis; corrective actions assigned and tracked to completion'},
      {'title': 'Are records of notifiable events retained for at least 5 years?', 'desc': 'HSWA s 56; documentation available for WorkSafe NZ inspector review'},
      {'title': 'Are workers informed of investigation outcomes and corrective actions taken?', 'desc': 'HSWA s 58; engagement with workers on matters that directly affect them'},
    ],
    'emergency planning & preparedness': [
      {'title': 'Is a written emergency plan prepared and tested for the workplace?', 'desc': 'HSW (GRWM) Regs s 14; plan for emergencies that could arise from work activities'},
      {'title': 'Are evacuation procedures practised at prescribed intervals?', 'desc': 'Fire and Emergency NZ approval; typically 6-monthly; documented with attendance records'},
      {'title': 'Are first aid facilities and trained first aiders provided?', 'desc': 'HSW (GRWM) Regs s 15; first aid assessment per WorkSafe NZ guidelines'},
      {'title': 'Is emergency contact information displayed prominently?', 'desc': '111 (NZ emergency), nearest hospital, WorkSafe NZ, site emergency warden'},
      {'title': 'Are fire extinguishers and emergency equipment regularly inspected?', 'desc': 'NZS 4503; fire extinguisher maintenance per New Zealand Standards'},
    ],

    // NZ2: Working at Height (HSW Regs Part 3 Subpart 2)
    'height work risk assessment': [
      {'title': 'Has a risk assessment been completed for all work at height?', 'desc': 'HSW (GRWM) Regs s 21; identify fall hazards and determine appropriate controls'},
      {'title': 'Is work at height eliminated where reasonably practicable?', 'desc': 'HSW (GRWM) Regs s 22; do the work at ground level if possible'},
      {'title': 'Has the hierarchy of controls been applied: prevent falls before arresting falls?', 'desc': 'HSW (GRWM) Regs s 22(2); passive protection (guardrails) before active (harnesses)'},
      {'title': 'Is a site-specific safety plan documented for all height work activities?', 'desc': 'Covers methodology, equipment, training, rescue, and weather conditions'},
      {'title': 'Are weather conditions monitored and height work suspended in high winds?', 'desc': 'WorkSafe NZ guidance; wind speed thresholds for scaffolding, cranes, and EWPs'},
    ],
    'scaffolding & ewp compliance': [
      {'title': 'Are scaffolds designed, erected, and inspected by competent persons?', 'desc': 'HSW (GRWM) Regs s 22; scaffolder holding SCA (Scaffolding Certificate of Authority) for >5m'},
      {'title': 'Is scaffolding erected in accordance with NZS 3610 or specific design?', 'desc': 'NZS 3610: Aluminium, steel, and timber scaffolding; design documentation available'},
      {'title': 'Are EWPs (cherry pickers, scissor lifts) operated by trained operators?', 'desc': 'WPC (Unit Standard) or equivalent competency; daily pre-start checks documented'},
      {'title': 'Are scaffold tags current and inspection dates within prescribed intervals?', 'desc': 'Green tag = safe; red tag = do not use; inspection after alteration or adverse weather'},
      {'title': 'Is the scaffold loaded within its rated capacity at all times?', 'desc': 'Duty rating displayed; no stockpiling of materials beyond what is needed for immediate use'},
    ],
    'edge protection & barriers': [
      {'title': 'Are guardrails installed on all open edges where falls could occur?', 'desc': 'HSW (GRWM) Regs s 22; top rail 900-1100mm, mid-rail, and toe board'},
      {'title': 'Are penetrations and openings in floors covered or guarded?', 'desc': 'Covers secured against displacement; marked "DANGER — OPENING"; rated for expected loads'},
      {'title': 'Are fragile surfaces (skylights, roofing iron) identified and barricaded?', 'desc': 'WorkSafe NZ guidance; no walking on fragile surfaces; crawl boards or equivalent'},
      {'title': 'Are temporary barriers maintained throughout the work shift?', 'desc': 'Barriers not removed until hazard is eliminated; signage supplementing physical protection'},
      {'title': 'Are exclusion zones established below height work areas?', 'desc': 'Prevent persons below from being struck by falling objects; barricade and signage'},
    ],
    'harness systems & anchor points': [
      {'title': 'Are anchor points rated to NZS/AS 1891.4 and certified (minimum 15 kN)?', 'desc': 'Anchor point testing certificate current; installed by competent person'},
      {'title': 'Are full-body harnesses compliant with NZS/AS 1891.1 and inspected before use?', 'desc': 'Check stitching, webbing, D-rings, buckles; replace if damaged or past service life'},
      {'title': 'Is free-fall distance limited to 2 metres maximum?', 'desc': 'NZS/AS 1891.4; includes lanyard deployment + energy absorber + harness stretch + safety margin'},
      {'title': 'Are workers trained in correct fitting, use, and limitations of harness systems?', 'desc': 'Unit Standard 15757 or equivalent; hands-on demonstration required'},
      {'title': 'Are fall arrest equipment and lanyards replaced after any fall arrest event?', 'desc': 'NZS/AS 1891.1; post-fall inspection; components retired if deployed or suspected damage'},
    ],
    'rescue & emergency provisions': [
      {'title': 'Is a rescue plan documented and communicated to all workers at height?', 'desc': 'HSW (GRWM) Regs s 22; rescue achievable within 20 minutes of a fall arrest'},
      {'title': 'Is rescue equipment available on site and maintained in working order?', 'desc': 'Descent devices, rescue kits, stretchers; inspected before each use'},
      {'title': 'Have rescue personnel been trained and practised in the rescue procedures?', 'desc': 'Annual drill minimum; scenario-based training specific to each fall arrest scenario'},
      {'title': 'Is emergency services contact information displayed at the work area?', 'desc': '111, nearest hospital, site emergency warden name and contact number'},
      {'title': 'Are workers trained to recognise suspension trauma and provide first aid?', 'desc': 'Suspension intolerance can be fatal within 30 minutes; rapid rescue essential'},
    ],

    // NZ3: Confined Space Entry (HSW Regs Part 3 Subpart 3)
    'entry permit & risk assessment': [
      {'title': 'Has a confined space risk assessment been completed for the specific space?', 'desc': 'HSW (GRWM) Regs s 26; identify atmospheric, physical, and entrapment hazards'},
      {'title': 'Is a written entry permit issued before any person enters the space?', 'desc': 'HSW (GRWM) Regs s 27; permit specifies conditions, duration, entrants, and controls'},
      {'title': 'Has the space been isolated from all energy sources before entry?', 'desc': 'HSW (GRWM) Regs s 28; lockout/tagout, blanking, disconnection of piping'},
      {'title': 'Is the entry permit posted at the point of entry and visible to all workers?', 'desc': 'Permit displays acceptable atmospheric conditions and emergency contact information'},
      {'title': 'Are cancelled permits retained for record keeping and review?', 'desc': 'Best practice: retain for at least 5 years; available for WorkSafe NZ inspection'},
    ],
    'atmospheric monitoring': [
      {'title': 'Is the atmosphere tested before and continuously during entry?', 'desc': 'HSW (GRWM) Regs s 26(b); O2, LEL, CO, H2S minimum; additional gases per risk assessment'},
      {'title': 'Is the gas detector calibrated and bump-tested before each use?', 'desc': 'Manufacturer schedule; calibration certificate current; daily bump test with test gas'},
      {'title': 'Are alarm set points correctly configured (O2: 19.5-23%, LEL: <5%, CO: <25ppm)?', 'desc': 'WorkSafe NZ Workplace Exposure Standards; conservative alarm triggers for evacuation'},
      {'title': 'Is the atmosphere re-tested after any interruption in ventilation?', 'desc': 'Gas can accumulate rapidly; re-test from outside the space before re-entry'},
      {'title': 'Are atmospheric monitoring results recorded on the entry permit?', 'desc': 'Pre-entry readings, continuous monitoring data, and any alarm events documented'},
    ],
    'nz standby person & communication': [
      {'title': 'Is a standby person stationed at the entry point throughout the entry?', 'desc': 'HSW (GRWM) Regs s 29; standby must never enter the space; maintains communication'},
      {'title': 'Is reliable two-way communication maintained between entrant and standby?', 'desc': 'Voice, radio, visual signals, or tug-line depending on space configuration'},
      {'title': 'Can the standby person order immediate evacuation?', 'desc': 'HSW (GRWM) Regs s 29; authority to terminate entry when conditions deteriorate'},
      {'title': 'Is the standby person trained in emergency procedures and first aid?', 'desc': 'Emergency response, gas detector use, and summoning emergency services'},
      {'title': 'Are entry and exit times logged by the standby person?', 'desc': 'Accountability register: who is in the space, when they entered, and when they exited'},
    ],
    'ventilation & hazard controls': [
      {'title': 'Is mechanical ventilation provided to maintain safe atmospheric conditions?', 'desc': 'HSW (GRWM) Regs s 28; forced-air ventilation; minimum 20 air changes per hour'},
      {'title': 'Is the ventilation arrangement documented on the entry permit?', 'desc': 'Fan location, duct routing, and flow rate recorded; arrangement maintained during entry'},
      {'title': 'Are residual hazards (engulfment, entrapment, mechanical) controlled?', 'desc': 'HSW (GRWM) Regs s 26; isolation of pipes, valves, mixers, conveyors'},
      {'title': 'Is PPE appropriate for the identified hazards provided and used?', 'desc': 'RPE, chemical suits, harnesses as required; last resort after engineering controls'},
      {'title': 'Is the space cleaned or purged of hazardous residues before entry?', 'desc': 'Steam cleaning, water washing, or ventilation to remove residual chemicals'},
    ],
    'emergency & rescue procedures': [
      {'title': 'Is a written emergency and rescue procedure documented for the space?', 'desc': 'HSW (GRWM) Regs s 30; procedure communicated to all entry personnel'},
      {'title': 'Is non-entry rescue (retrieval system) the primary rescue method?', 'desc': 'Tripod, winch, and retrieval line attached to entrant; entry rescue as last resort'},
      {'title': 'Is rescue equipment available, inspected, and functional at the entry point?', 'desc': 'Harness, retrieval line, SCBA, first aid kit; tested before each entry'},
      {'title': 'Are rescue personnel trained and practised in the rescue procedures?', 'desc': 'Annual drill minimum; scenario-based; documented with participants'},
      {'title': 'Is emergency services contact information available at the entry point?', 'desc': '111 emergency; specific hazard information provided to responding services'},
    ],

    // NZ4: Asbestos Management (HSW Asbestos Regs 2016)
    'asbestos management plan': [
      {'title': 'Is an asbestos management plan in place for the workplace?', 'desc': 'HSW (Asbestos) Regs 2016 s 12; plan reviewed every 5 years or when circumstances change'},
      {'title': 'Does the plan identify all ACM and their condition at the workplace?', 'desc': 'HSW (Asbestos) Regs 2016 s 12(2)(a); location, type, condition, and risk assessment'},
      {'title': 'Are decisions about ACM management documented (leave, encapsulate, remove)?', 'desc': 'HSW (Asbestos) Regs 2016 s 12(2)(c); control measures for each ACM location'},
      {'title': 'Is the plan accessible to workers and other PCBUs at the workplace?', 'desc': 'HSW (Asbestos) Regs 2016 s 12(5); available on request; communicated during induction'},
      {'title': 'Is the plan reviewed after any asbestos incident or removal activity?', 'desc': 'HSW (Asbestos) Regs 2016 s 12(4); update register and management measures'},
    ],
    'asbestos register & identification': [
      {'title': 'Is an asbestos register maintained for the workplace?', 'desc': 'HSW (Asbestos) Regs 2016 s 10; register identifies location, type, and condition of ACM'},
      {'title': 'Has a competent person identified or assumed the presence of ACM?', 'desc': 'HSW (Asbestos) Regs 2016 s 10(2); unknown material assumed to contain asbestos'},
      {'title': 'Have samples been analysed by an IANZ-accredited laboratory?', 'desc': 'IANZ accreditation required for definitive asbestos identification in New Zealand'},
      {'title': 'Are ACM locations labelled with asbestos warning signs?', 'desc': 'HSW (Asbestos) Regs 2016 s 15; labels at or near ACM; size and format as prescribed'},
      {'title': 'Is the register provided to contractors and other PCBUs before work commences?', 'desc': 'HSW (Asbestos) Regs 2016 s 10(5); duty to share information about ACM at the workplace'},
    ],
    'exposure prevention controls': [
      {'title': 'Are control measures in place to prevent exposure of workers to airborne asbestos?', 'desc': 'HSW (Asbestos) Regs 2016 s 18; workplace exposure standard <0.1 f/mL TWA 8 hours'},
      {'title': 'Is undamaged non-friable ACM left in situ and monitored for condition changes?', 'desc': 'Management in place where removal is not immediately required; re-inspect schedule'},
      {'title': 'Is damaged or deteriorating ACM sealed, enclosed, or scheduled for removal?', 'desc': 'Friable or significantly deteriorated ACM must be removed by a licensed removalist'},
      {'title': 'Are workers informed about the presence of ACM before performing work that may disturb it?', 'desc': 'HSW (Asbestos) Regs 2016 s 11; duty to inform workers and other PCBUs'},
      {'title': 'Is asbestos awareness training provided to workers who may encounter ACM?', 'desc': 'Unit Standard 25045 or equivalent; covers identification, risks, and reporting'},
    ],
    'asbestos removal procedures': [
      {'title': 'Is asbestos removal carried out by a licensed asbestos removalist?', 'desc': 'HSW (Asbestos) Regs 2016 s 24; Class A for friable; Class B for non-friable >10m²'},
      {'title': 'Is a removal control plan prepared and approved before work commences?', 'desc': 'HSW (Asbestos) Regs 2016 s 30; plan covers methods, containment, decontamination'},
      {'title': 'Is the removal area enclosed and fitted with negative air pressure?', 'desc': 'HSW (Asbestos) Regs 2016 s 33; HEPA-filtered negative pressure for friable removal'},
      {'title': 'Is air monitoring conducted during and after removal by an independent assessor?', 'desc': 'HSW (Asbestos) Regs 2016 s 35; IANZ-accredited assessor; pre, during, and clearance'},
      {'title': 'Is asbestos waste double-bagged, labelled, and disposed of at a licensed facility?', 'desc': 'HSW (Asbestos) Regs 2016 s 39; tracked from site to disposal; manifest documentation'},
    ],
    'clearance & record keeping': [
      {'title': 'Is a clearance inspection conducted by an independent licensed assessor?', 'desc': 'HSW (Asbestos) Regs 2016 s 36; area must not be re-occupied until clearance certificate issued'},
      {'title': 'Is the clearance air monitoring result <0.01 f/mL before re-occupation?', 'desc': 'HSW (Asbestos) Regs 2016 s 36; clearance standard 10x lower than WES'},
      {'title': 'Is the asbestos register updated to reflect the removal?', 'desc': 'HSW (Asbestos) Regs 2016 s 10; register reflects current state of ACM at the workplace'},
      {'title': 'Are removal records retained for at least 40 years?', 'desc': 'HSW (Asbestos) Regs 2016 s 44; includes health monitoring records for exposed workers'},
      {'title': 'Are waste disposal certificates obtained and filed?', 'desc': 'Tracking from removal site to licensed landfill; disposal certificate retained with project records'},
    ],

    // NZ5: Construction Site Safety (HSW Regs Part 4)
    'principal contractor duties': [
      {'title': 'Is a principal contractor appointed for the construction work?', 'desc': 'HSWA s 35A; principal contractor has overall duty for health and safety coordination'},
      {'title': 'Has the principal contractor prepared a site-specific health and safety plan?', 'desc': 'HSW (GRWM) Regs Part 4; plan covers all activities, hazards, and control measures'},
      {'title': 'Are all subcontractors provided with the health and safety plan before work begins?', 'desc': 'Contractor induction; signed acknowledgement of H&S plan requirements'},
      {'title': 'Are regular site safety meetings held with all contractors?', 'desc': 'Weekly toolbox meetings; documented attendance and topics discussed'},
      {'title': 'Is the site H&S plan reviewed when new activities or contractors are introduced?', 'desc': 'Living document; updated as project scope or conditions change'},
    ],
    'site access & induction': [
      {'title': 'Have all workers completed a site-specific safety induction?', 'desc': 'HSW (GRWM) Regs Part 4; site hazards, emergency procedures, PPE requirements'},
      {'title': 'Is an induction register maintained with signed attendance records?', 'desc': 'Name, employer, date, induction provider; record retained for project duration'},
      {'title': 'Do workers hold current construction health and safety training (Site Safe passport)?', 'desc': 'Site Safe passport or equivalent; valid for 2 years; verified before site access'},
      {'title': 'Are visitors and delivery drivers inducted on site hazards before entering?', 'desc': 'Abbreviated induction covering emergency procedures and escort requirements'},
      {'title': 'Is site access gate controlled and attendance tracked?', 'desc': 'Card access, sign-in log, or digital system; muster list accurate for emergency evacuation'},
    ],
    'notifiable work compliance': [
      {'title': 'Has the work been assessed to determine if it is notifiable construction work?', 'desc': 'HSW (GRWM) Regs s 33; 13 categories including excavation >1.5m, demolition, asbestos'},
      {'title': 'Has written notification been given to WorkSafe NZ at least 24 hours before notifiable work?', 'desc': 'HSW (GRWM) Regs s 34; online notification preferred; include site address and work details'},
      {'title': 'Is notification documentation retained on site and available for inspection?', 'desc': 'WorkSafe NZ confirmation retained; posted at site office'},
      {'title': 'Are high-risk construction activities covered by task-specific safety plans?', 'desc': 'Detailed method statements for demolition, crane lifts, deep excavations, etc.'},
      {'title': 'Is a competent person supervising all notifiable construction work?', 'desc': 'HSWA s 36; supervision appropriate to the level of risk of the activity'},
    ],
    'excavation & demolition safety': [
      {'title': 'Are excavations deeper than 1.5m supported, battered, or benched?', 'desc': 'HSW (GRWM) Regs s 37; support system designed by a competent person'},
      {'title': 'Has underground service location been completed before excavation?', 'desc': 'BeforeUDig NZ; locate and mark services before any ground disturbance'},
      {'title': 'Is demolition work carried out under a written demolition plan prepared by a competent person?', 'desc': 'HSW (GRWM) Regs s 39; plan covers methodology, sequence, and structural assessment'},
      {'title': 'Are pre-demolition surveys completed for asbestos, lead, and other hazardous materials?', 'desc': 'HSW (Asbestos) Regs 2016; survey by a competent person before demolition begins'},
      {'title': 'Are exclusion zones established around demolition and excavation areas?', 'desc': 'Barricading and signage; no unauthorised entry; spotters for plant in exclusion zones'},
    ],
    'traffic management & signage': [
      {'title': 'Is a traffic management plan in place for the construction site?', 'desc': 'WorkSafe NZ COP Managing Risks of Plant; vehicle-pedestrian separation'},
      {'title': 'Are vehicle and pedestrian routes clearly marked and separated?', 'desc': 'Physical barriers, cones, and signage; controlled crossing points'},
      {'title': 'Is signage compliant with NZS and clearly visible?', 'desc': 'Speed limits, hazard warnings, PPE requirements, and directional signs'},
      {'title': 'Are all plant operators holding appropriate competency or licensing?', 'desc': 'NZQA Unit Standards; site-specific familiarisation completed'},
      {'title': 'Are temporary traffic management measures in place for public roads?', 'desc': 'NZTA Code of Practice for Temporary Traffic Management; TTM plan approved'},
    ],
  };
}
