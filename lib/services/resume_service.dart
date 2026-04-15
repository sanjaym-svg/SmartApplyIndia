import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'ats_engine.dart';
import 'ai_service.dart';
import 'storage_service.dart';
import '../models/job_model.dart';

/// Manages resume data, text extraction, AI-powered analysis,
/// and ATS score computation. Persists resume text locally.
class ResumeService extends ChangeNotifier {
  static final ResumeService _instance = ResumeService._();
  factory ResumeService() => _instance;
  ResumeService._() {
    _restoreResume();
  }

  final AtsEngine _atsEngine = AtsEngine();
  final AiService _ai = AiService();
  final StorageService _storage = StorageService();

  String _resumeText = '';
  String _fileName = '';
  List<String> _extractedSkills = [];
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  String? _error;

  // AI analysis results
  ResumeAnalysis? _aiAnalysis;
  final Map<String, JobMatchAnalysis> _jobMatchCache = {};
  final Map<String, TailoredResume> _tailoredCache = {};

  // ─── Getters ──────────────────────────────────────────

  String get resumeText => _resumeText;
  String get fileName => _fileName;
  bool get hasResume => _resumeText.isNotEmpty;
  List<String> get extractedSkills => _extractedSkills;
  bool get isProcessing => _isProcessing;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  bool get hasAiAnalysis => _aiAnalysis != null && !_aiAnalysis!.isEmpty;
  ResumeAnalysis? get aiAnalysis => _aiAnalysis;
  bool get isAiAvailable => _ai.isAvailable;

  double get atsScore {
    if (_aiAnalysis != null && !_aiAnalysis!.isEmpty) {
      return _aiAnalysis!.atsScore;
    }
    return (_extractedSkills.length * 6.0).clamp(0, 100);
  }

  // ─── Restore from Storage ─────────────────────────────

  void _restoreResume() {
    if (!_storage.isReady) return;
    final savedText = _storage.savedResumeText;
    final savedName = _storage.savedResumeFileName;
    if (savedText != null && savedText.isNotEmpty) {
      _resumeText = savedText;
      _fileName = savedName ?? 'Restored Resume';
      _extractSkillsLocal();
    }
  }

  // ─── Resume Text Input ────────────────────────────────

  /// Set resume text directly (paste mode)
  void setResumeText(String text) {
    _resumeText = text.trim();
    _fileName = 'Pasted Resume';
    _extractSkillsLocal();
    _error = null;
    _aiAnalysis = null;
    _jobMatchCache.clear();
    _tailoredCache.clear();
    notifyListeners();
    _persistResume();
    _runAiAnalysis();
  }

  /// Set resume from file selection — now with proper PDF parsing
  void setResumeFile({
    required String fileName,
    required Uint8List bytes,
  }) {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    _fileName = fileName;

    try {
      final lowerName = fileName.toLowerCase();
      if (lowerName.endsWith('.pdf')) {
        // ── Proper PDF text extraction via Syncfusion ──
        _resumeText = _extractTextFromPdf(bytes);
        if (_resumeText.trim().isEmpty) {
          _error = 'PDF has no extractable text (image-based). Please paste your resume text instead.';
        }
      } else {
        // Plain text / doc files
        final text = utf8.decode(bytes, allowMalformed: true);
        if (_isReadableText(text)) {
          _resumeText = _cleanExtractedText(text);
        } else {
          _resumeText = '';
          _error = 'Could not read this file. Please paste your resume text instead.';
        }
      }
    } catch (e) {
      print('File parse error: $e');
      _error = 'Error reading file: ${e.toString().split('\n').first}';
    }

    if (_resumeText.isNotEmpty) {
      _extractSkillsLocal();
      _aiAnalysis = null;
      _jobMatchCache.clear();
      _tailoredCache.clear();
      if (_error != null && _resumeText.length > 50) {
        _error = null; // Clear error if we got good text
      }
    }

    _isProcessing = false;
    notifyListeners();

    if (_resumeText.isNotEmpty) {
      _persistResume();
      _runAiAnalysis();
    }
  }

  /// Clear resume data
  void clearResume() {
    _resumeText = '';
    _fileName = '';
    _extractedSkills = [];
    _error = null;
    _aiAnalysis = null;
    _jobMatchCache.clear();
    _tailoredCache.clear();
    _storage.clearResume();
    notifyListeners();
  }

  /// Persist resume to local storage
  Future<void> _persistResume() async {
    if (_resumeText.isNotEmpty) {
      await _storage.saveResume(_resumeText, _fileName);
    }
  }

  // ─── PDF Text Extraction ──────────────────────────────

  /// Extract all text from a PDF using Syncfusion
  String _extractTextFromPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    // Extract text from all pages at once
    final String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return _cleanExtractedText(text);
  }

  // ─── AI-Powered Analysis ──────────────────────────────

  /// Run deep AI analysis on resume (called automatically)
  Future<void> _runAiAnalysis() async {
    if (!_ai.isAvailable || _resumeText.isEmpty) return;

    _isAnalyzing = true;
    notifyListeners();

    try {
      _aiAnalysis = await _ai.analyzeResume(_resumeText);
      if (_aiAnalysis != null && !_aiAnalysis!.isEmpty) {
        _extractedSkills = _aiAnalysis!.skills;
      }
      _error = null;
    } catch (e) {
      print('AI analysis failed: $e');
    }

    _isAnalyzing = false;
    notifyListeners();
  }

  /// Force re-analyze with AI
  Future<void> reanalyze() async {
    await _runAiAnalysis();
  }

  /// Get AI-powered job match analysis (cached)
  Future<JobMatchAnalysis> getAiJobMatch(Job job) async {
    if (_jobMatchCache.containsKey(job.id)) {
      return _jobMatchCache[job.id]!;
    }

    if (!_ai.isAvailable || _resumeText.isEmpty) {
      return JobMatchAnalysis.empty();
    }

    final analysis = await _ai.analyzeJobMatch(
      _resumeText,
      job.title,
      job.description,
    );

    _jobMatchCache[job.id] = analysis;
    return analysis;
  }

  /// Get AI-tailored resume for a specific job (cached)
  Future<TailoredResume> getTailoredResume(Job job) async {
    if (_tailoredCache.containsKey(job.id)) {
      return _tailoredCache[job.id]!;
    }

    if (_resumeText.isEmpty) {
      throw Exception('No resume loaded. Please upload your resume first.');
    }

    if (!_ai.isAvailable) {
      throw Exception('AI service not available. Check your API key configuration.');
    }

    final tailored = await _ai.tailorResume(
      _resumeText,
      job.title,
      job.description,
    );

    _tailoredCache[job.id] = tailored;
    return tailored;
  }

  /// Clear cached tailor result for a specific job (for retry)
  void clearTailorCache(String jobId) {
    _tailoredCache.remove(jobId);
  }

  // ─── Local Skill Extraction (Fallback) ─────────────────

  void _extractSkillsLocal() {
    const knownSkills = [
      'Flutter', 'Dart', 'React', 'Angular', 'Vue.js', 'Node.js',
      'Python', 'Java', 'Kotlin', 'Swift', 'JavaScript', 'TypeScript',
      'Go', 'Rust', 'C++', 'C#', 'PHP', 'Ruby',
      'Django', 'Flask', 'Spring Boot', 'Express.js', 'FastAPI',
      'AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes', 'DevOps', 'CI/CD',
      'Machine Learning', 'Deep Learning', 'TensorFlow', 'PyTorch', 'NLP',
      'SQL', 'MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Firebase',
      'REST API', 'GraphQL', 'Microservices',
      'Git', 'GitHub', 'Agile', 'Scrum', 'Jira',
      'HTML', 'CSS', 'Sass', 'Tailwind', 'Bootstrap',
      'Android', 'iOS', 'React Native', 'Xamarin',
      'Data Science', 'Tableau', 'Power BI', 'Excel',
      'Linux', 'Bash', 'Terraform', 'Ansible',
      'Figma', 'UI/UX', 'Supabase', 'Next.js',
    ];

    final resumeLower = _resumeText.toLowerCase();
    _extractedSkills = knownSkills
        .where((skill) => resumeLower.contains(skill.toLowerCase()))
        .toList();
  }

  // ─── ATS Scoring (TF-IDF fallback) ────────────────────

  double getJobScore(Job job) {
    if (!hasResume) return 0;
    return _atsEngine.matchScore(_resumeText, '${job.title} ${job.description}');
  }

  List<Job> scoreJobs(List<Job> jobs) {
    if (!hasResume) return jobs;

    final jobMaps = jobs.map((j) => {
      'id': j.id,
      'description': '${j.title} ${j.description}',
    }).toList();

    final scores = _atsEngine.batchMatchScores(_resumeText, jobMaps);

    return jobs.map((j) {
      final score = scores[j.id] ?? 0;
      return j.copyWith(matchScore: score);
    }).toList();
  }

  MatchAnalysis analyzeJob(Job job) {
    return _atsEngine.analyzeMatch(
      _resumeText,
      '${job.title} ${job.description}',
    );
  }

  // ─── Helpers ──────────────────────────────────────────

  bool _isReadableText(String text) {
    if (text.length < 20) return false;
    int printable = 0;
    final sample = text.substring(0, (text.length).clamp(0, 500));
    for (final c in sample.codeUnits) {
      if ((c >= 32 && c <= 126) || c == 10 || c == 13 || c == 9) {
        printable++;
      }
    }
    return printable / sample.length > 0.8;
  }

  String _cleanExtractedText(String text) {
    return text
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
