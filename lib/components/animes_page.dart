import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'theme_controller.dart';
import 'details_page.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  int currentPage = 1;
  final int perPage = 10;

  String search = "";
  Timer? _debounce;

  Set<int> favorites = {};
  final TextEditingController searchController = TextEditingController();

  final String query = r'''
query GetAnime($page: Int, $perPage: Int, $search: String) {
  Page(page: $page, perPage: $perPage) {
    pageInfo {
      currentPage
      hasNextPage
    }

    media(type: ANIME, search: $search) {
      id
      title {
        romaji
        english
        native
      }

      description
      genres
      averageScore

      coverImage {
        extraLarge
        large
        medium
      }

      trailer {
        id
        site
        thumbnail
      }
    }
  }
}
''';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("favorites") ?? [];
    setState(() => favorites = list.map(int.parse).toSet());
  }

  Future<void> _toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();

    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    await prefs.setStringList(
      "favorites",
      favorites.map((e) => e.toString()).toList(),
    );

    setState(() {});
  }

  // ——— SEARCH COM DEBOUNCE ———
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = value;
        currentPage = 1;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // ——— SKELETON ———
  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withOpacity(.3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Animes"),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeController>().themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => context.read<ThemeController>().toggleTheme(),
          )
        ],
      ),

      body: Column(
        children: [
          // ——— SEARCH MELHORADO ———
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Buscar anime...",
                filled: true,
                fillColor: theme.cardColor,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(query),
                variables: {
                  "page": currentPage,
                  "perPage": perPage,
                  "search": search.isEmpty ? null : search,
                },
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return _buildSkeleton();
                }

                if (result.hasException) {
                  return Center(
                    child: Text("Erro: ${result.exception}"),
                  );
                }

                final page = result.data!["Page"];
                final List media = page["media"];
                final hasNext = page["pageInfo"]["hasNextPage"];

                return ListView.builder(
                  itemCount: media.length + 1,
                  itemBuilder: (context, index) {
                    if (index == media.length) {
                      if (!hasNext) return const SizedBox.shrink();

                      return TextButton(
                        onPressed: () {
                          setState(() => currentPage++);
                        },
                        child: const Text("Carregar mais"),
                      );
                    }

                    final anime = media[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimeDetailsPage(anime: anime),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Hero(
                                tag: "anime_${anime["id"]}",
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    anime["coverImage"]["large"],
                                    width: 90,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      anime["title"]["romaji"],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Clique para ver detalhes",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  favorites.contains(anime["id"])
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _toggleFavorite(anime["id"]),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
