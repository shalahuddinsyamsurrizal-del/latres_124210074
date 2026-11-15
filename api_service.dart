import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  Future<CharacterPage> getCharacters({
    String status = '',
    String name = '',
    int page = 1,
  }) async {
    final query = <String, String>{'page': '$page'};
    if (status.isNotEmpty) query['status'] = status.toLowerCase();
    if (name.trim().isNotEmpty) query['name'] = name.trim();

    final uri = Uri.parse('$_baseUrl/character').replace(queryParameters: query);
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return CharacterPage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    if (response.statusCode == 404) {
      return const CharacterPage(results: [], pages: 1);
    }
    throw Exception('Gagal mengambil karakter (HTTP ${response.statusCode}).');
  }

  Future<Character> getCharacter(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/character/$id'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      return Character.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal mengambil detail karakter.');
  }

  Future<List<Episode>> getEpisodes() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/episode'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil episode (HTTP ${response.statusCode}).');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? [])
        .map((item) => Episode.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
