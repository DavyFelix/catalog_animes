import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<int> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("favorites") ?? [];
    setState(() {
      favorites = list.map(int.parse).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos")),
      body: favorites.isEmpty
          ? const Center(child: Text("Nenhum anime favorito ainda 😢"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (_, index) {
                final id = favorites[index];

                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text("Anime ID: $id"),
                );
              },
            ),
    );
  }
}
