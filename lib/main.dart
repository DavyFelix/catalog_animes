import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'pages/animes_page.dart';
import 'pages/theme_controller.dart';

// 🔥 Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initHiveForFlutter();

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const _GraphQLWrapper(),
    );
  }
}

class _GraphQLWrapper extends StatefulWidget {
  const _GraphQLWrapper({super.key});

  @override
  State<_GraphQLWrapper> createState() => _GraphQLWrapperState();
}

class _GraphQLWrapperState extends State<_GraphQLWrapper> {
  ValueNotifier<GraphQLClient>? client;

  @override
  void initState() {
    super.initState();
    _initClient();
  }

  Future<void> _initClient() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final httpLink = HttpLink('https://graphql.anilist.co');

    client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: controller.themeMode,
      home: AnimatedTheme(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        data: controller.themeMode == ThemeMode.dark
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData.light(useMaterial3: true),
        child: client == null
            ? const _MainSkeleton()
            : GraphQLProvider(
                client: client!,
                child: const AnimeListPage(),
              ),
      ),
    );
  }
}

class _MainSkeleton extends StatelessWidget {
  const _MainSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carregando..."),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.1, 0.3, 0.8],
            ),
          ),
        ),
      ),
    );
  }
}
