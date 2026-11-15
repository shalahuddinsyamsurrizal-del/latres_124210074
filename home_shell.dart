import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../widgets/character_card.dart';
import 'detail_screen.dart';

class HomeShell extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.username, required this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  Set<int> _favoriteIds = <int>{};
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await PreferencesService().getFavorites();
    if (!mounted) return;
    setState(() {
      _favoriteIds = ids;
      _favoritesLoaded = true;
    });
  }

  Future<void> _toggleFavorite(int id) async {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    await PreferencesService().saveFavorites(_favoriteIds);
  }

  void _openDetail(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          characterId: character.id,
          isFavorite: _favoriteIds.contains(character.id),
          onFavoriteChanged: (id) => _toggleFavorite(id),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_favoritesLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _CharacterListPage(
        favoriteIds: _favoriteIds,
        onFavorite: _toggleFavorite,
        onOpenDetail: _openDetail,
      ),
      _FavoritePage(
        favoriteIds: _favoriteIds,
        onFavorite: _toggleFavorite,
        onOpenDetail: _openDetail,
      ),
      const _EpisodePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Characters', 'Favorites', 'Episodes'][_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Text(widget.username, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favorite'),
          NavigationDestination(icon: Icon(Icons.movie_outlined), selectedIcon: Icon(Icons.movie), label: 'Episode'),
        ],
      ),
    );
  }
}

class _CharacterListPage extends StatefulWidget {
  final Set<int> favoriteIds;
  final ValueChanged<int> onFavorite;
  final ValueChanged<Character> onOpenDetail;

  const _CharacterListPage({
    required this.favoriteIds,
    required this.onFavorite,
    required this.onOpenDetail,
  });

  @override
  State<_CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<_CharacterListPage> {
  final _searchController = TextEditingController();
  String _status = '';
  late Future<CharacterPage> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = ApiService().getCharacters(
        status: _status,
        name: _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Cari nama karakter...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  _load();
                },
                icon: const Icon(Icons.clear),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _filterChip('All', ''),
              _filterChip('Alive', 'alive'),
              _filterChip('Dead', 'dead'),
              _filterChip('Unknown', 'unknown'),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<CharacterPage>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _errorView(() => _load());
              }
              final characters = snapshot.data?.results ?? [];
              if (characters.isEmpty) {
                return const Center(child: Text('Karakter tidak ditemukan.'));
              }
              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CharacterCard(
                      character: character,
                      isFavorite: widget.favoriteIds.contains(character.id),
                      onFavorite: () => widget.onFavorite(character.id),
                      onTap: () => widget.onOpenDetail(character),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _status == value,
        onSelected: (_) {
          _status = value;
          _load();
        },
      ),
    );
  }
}

class _FavoritePage extends StatelessWidget {
  final Set<int> favoriteIds;
  final ValueChanged<int> onFavorite;
  final ValueChanged<Character> onOpenDetail;

  const _FavoritePage({
    required this.favoriteIds,
    required this.onFavorite,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (favoriteIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada karakter favorit.'),
          ],
        ),
      );
    }

    final ids = favoriteIds.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final id = ids[index];
        return FutureBuilder<Character>(
          future: ApiService().getCharacter(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Dismissible(
                key: ValueKey('favorite-$id'),
                direction: DismissDirection.endToStart,
                background: _deleteBackground(),
                onDismissed: (_) {
                  onFavorite(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorite berhasil dihapus.')),
                  );
                },
                child: ListTile(title: Text('Karakter #$id gagal dimuat')),
              );
            }
            final character = snapshot.data!;
            return Dismissible(
              key: ValueKey('favorite-$id'),
              direction: DismissDirection.endToStart,
              background: _deleteBackground(),
              onDismissed: (_) {
                onFavorite(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${character.name} dihapus dari favorit.')),
                );
              },
              child: CharacterCard(
                character: character,
                isFavorite: true,
                onFavorite: () {
                  onFavorite(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${character.name} dihapus dari favorit.')),
                  );
                },
                onTap: () => onOpenDetail(character),
              ),
            );
          },
        );
      },
    );
  }

  Widget _deleteBackground() => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      );
}

class _EpisodePage extends StatefulWidget {
  const _EpisodePage();

  @override
  State<_EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<_EpisodePage> {
  late Future<List<Episode>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Episode>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorView(() => setState(() => _future = ApiService().getEpisodes()));
        }
        final episodes = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = ApiService().getEpisodes()),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${episode.id}')),
                  title: Text(episode.name),
                  subtitle: Text('Air date: ${episode.airDate}'),
                  trailing: Text(episode.episodeCode),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Widget _errorView(VoidCallback retry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Terjadi kesalahan saat memuat data. Periksa koneksi internet.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}
