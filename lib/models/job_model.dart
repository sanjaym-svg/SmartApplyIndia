class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String salaryMin;
  final String salaryMax;
  final List<String> tags;
  final DateTime postedDate;
  final bool isRemote;
  final bool isFresher;
  final double matchScore;
  final String? companyLogo;
  final String? applyUrl;
  final bool isBookmarked;
  final bool isApplied;
  final String source; // 'adzuna', 'mock', 'supabase'

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.salaryMin = '',
    this.salaryMax = '',
    this.tags = const [],
    required this.postedDate,
    this.isRemote = false,
    this.isFresher = false,
    this.matchScore = 0.0,
    this.companyLogo,
    this.applyUrl,
    this.isBookmarked = false,
    this.isApplied = false,
    this.source = 'mock',
  });

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? description,
    String? salaryMin,
    String? salaryMax,
    List<String>? tags,
    DateTime? postedDate,
    bool? isRemote,
    bool? isFresher,
    double? matchScore,
    String? companyLogo,
    String? applyUrl,
    bool? isBookmarked,
    bool? isApplied,
    String? source,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      description: description ?? this.description,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      tags: tags ?? this.tags,
      postedDate: postedDate ?? this.postedDate,
      isRemote: isRemote ?? this.isRemote,
      isFresher: isFresher ?? this.isFresher,
      matchScore: matchScore ?? this.matchScore,
      companyLogo: companyLogo ?? this.companyLogo,
      applyUrl: applyUrl ?? this.applyUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isApplied: isApplied ?? this.isApplied,
      source: source ?? this.source,
    );
  }

  String get salaryRange {
    if (salaryMin.isEmpty && salaryMax.isEmpty) return 'Not disclosed';
    if (salaryMin.isEmpty) return '₹$salaryMax';
    if (salaryMax.isEmpty) return '₹$salaryMin+';
    return '₹$salaryMin - ₹$salaryMax';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedDate);
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  // ─── Adzuna JSON Parsing ─────────────────────────────────
  factory Job.fromAdzunaJson(Map<String, dynamic> json) {
    final salaryMin = json['salary_min'] as num?;
    final salaryMax = json['salary_max'] as num?;

    // Extract tags from category and title
    final category = json['category']?['label'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final tags = <String>{};

    // Extract technology keywords from title and description
    final techKeywords = [
      'Flutter', 'React', 'Angular', 'Vue', 'Node.js', 'Python', 'Java',
      'Kotlin', 'Swift', 'Dart', 'JavaScript', 'TypeScript', 'Go', 'Rust',
      'C++', 'C#', 'PHP', 'Ruby', 'Django', 'Spring', 'AWS', 'Azure',
      'Docker', 'Kubernetes', 'DevOps', 'ML', 'AI', 'Data', 'SQL', 'MongoDB',
      'Firebase', 'REST', 'GraphQL', 'Mobile', 'Frontend', 'Backend', 'Full Stack',
    ];
    final titleLower = title.toLowerCase();
    final descLower = (json['description'] as String? ?? '').toLowerCase();
    for (final kw in techKeywords) {
      if (titleLower.contains(kw.toLowerCase()) || descLower.contains(kw.toLowerCase())) {
        tags.add(kw);
      }
    }
    if (category.isNotEmpty && tags.length < 4) tags.add(category);
    if (tags.isEmpty) tags.add('Software');

    // Detect remote/fresher from title + description
    final combined = '$titleLower $descLower';
    final isRemote = combined.contains('remote') || combined.contains('work from home') || combined.contains('wfh');
    final isFresher = combined.contains('fresher') || combined.contains('entry level') ||
        combined.contains('junior') || combined.contains('0-1') || combined.contains('0-2') ||
        combined.contains('graduate') || combined.contains('intern');

    // Format salary in Indian Lakhs
    String formatSalary(num? val) {
      if (val == null || val <= 0) return '';
      // Adzuna returns yearly salary
      final inLakhs = val / 100000;
      if (inLakhs >= 1) return '${inLakhs.toStringAsFixed(inLakhs.truncateToDouble() == inLakhs ? 0 : 1)}L';
      return '${(val / 1000).toStringAsFixed(0)}K';
    }

    return Job(
      id: 'az_${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      title: _cleanHtml(title),
      company: json['company']?['display_name'] as String? ?? 'Unknown Company',
      location: json['location']?['display_name'] as String? ?? 'India',
      description: _cleanHtml(json['description'] as String? ?? ''),
      salaryMin: formatSalary(salaryMin),
      salaryMax: formatSalary(salaryMax),
      tags: tags.take(4).toList(),
      postedDate: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      isRemote: isRemote,
      isFresher: isFresher,
      matchScore: 0.0, // Will be computed by ATS engine later
      applyUrl: json['redirect_url'] as String?,
      source: 'adzuna',
    );
  }

  /// Remove HTML tags from Adzuna descriptions
  static String _cleanHtml(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'").trim();
  }

  // ─── JSON Serialization (for Supabase cache) ─────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'tags': tags,
      'posted_date': postedDate.toIso8601String(),
      'is_remote': isRemote,
      'is_fresher': isFresher,
      'match_score': matchScore,
      'company_logo': companyLogo,
      'apply_url': applyUrl,
      'source': source,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      salaryMin: json['salary_min'] as String? ?? '',
      salaryMax: json['salary_max'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      postedDate: DateTime.tryParse(json['posted_date'] as String? ?? '') ?? DateTime.now(),
      isRemote: json['is_remote'] as bool? ?? false,
      isFresher: json['is_fresher'] as bool? ?? false,
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      companyLogo: json['company_logo'] as String?,
      applyUrl: json['apply_url'] as String?,
      source: json['source'] as String? ?? 'supabase',
    );
  }

  // ─── Mock Data ───────────────────────────────────────────
  static List<Job> getMockJobs() {
    return [
      Job(
        id: '1',
        title: 'Flutter Developer',
        company: 'TCS Digital',
        location: 'Mumbai, India',
        description:
            'We are looking for a passionate Flutter developer to join our mobile development team. You will be responsible for building cross-platform applications using Flutter framework.\n\nRequirements:\n• 0-2 years of experience in Flutter/Dart\n• Understanding of state management (Provider, Bloc, Riverpod)\n• Knowledge of REST APIs and JSON\n• Familiarity with Firebase services\n• Good understanding of UI/UX principles\n\nSkills: Flutter, Dart, Firebase, REST API, Git, Agile',
        salaryMin: '4L',
        salaryMax: '8L',
        tags: ['Flutter', 'Dart', 'Firebase', 'Mobile'],
        postedDate: DateTime.now().subtract(const Duration(hours: 3)),
        isRemote: false,
        isFresher: true,
        matchScore: 87.5,
      ),
      Job(
        id: '2',
        title: 'Python Backend Engineer',
        company: 'Infosys BPM',
        location: 'Bangalore, India',
        description:
            'Join our backend engineering team to build scalable microservices using Python and Django.\n\nRequirements:\n• Strong Python programming skills\n• Experience with Django/Flask\n• Database knowledge (PostgreSQL, MongoDB)\n• RESTful API design\n• Docker and Kubernetes basics\n\nSkills: Python, Django, PostgreSQL, Docker, AWS',
        salaryMin: '5L',
        salaryMax: '10L',
        tags: ['Python', 'Django', 'AWS', 'Backend'],
        postedDate: DateTime.now().subtract(const Duration(hours: 6)),
        isRemote: true,
        isFresher: true,
        matchScore: 72.0,
      ),
      Job(
        id: '3',
        title: 'React.js Frontend Developer',
        company: 'Wipro Technologies',
        location: 'Hyderabad, India',
        description:
            'Looking for a React.js developer to build modern web applications.\n\nRequirements:\n• Proficiency in React.js and JavaScript ES6+\n• Experience with Redux or Context API\n• HTML5, CSS3, and responsive design\n• Knowledge of RESTful APIs\n• Version control with Git\n\nSkills: React, JavaScript, Redux, HTML, CSS, TypeScript',
        salaryMin: '3.5L',
        salaryMax: '7L',
        tags: ['React', 'JavaScript', 'Frontend', 'TypeScript'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        isRemote: false,
        isFresher: true,
        matchScore: 65.3,
      ),
      Job(
        id: '4',
        title: 'Full Stack Developer',
        company: 'Zoho Corporation',
        location: 'Chennai, India',
        description:
            'Zoho is hiring full stack developers for our SaaS product development team.\n\nRequirements:\n• Strong in Java or Node.js backend\n• React or Angular frontend skills\n• SQL and NoSQL databases\n• Understanding of cloud services\n• Problem-solving aptitude\n\nSkills: Java, React, Node.js, MySQL, MongoDB, AWS',
        salaryMin: '6L',
        salaryMax: '12L',
        tags: ['Full Stack', 'Java', 'React', 'Node.js'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        isRemote: false,
        isFresher: false,
        matchScore: 58.0,
      ),
      Job(
        id: '5',
        title: 'DevOps Engineer Intern',
        company: 'Razorpay',
        location: 'Bangalore, India',
        description:
            'Internship opportunity in DevOps engineering at one of India\'s leading fintech startups.\n\nRequirements:\n• Basics of Linux and networking\n• Familiarity with CI/CD concepts\n• Docker basics\n• Scripting (Bash/Python)\n• Eagerness to learn\n\nSkills: Linux, Docker, CI/CD, Python, Bash, AWS',
        salaryMin: '25K/m',
        salaryMax: '40K/m',
        tags: ['DevOps', 'Docker', 'Linux', 'Intern'],
        postedDate: DateTime.now().subtract(const Duration(hours: 12)),
        isRemote: true,
        isFresher: true,
        matchScore: 45.2,
      ),
      Job(
        id: '6',
        title: 'Android Developer',
        company: 'PhonePe',
        location: 'Pune, India',
        description:
            'Build next-generation Android applications for millions of users.\n\nRequirements:\n• Kotlin and Java proficiency\n• Android SDK and Jetpack components\n• MVVM architecture\n• REST API integration\n• Unit testing\n\nSkills: Kotlin, Java, Android, Jetpack, MVVM, Room DB',
        salaryMin: '8L',
        salaryMax: '15L',
        tags: ['Android', 'Kotlin', 'Java', 'Mobile'],
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        isRemote: false,
        isFresher: false,
        matchScore: 52.8,
      ),
      Job(
        id: '7',
        title: 'Data Analyst Fresher',
        company: 'Accenture India',
        location: 'Delhi NCR, India',
        description:
            'Entry level data analyst position focusing on business intelligence.\n\nRequirements:\n• Strong analytical skills\n• SQL proficiency\n• Excel / Google Sheets\n• Basic Python or R\n• Data visualization (Tableau/Power BI)\n\nSkills: SQL, Python, Tableau, Excel, Power BI, Statistics',
        salaryMin: '3L',
        salaryMax: '5L',
        tags: ['Data', 'SQL', 'Python', 'Fresher'],
        postedDate: DateTime.now().subtract(const Duration(hours: 8)),
        isRemote: false,
        isFresher: true,
        matchScore: 38.5,
      ),
      Job(
        id: '8',
        title: 'ML Engineer',
        company: 'Flipkart',
        location: 'Bangalore, India',
        description:
            'Join the AI/ML team to build recommendation systems and search algorithms.\n\nRequirements:\n• Strong Python and ML fundamentals\n• TensorFlow / PyTorch\n• NLP or Computer Vision experience\n• Data structures and algorithms\n• Research mindset\n\nSkills: Python, TensorFlow, PyTorch, NLP, Deep Learning, MLOps',
        salaryMin: '15L',
        salaryMax: '25L',
        tags: ['ML', 'Python', 'AI', 'Deep Learning'],
        postedDate: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        isRemote: true,
        isFresher: false,
        matchScore: 42.0,
      ),
    ];
  }
}
