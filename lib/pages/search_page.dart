import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final Future<List<Map>> Function(String) onSearch;

  const SearchPage({super.key, required this.onSearch});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();

  bool loading = false;
  List<Map> results = [];
  String query = "";

  Future<void> search() async {
    if (query.trim().isEmpty) return;

    setState(() => loading = true);

    final data = await widget.onSearch(query);

    setState(() {
      results = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar animes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 CAMPO DE BUSCA — redesenhado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: Colors.grey.withOpacity(.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 22),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (v) => query = v,
                      onSubmitted: (_) => search(),
                      decoration: const InputDecoration(
                        hintText: "Digite o nome do anime...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        setState(() {
                          query = "";
                          results.clear();
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: loading
                  ? _buildSkeletonList()
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            "Digite algo para pesquisar ✨",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, i) {
                            final anime = results[i];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    anime["coverImage"]["medium"],
                                    width: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  anime["title"]["romaji"] ??
                                      anime["title"]["english"] ??
                                      "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  anime["format"] ?? "",
                                  maxLines: 1,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎭 Skeleton com efeito gradiente
  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
