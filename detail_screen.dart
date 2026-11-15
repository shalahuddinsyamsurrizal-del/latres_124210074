import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;
  final bool isFavorite;
  final ValueChanged<int> onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.characterId,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Character> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getCharacter(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Karakter')),
      body: FutureBuilder<Character>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat detail karakter.'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => setState(
                      () => _future = ApiService().getCharacter(widget.characterId),
                    ),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final character = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  character.image,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 240,
                    child: Icon(Icons.person, size: 80),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(character.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 12),
              _info(context, 'Status', character.status),
              _info(context, 'Spesies', character.species),
              _info(context, 'Gender', character.gender),
              _info(context, 'Origin', character.origin),
              _info(context, 'Location', character.location),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  widget.onFavoriteChanged(character.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.isFavorite
                          ? '${character.name} dihapus dari favorit'
                          : '${character.name} ditambahkan ke favorit'),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(widget.isFavorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(BuildContext context, String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label, style: Theme.of(context).textTheme.labelMedium),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
