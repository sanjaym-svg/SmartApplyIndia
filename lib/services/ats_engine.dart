import 'dart:math';

/// TF-IDF + Cosine Similarity ATS matching engine.
/// Compares resume text against job descriptions to produce a 0-100 match score.
class AtsEngine {
  static final AtsEngine _instance = AtsEngine._();
  factory AtsEngine() => _instance;
  AtsEngine._();

  /// Common English stop words to ignore
  static const _stopWords = <String>{
    'a', 'an', 'the', 'and', 'or', 'but', 'is', 'are', 'was', 'were',
    'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did',
    'will', 'would', 'could', 'should', 'may', 'might', 'shall', 'can',
    'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as',
    'into', 'through', 'during', 'before', 'after', 'above', 'below',
    'between', 'out', 'off', 'over', 'under', 'again', 'further', 'then',
    'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any',
    'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no',
    'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very',
    'just', 'because', 'about', 'up', 'it', 'its', 'this', 'that',
    'these', 'those', 'i', 'me', 'my', 'we', 'our', 'you', 'your',
    'he', 'she', 'they', 'them', 'what', 'which', 'who', 'whom',
    'am', 'if', 'also', 'etc', 'per', 'using', 'able', 'work', 'working',
    'looking', 'well', 'role', 'experience', 'years', 'year',
  };

  /// Key tech skills/keywords that carry extra weight in matching
  static const _techBoostWords = <String>{
    'flutter', 'dart', 'react', 'angular', 'vue', 'node', 'nodejs',
    'python', 'java', 'kotlin', 'swift', 'javascript', 'typescript',
    'go', 'golang', 'rust', 'c++', 'cpp', 'csharp', 'c#', 'php', 'ruby',
    'django', 'flask', 'spring', 'express', 'fastapi', 'rails',
    'aws', 'azure', 'gcp', 'docker', 'kubernetes', 'k8s', 'devops', 'cicd',
    'ml', 'ai', 'tensorflow', 'pytorch', 'nlp', 'opencv',
    'sql', 'mysql', 'postgresql', 'postgres', 'mongodb', 'redis', 'firebase',
    'rest', 'restful', 'graphql', 'api', 'apis', 'microservices',
    'git', 'github', 'gitlab', 'agile', 'scrum', 'jira',
    'html', 'css', 'sass', 'tailwind', 'bootstrap',
    'android', 'ios', 'mobile', 'frontend', 'backend', 'fullstack',
    'data', 'analytics', 'tableau', 'powerbi', 'excel',
    'linux', 'unix', 'bash', 'shell', 'terraform', 'ansible',
    'figma', 'sketch', 'ui', 'ux', 'design',
    'supabase', 'nextjs', 'nuxt', 'svelte', 'remix',
  };

  // ─── Tokenization ──────────────────────────────────────

  /// Tokenize text into meaningful words
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9#+.\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1 && !_stopWords.contains(w))
        .toList();
  }

  // ─── TF (Term Frequency) ──────────────────────────────

  /// Compute term frequency: count of each word / total words
  Map<String, double> _termFrequency(List<String> tokens) {
    final counts = <String, int>{};
    for (final t in tokens) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    final total = tokens.length.toDouble();
    return counts.map((k, v) => MapEntry(k, v / total));
  }

  // ─── IDF (Inverse Document Frequency) ─────────────────

  /// Compute IDF across a set of documents
  Map<String, double> _inverseDocumentFrequency(List<List<String>> documents) {
    final n = documents.length;
    final docFreq = <String, int>{};

    for (final doc in documents) {
      final uniqueWords = doc.toSet();
      for (final word in uniqueWords) {
        docFreq[word] = (docFreq[word] ?? 0) + 1;
      }
    }

    return docFreq.map((k, v) => MapEntry(k, log((n + 1) / (v + 1)) + 1));
  }

  // ─── TF-IDF Vector ────────────────────────────────────

  /// Build TF-IDF vector for a document
  Map<String, double> _tfidfVector(
    List<String> tokens,
    Map<String, double> idf,
  ) {
    final tf = _termFrequency(tokens);
    final tfidf = <String, double>{};

    for (final entry in tf.entries) {
      final idfVal = idf[entry.key] ?? 1.0;
      double weight = entry.value * idfVal;

      // Boost tech keywords by 1.5x
      if (_techBoostWords.contains(entry.key)) {
        weight *= 1.5;
      }

      tfidf[entry.key] = weight;
    }

    return tfidf;
  }

  // ─── Cosine Similarity ────────────────────────────────

  /// Compute cosine similarity between two TF-IDF vectors
  double _cosineSimilarity(
    Map<String, double> vecA,
    Map<String, double> vecB,
  ) {
    final allKeys = {...vecA.keys, ...vecB.keys};

    double dotProduct = 0;
    double magA = 0;
    double magB = 0;

    for (final key in allKeys) {
      final a = vecA[key] ?? 0;
      final b = vecB[key] ?? 0;
      dotProduct += a * b;
      magA += a * a;
      magB += b * b;
    }

    if (magA == 0 || magB == 0) return 0;
    return dotProduct / (sqrt(magA) * sqrt(magB));
  }

  // ─── Public API ───────────────────────────────────────

  /// Compute match score (0-100) between resume and a single job description
  double matchScore(String resumeText, String jobDescription) {
    if (resumeText.isEmpty || jobDescription.isEmpty) return 0;

    final resumeTokens = _tokenize(resumeText);
    final jobTokens = _tokenize(jobDescription);

    if (resumeTokens.isEmpty || jobTokens.isEmpty) return 0;

    // Build IDF from both documents
    final idf = _inverseDocumentFrequency([resumeTokens, jobTokens]);

    // Build TF-IDF vectors
    final resumeVec = _tfidfVector(resumeTokens, idf);
    final jobVec = _tfidfVector(jobTokens, idf);

    // Cosine similarity → scale to 0-100
    final similarity = _cosineSimilarity(resumeVec, jobVec);
    return (similarity * 100).clamp(0, 100);
  }

  /// Compute match scores for multiple jobs at once.
  /// Returns a map of job ID → score.
  Map<String, double> batchMatchScores(
    String resumeText,
    List<Map<String, String>> jobs, // [{id, description}]
  ) {
    if (resumeText.isEmpty) return {};

    final resumeTokens = _tokenize(resumeText);
    if (resumeTokens.isEmpty) return {};

    // Tokenize all job descriptions
    final jobTokensList = <List<String>>[];
    for (final job in jobs) {
      jobTokensList.add(_tokenize(job['description'] ?? ''));
    }

    // Build IDF across all documents (resume + all jobs)
    final allDocs = [resumeTokens, ...jobTokensList];
    final idf = _inverseDocumentFrequency(allDocs);

    // Resume TF-IDF vector (computed once)
    final resumeVec = _tfidfVector(resumeTokens, idf);

    // Score each job
    final scores = <String, double>{};
    for (int i = 0; i < jobs.length; i++) {
      final jobVec = _tfidfVector(jobTokensList[i], idf);
      final similarity = _cosineSimilarity(resumeVec, jobVec);
      scores[jobs[i]['id']!] = (similarity * 100).clamp(0, 100);
    }

    return scores;
  }

  /// Extract matched and missing keywords between resume and job
  MatchAnalysis analyzeMatch(String resumeText, String jobDescription) {
    final resumeTokens = _tokenize(resumeText).toSet();
    final jobTokens = _tokenize(jobDescription).toSet();

    // Focus on tech keywords from the job
    final jobTechKeywords = jobTokens.where((t) => _techBoostWords.contains(t)).toSet();
    final allJobKeywords = jobTokens.length > 20
        ? jobTechKeywords
        : jobTokens;

    final matched = allJobKeywords.intersection(resumeTokens).toList()..sort();
    final missing = allJobKeywords.difference(resumeTokens).toList()..sort();

    return MatchAnalysis(
      score: matchScore(resumeText, jobDescription),
      matchedKeywords: matched,
      missingKeywords: missing,
      resumeKeywordCount: resumeTokens.length,
      jobKeywordCount: jobTokens.length,
    );
  }
}

/// Result of detailed match analysis
class MatchAnalysis {
  final double score;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final int resumeKeywordCount;
  final int jobKeywordCount;

  const MatchAnalysis({
    required this.score,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.resumeKeywordCount,
    required this.jobKeywordCount,
  });

  double get matchPercentage => score;

  String get scoreLabel {
    if (score >= 75) return 'Excellent Match';
    if (score >= 50) return 'Good Match';
    if (score >= 30) return 'Fair Match';
    return 'Low Match';
  }
}
