import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls DeepSeek API to generate AI-powered risk assessments.
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  // DeepSeek API key — loaded from environment or hardcoded for MVP.
  static const String _apiKey = 'sk-d05b8badc841440c92a94c0b545275f9';
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  /// Analyse an inspection and return a risk assessment.
  Future<RiskAssessment> analyseInspection({
    required String inspectionName,
    required String siteName,
    required Map<String, String> answers,
    required Map<String, String> notes,
    required List<String> sectionNames,
  }) async {
    final failCount = answers.values.where((v) => v == 'fail').length;
    final passCount = answers.values.where((v) => v == 'pass').length;
    final total = answers.length;

    final prompt = '''You are a health & safety risk assessment AI. Analyse the following inspection data and provide a JSON risk assessment.

Inspection: $inspectionName
Site: $siteName
Sections: ${sectionNames.join(', ')}
Total checks: $total
Passed: $passCount
Failed: $failCount
Failure rate: ${total > 0 ? ((failCount / total) * 100).toStringAsFixed(1) : 0}%

Failed items with notes:
${answers.entries.where((e) => e.value == 'fail').map((e) => '- ${e.key}: ${notes[e.key] ?? "No note provided"}').join('\n')}

Respond with ONLY valid JSON in this exact format:
{
  "riskLevel": "low|medium|high|critical",
  "score": 0-100,
  "summary": "2-3 sentence overall assessment",
  "keyFindings": ["finding 1", "finding 2", "finding 3"],
  "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"],
  "priorityAreas": ["area 1", "area 2"]
}''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final content =
            body['choices'][0]['message']['content'] as String;
        // Extract JSON from response (may have markdown wrapping)
        final jsonStr = _extractJson(content);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        return RiskAssessment.fromJson(parsed);
      }
    } catch (_) {}

    // Fallback: compute locally based on failure rate
    return _localAssessment(
      failCount: failCount,
      passCount: passCount,
      total: total,
    );
  }

  String _extractJson(String content) {
    // Remove markdown code fences if present
    var cleaned = content.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```json?\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
    }
    return cleaned.trim();
  }

  RiskAssessment _localAssessment({
    required int failCount,
    required int passCount,
    required int total,
  }) {
    final failRate = total > 0 ? failCount / total : 0.0;
    final score = total > 0 ? ((passCount / total) * 100).round() : 100;

    RiskLevel level;
    String summary;
    if (failRate >= 0.5) {
      level = RiskLevel.critical;
      summary =
          'Critical risk level detected. More than half of all checks have failed. Immediate corrective action is required before operations continue.';
    } else if (failRate >= 0.25) {
      level = RiskLevel.high;
      summary =
          'High risk level identified. Significant number of failures require urgent attention and a formal corrective action plan.';
    } else if (failRate >= 0.1) {
      level = RiskLevel.medium;
      summary =
          'Moderate risk level. Some areas need improvement. Schedule corrective actions for failed items within the next review period.';
    } else {
      level = RiskLevel.low;
      summary =
          'Low risk level. The site is broadly compliant with minor issues to address during routine maintenance.';
    }

    return RiskAssessment(
      riskLevel: level,
      score: score,
      summary: summary,
      keyFindings: failCount > 0
          ? ['$failCount check(s) failed out of $total total']
          : ['All checks passed'],
      recommendations: failCount > 0
          ? ['Address failed items within 7 days', 'Schedule follow-up inspection']
          : ['Maintain current standards', 'Continue regular inspection schedule'],
      priorityAreas: [],
    );
  }
}

enum RiskLevel { low, medium, high, critical }

class RiskAssessment {
  final RiskLevel riskLevel;
  final int score;
  final String summary;
  final List<String> keyFindings;
  final List<String> recommendations;
  final List<String> priorityAreas;

  RiskAssessment({
    required this.riskLevel,
    required this.score,
    required this.summary,
    required this.keyFindings,
    required this.recommendations,
    required this.priorityAreas,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    final levelStr = (json['riskLevel'] as String? ?? 'medium').toLowerCase();
    RiskLevel level;
    switch (levelStr) {
      case 'low':
        level = RiskLevel.low;
        break;
      case 'high':
        level = RiskLevel.high;
        break;
      case 'critical':
        level = RiskLevel.critical;
        break;
      default:
        level = RiskLevel.medium;
    }
    return RiskAssessment(
      riskLevel: level,
      score: (json['score'] as num?)?.toInt() ?? 50,
      summary: json['summary'] as String? ?? '',
      keyFindings: (json['keyFindings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priorityAreas: (json['priorityAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get riskLevelLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }
}
