import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  Color _statusColor() {
    switch (character.status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.network(
              character.image,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 112,
                height: 112,
                color: Colors.black12,
                child: const Icon(Icons.person, size: 42),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _statusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('${character.status} • ${character.species}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
