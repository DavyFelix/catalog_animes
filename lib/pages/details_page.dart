import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AnimeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> anime;

  const AnimeDetailsPage({
    super.key,
    required this.anime,
  });

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    final trailer = widget.anime["trailer"];

    final hasTrailer =
        trailer != null && trailer["site"] == "youtube" && trailer["id"] != null;

    if (hasTrailer) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: trailer["id"],
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cover = widget.anime["coverImage"];
    final title = widget.anime["title"];
    final trailer = widget.anime["trailer"];

    final imageUrl =
        cover?["extraLarge"] ?? cover?["large"] ?? cover?["medium"];

    final animeTitle =
        (title?["english"] ?? title?["romaji"] ?? title?["native"] ?? "Sem título");

    final genres = (widget.anime["genres"] ?? []) as List<dynamic>;
    final score = widget.anime["averageScore"];

    final hasTrailer =
        trailer != null && trailer["site"] == "youtube" && trailer["id"] != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                animeTitle,
                style: theme.textTheme.titleSmall,
              ),
              background: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade900),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ⭐ Nota
                  if (score != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          "$score / 100",
                          style: theme.textTheme.bodyLarge,
                        )
                      ],
                    ),

                  const SizedBox(height: 14),

                  // 🎭 Gêneros
                  if (genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: genres
                          .map(
                            (g) => Chip(
                              label: Text(g.toString()),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 20),

                  // 🎬 Trailer
                  if (hasTrailer && _youtubeController != null) ...[
                    Text(
                      "Trailer",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 📖 Descrição (remover tags HTML)
                  if (widget.anime["description"] != null)
                    Text(
                      widget.anime["description"]
                          .toString()
                          .replaceAll(RegExp(r'<[^>]*>'), ''),
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
