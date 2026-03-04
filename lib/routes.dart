import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/inspection_detail_screen.dart';
import 'screens/section_detail_screen.dart';
import 'screens/inspection_summary_screen.dart';
import 'screens/inspection_complete_screen.dart';
import 'screens/templates_screen.dart';
import 'screens/site_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/about_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/corrective_actions_screen.dart';
import 'screens/team_screen.dart';
import 'screens/schedules_screen.dart';
import 'screens/template_builder_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/compliance_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/join_org_screen.dart';
import 'widgets/app_shell.dart';
import 'models/inspection.dart';
import 'models/site.dart';
import 'services/feature_gate.dart';

class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String inspections = '/inspections';
  static const String inspectionDetail = '/inspection-detail';
  static const String sectionDetail = '/section-detail';
  static const String inspectionSummary = '/inspection-summary';
  static const String inspectionComplete = '/inspection-complete';
  static const String templates = '/templates';
  static const String sites = '/sites';
  static const String siteDetail = '/site-detail';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String about = '/about';
  static const String createAccount = '/create-account';
  static const String onboarding = '/onboarding';
  static const String analytics = '/analytics';
  static const String correctiveActions = '/corrective-actions';
  static const String team = '/team';
  static const String schedules = '/schedules';
  static const String templateBuilder = '/template-builder';
  static const String qrScanner = '/qr-scanner';
  static const String compliance = '/compliance';
  static const String paywall = '/paywall';
  static const String joinOrg = '/join-org';

  static Route<dynamic> _fallback() =>
      MaterialPageRoute(builder: (_) => const HomeScreen());

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case inspections:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(initialTab: 1));
      case inspectionDetail:
        final inspection = routeSettings.arguments as Inspection?;
        if (inspection == null) return _fallback();
        return MaterialPageRoute(
          builder: (_) => InspectionDetailScreen(inspection: inspection),
        );
      case sectionDetail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        if (args == null) return _fallback();
        return MaterialPageRoute(
          builder: (_) => SectionDetailScreen(
            section: args['section'] as InspectionSection,
            inspectionName: args['inspectionName'] as String,
            inspection: args['inspection'] as Inspection?,
          ),
        );
      case inspectionSummary:
        final inspection = routeSettings.arguments as Inspection?;
        if (inspection == null) return _fallback();
        return MaterialPageRoute(
          builder: (_) => InspectionSummaryScreen(inspection: inspection),
        );
      case inspectionComplete:
        final inspection = routeSettings.arguments as Inspection?;
        if (inspection == null) return _fallback();
        return MaterialPageRoute(
          builder: (_) => InspectionCompleteScreen(inspection: inspection),
        );
      case templates:
        return MaterialPageRoute(builder: (_) => const TemplatesScreen());
      case sites:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(initialTab: 2));
      case siteDetail:
        final site = routeSettings.arguments as Site?;
        if (site == null) return _fallback();
        return MaterialPageRoute(
          builder: (_) => SiteDetailScreen(site: site),
        );
      case settings:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(initialTab: 3));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case correctiveActions:
        final inspectionId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CorrectiveActionsScreen(inspectionId: inspectionId),
        );
      case team:
        return MaterialPageRoute(builder: (_) => const TeamScreen());
      case schedules:
        return MaterialPageRoute(builder: (_) => const SchedulesScreen());
      case templateBuilder:
        return MaterialPageRoute(builder: (_) => const TemplateBuilderScreen());
      case qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());
      case compliance:
        return MaterialPageRoute(builder: (_) => const ComplianceScreen());
      case paywall:
        final feature = routeSettings.arguments as Feature?;
        return MaterialPageRoute(
          builder: (_) => PaywallScreen(triggerFeature: feature),
        );
      case joinOrg:
        final invite = routeSettings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          builder: (_) => JoinOrgScreen(pendingInvite: invite),
        );
      default:
        return _fallback();
    }
  }
}
