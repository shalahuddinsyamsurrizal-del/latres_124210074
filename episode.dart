class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episodeCode;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown',
      airDate: json['air_date']?.toString() ?? 'Unknown',
      episodeCode: json['episode']?.toString() ?? '',
    );
  }
}
