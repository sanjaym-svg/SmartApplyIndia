import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';

/// AI-powered resume analysis and tailoring using Groq (free tier).
/// Uses Llama 3.3 70B for best quality with fallback to lighter models.
/// Free: 30 RPM, 14,400 requests/day — no credit card needed.
class AiService {
  static final AiService _instance = AiService._();
  factory AiService() => _instance;
  AiService._();

  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Models to try in order (best quality → fastest)
  static const List<String> _models = [
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
    'gemma2-9b-it',
  ];

  bool get isAvailable => Env.isGroqConfigured;

  /// Send a prompt to Groq and get the response text.
  /// [maxTokens] can be increased for longer responses like full resume tailoring.
  Future<String> _generate(String systemPrompt, String userPrompt, {int maxTokens = 3500}) async {
    if (!Env.isGroqConfigured) throw Exception('Groq API key not configured');

    for (int i = 0; i < _models.length; i++) {
      try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Env.groqApiKey}',
          },
          body: json.encode({
            'model': _models[i],
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': 0.3,
            'max_tokens': maxTokens,
            'response_format': {'type': 'json_object'},
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final content = data['choices']?[0]?['message']?['content'] ?? '';
          if (content.isEmpty) {
            print('WARNING: Groq returned empty content with model ${_models[i]}');
            if (i < _models.length - 1) continue;
            throw Exception('AI returned empty response');
          }
          return content;
        }

        // Rate limit or quota error — try next model
        if (response.statusCode == 429 || response.statusCode == 503) {
          print('Model ${_models[i]} rate limited (${response.statusCode}), trying next...');
          if (i < _models.length - 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
        }

        // Other errors
        print('Groq error response body: ${response.body}');
        final errorBody = json.decode(response.body);
        final errorMsg = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception('Groq API error (${response.statusCode}): $errorMsg');
      } catch (e) {
        if (e is Exception && e.toString().contains('Groq API error')) rethrow;
        if (i < _models.length - 1) {
          print('Model ${_models[i]} failed: $e, trying next...');
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('All models exhausted');
  }

  // ─── Deep Resume Analysis ────────────────────────────────

  Future<ResumeAnalysis> analyzeResume(String resumeText) async {
    if (!isAvailable) return ResumeAnalysis.empty();

    try {
      const systemPrompt = '''You are an expert ATS (Applicant Tracking System) resume analyzer for the Indian tech job market.
You must respond with valid JSON only. No markdown, no code blocks, no extra text.''';

      final userPrompt = '''Analyze this resume and return a JSON object with these exact fields:
{
  "skills": ["skill1", "skill2", ...],
  "experience_level": "fresher|junior|mid|senior",
  "years_experience": 0,
  "education": "degree and institution",
  "strengths": ["strength1", "strength2", ...],
  "weaknesses": ["weakness1", "weakness2", ...],
  "ats_score": 0, // must be a number between 0 and 100
  "summary": "2-3 sentence professional summary",
  "improvement_tips": ["tip1", "tip2", ...]
}

Resume text:
$resumeText''';

      final text = await _generate(systemPrompt, userPrompt);
      final data = json.decode(_extractJson(text)) as Map<String, dynamic>;

      return ResumeAnalysis(
        skills: List<String>.from(data['skills'] ?? []),
        experienceLevel: data['experience_level'] ?? 'fresher',
        yearsExperience: (data['years_experience'] ?? 0).toDouble(),
        education: data['education'] ?? '',
        strengths: List<String>.from(data['strengths'] ?? []),
        weaknesses: List<String>.from(data['weaknesses'] ?? []),
        atsScore: _normalizeScore((data['ats_score'] ?? 50).toDouble()),
        summary: data['summary'] ?? '',
        improvementTips: List<String>.from(data['improvement_tips'] ?? []),
      );
    } catch (e) {
      print('AI resume analysis error: $e');
      return ResumeAnalysis.empty();
    }
  }

  // ─── Job-Specific ATS Match ─────────────────────────────

  Future<JobMatchAnalysis> analyzeJobMatch(
    String resumeText,
    String jobTitle,
    String jobDescription,
  ) async {
    if (!isAvailable) return JobMatchAnalysis.empty();

    try {
      const systemPrompt = '''You are an expert ATS analyzer. Compare resumes against job postings.
You must respond with valid JSON only. No markdown, no code blocks, no extra text.''';

      final userPrompt = '''Compare this resume against the job posting and return a JSON analysis.

Resume:
$resumeText

Job Title: $jobTitle
Job Description: $jobDescription

Return a JSON object with:
{
  "match_score": 0, // must be a number between 0 and 100
  "matched_skills": ["skill1", "skill2", ...],
  "missing_skills": ["skill1", "skill2", ...],
  "keyword_matches": ["keyword1", "keyword2", ...],
  "recommendations": ["rec1", "rec2", ...],
  "fit_summary": "2-3 sentence summary of candidate fit"
}''';

      final text = await _generate(systemPrompt, userPrompt);
      final data = json.decode(_extractJson(text)) as Map<String, dynamic>;

      return JobMatchAnalysis(
        matchScore: _normalizeScore((data['match_score'] ?? 0).toDouble()),
        matchedSkills: List<String>.from(data['matched_skills'] ?? []),
        missingSkills: List<String>.from(data['missing_skills'] ?? []),
        keywordMatches: List<String>.from(data['keyword_matches'] ?? []),
        recommendations: List<String>.from(data['recommendations'] ?? []),
        fitSummary: data['fit_summary'] ?? '',
      );
    } catch (e) {
      print('AI job match error: $e');
      return JobMatchAnalysis.empty();
    }
  }

  // ─── Resume Tailoring ───────────────────────────────────

  Future<TailoredResume> tailorResume(
    String resumeText,
    String jobTitle,
    String jobDescription,
  ) async {
    if (!isAvailable) throw Exception('AI service not available. Check Groq API key.');

    const systemPrompt = '''You are an elite ATS resume optimization expert specializing in the Indian tech job market, with deep knowledge of recruiter behavior, ATS parsing systems, and hiring trends.

Your goal is to generate a COMPLETE, CLEAN, ATS-OPTIMIZED resume in STRICT PROFESSIONAL FORMAT.

STRICT RULES:
* Output MUST be valid JSON only
* No markdown, no explanations, no extra text
* Ensure the "full_tailored_resume" is CLEANLY FORMATTED and HUMAN-READABLE
* DO NOT generate long paragraphs
* DO NOT merge sections into a single paragraph
* Use proper line breaks (\\n) and spacing
* Use bullet points (- or *) for achievements and experience
* Keep each bullet point 1-2 lines max
* Use strong action verbs + measurable impact
* Ensure ATS-friendly structure

CRITICAL FORMATTING RULES FOR "full_tailored_resume":
* Each section MUST be clearly separated
* Use EXACT section headers (all uppercase):

NAME & CONTACT
PROFESSIONAL SUMMARY
SKILLS
EXPERIENCE
PROJECTS
EDUCATION
CERTIFICATIONS

* Follow this structure strictly:

NAME & CONTACT
Name
Location | Phone | Email | LinkedIn | GitHub

PROFESSIONAL SUMMARY
(3-4 concise lines)

SKILLS
* Categorized skills (Languages, Backend, AI/ML, Tools, Concepts)

EXPERIENCE
Role | Company | Duration
* Bullet point with impact
* Bullet point with metrics

PROJECTS
Project Name | Tech Stack
* What you built
* Impact / result

EDUCATION
Degree | College | Year
* CGPA / Score

CERTIFICATIONS
* Certification name''';

    final userPrompt = '''CONTENT STRATEGY:
* Align strictly with job description
* Add missing ATS keywords naturally
* Convert all weak statements -> achievement-based bullets
* Use Problem -> Action -> Result format
* Ensure resume is scannable in 6-10 seconds

Resume:
$resumeText

Job Title: $jobTitle
Job Description: $jobDescription

Return JSON:
{
  "tailored_summary": "Concise, high-impact summary",
  "tailored_skills": ["Relevant ATS skills"],
  "key_achievements": ["Impact-based achievements"],
  "keywords_to_add": ["Missing keywords"],
  "cover_letter_points": ["Strong talking points"],
  "overall_tips": "Actionable improvement tips",
  "full_tailored_resume": "STRICTLY formatted resume with proper sections, spacing, and bullet points. Must look like a real professional resume, not a paragraph."
}

FAIL-SAFE:
If formatting cannot be followed, return:
{"error": "formatting_failed"}''';

    try {
      final text = await _generate(systemPrompt, userPrompt, maxTokens: 4096);
      print('AI tailor raw response length: ${text.length}');

      final jsonStr = _extractJson(text);
      Map<String, dynamic> data;
      try {
        data = json.decode(jsonStr) as Map<String, dynamic>;
      } catch (jsonError) {
        print('JSON parse error: $jsonError');
        print('Raw JSON (first 500 chars): ${jsonStr.substring(0, jsonStr.length.clamp(0, 500))}');
        throw Exception('AI returned invalid JSON. Please try again.');
      }

      final result = TailoredResume(
        tailoredSummary: data['tailored_summary']?.toString() ?? '',
        tailoredSkills: List<String>.from(data['tailored_skills'] ?? []),
        keyAchievements: List<String>.from(data['key_achievements'] ?? []),
        keywordsToAdd: List<String>.from(data['keywords_to_add'] ?? []),
        coverLetterPoints: List<String>.from(data['cover_letter_points'] ?? []),
        overallTips: data['overall_tips']?.toString() ?? '',
        fullResumeText: data['full_tailored_resume']?.toString() ?? '',
      );

      if (result.isEmpty) {
        throw Exception('AI returned empty suggestions. Please try again.');
      }

      return result;
    } catch (e) {
      print('AI tailor error: $e');
      rethrow; // Let the UI handle and display the error
    }
  }

  // ─── Helper ─────────────────────────────────────────────

  String _extractJson(String text) {
    // Try code block first
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = codeBlockRegex.firstMatch(text);
    if (match != null) return match.group(1)!.trim();

    // Try raw JSON
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart >= 0 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }

    return text.trim();
  }

  double _normalizeScore(double parsedScore) {
    // If AI returned a score out of 10 instead of 100, scale it up
    if (parsedScore > 0 && parsedScore <= 10) {
      return parsedScore * 10;
    }
    return parsedScore;
  }
}

// ─── Data Models ────────────────────────────────────────────

class ResumeAnalysis {
  final List<String> skills;
  final String experienceLevel;
  final double yearsExperience;
  final String education;
  final List<String> strengths;
  final List<String> weaknesses;
  final double atsScore;
  final String summary;
  final List<String> improvementTips;

  const ResumeAnalysis({
    required this.skills,
    required this.experienceLevel,
    required this.yearsExperience,
    required this.education,
    required this.strengths,
    required this.weaknesses,
    required this.atsScore,
    required this.summary,
    required this.improvementTips,
  });

  factory ResumeAnalysis.empty() => const ResumeAnalysis(
    skills: [],
    experienceLevel: 'fresher',
    yearsExperience: 0,
    education: '',
    strengths: [],
    weaknesses: [],
    atsScore: 0,
    summary: '',
    improvementTips: [],
  );

  bool get isEmpty => skills.isEmpty && summary.isEmpty;
}

class JobMatchAnalysis {
  final double matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> keywordMatches;
  final List<String> recommendations;
  final String fitSummary;

  const JobMatchAnalysis({
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.keywordMatches,
    required this.recommendations,
    required this.fitSummary,
  });

  factory JobMatchAnalysis.empty() => const JobMatchAnalysis(
    matchScore: 0,
    matchedSkills: [],
    missingSkills: [],
    keywordMatches: [],
    recommendations: [],
    fitSummary: '',
  );

  bool get isEmpty => matchedSkills.isEmpty && fitSummary.isEmpty;
}

class TailoredResume {
  final String tailoredSummary;
  final List<String> tailoredSkills;
  final List<String> keyAchievements;
  final List<String> keywordsToAdd;
  final List<String> coverLetterPoints;
  final String overallTips;
  final String fullResumeText;

  const TailoredResume({
    required this.tailoredSummary,
    required this.tailoredSkills,
    required this.keyAchievements,
    required this.keywordsToAdd,
    required this.coverLetterPoints,
    required this.overallTips,
    required this.fullResumeText,
  });

  factory TailoredResume.empty() => const TailoredResume(
    tailoredSummary: '',
    tailoredSkills: [],
    keyAchievements: [],
    keywordsToAdd: [],
    coverLetterPoints: [],
    overallTips: '',
    fullResumeText: '',
  );

  bool get isEmpty => tailoredSummary.isEmpty;
}
