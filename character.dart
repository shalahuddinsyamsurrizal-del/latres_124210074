class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String origin;
  final String location;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'Unknown',
      species: json['species']?.toString() ?? 'Unknown',
      gender: json['gender']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      origin: (json['origin'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Unknown',
      location: (json['location'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Unknown',
    );
  }
}

class CharacterPage {
  final List<Character> results;
  final int pages;

  const CharacterPage({required this.results, required this.pages});

  factory CharacterPage.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final results = (json['results'] as List<dynamic>? ?? [])
        .map((item) => Character.fromJson(item as Map<String, dynamic>))
        .toList();
    return CharacterPage(
      results: results,
      pages: (info['pages'] as num?)?.toInt() ?? 1,
    );
  }
}
