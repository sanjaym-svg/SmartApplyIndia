import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';
import '../models/job_model.dart';
import 'supabase_service.dart';

/// Fetches jobs from Adzuna API with mock fallback.
/// Optionally caches results to Supabase.
class JobService {
  static final JobService _instance = JobService._();
  factory JobService() => _instance;
  JobService._();

  final SupabaseService _supabase = SupabaseService();

  static const String _baseUrl = 'https://api.adzuna.com/v1/api/jobs/in/search';
  static const int _resultsPerPage = 15;

  bool get isLiveMode => Env.isAdzunaConfigured;

  /// Fetch jobs from Adzuna or mock data
  Future<List<Job>> fetchJobs({
    String query = 'software developer',
    String location = '',
    int page = 1,
  }) async {
    if (!Env.isAdzunaConfigured) {
      // Simulate network delay for mock data
      await Future.delayed(const Duration(milliseconds: 600));
      return Job.getMockJobs();
    }

    try {
      final jobs = await _fetchFromAdzuna(query: query, location: location, page: page);

      // Cache to Supabase if configured
      if (_supabase.isReady && jobs.isNotEmpty) {
        _cacheJobs(jobs);
      }

      return jobs;
    } catch (e) {
      // On API failure, try Supabase cache, then fall back to mock
      if (_supabase.isReady) {
        final cached = await _fetchFromCache();
        if (cached.isNotEmpty) return cached;
      }
      return Job.getMockJobs();
    }
  }

  /// Fetch from Adzuna REST API
  Future<List<Job>> _fetchFromAdzuna({
    required String query,
    String location = '',
    int page = 1,
  }) async {
    final params = {
      'app_id': Env.adzunaAppId,
      'app_key': Env.adzunaApiKey,
      'results_per_page': '$_resultsPerPage',
      'what': query,
      'content-type': 'application/json',
      'sort_by': 'date',
    };

    if (location.isNotEmpty) {
      params['where'] = location;
    }

    final uri = Uri.parse('$_baseUrl/$page').replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Adzuna API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map((json) => Job.fromAdzunaJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Cache jobs to Supabase
  Future<void> _cacheJobs(List<Job> jobs) async {
    try {
      final client = _supabase.client;
      if (client == null) return;

      await client.from('jobs').upsert(
        jobs.map((j) => j.toJson()).toList(),
        onConflict: 'id',
      );
    } catch (_) {
      // Silently fail — caching is optional
    }
  }

  /// Fetch from Supabase cache
  Future<List<Job>> _fetchFromCache() async {
    try {
      final client = _supabase.client;
      if (client == null) return [];

      final response = await client
          .from('jobs')
          .select()
          .order('posted_date', ascending: false)
          .limit(20);

      return (response as List<dynamic>)
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
