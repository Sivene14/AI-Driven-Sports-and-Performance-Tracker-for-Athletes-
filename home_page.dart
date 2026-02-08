import 'package:flutter/material.dart';
import 'news_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.fetchSportsNews();
  }

  Future<void> _refreshNews() async {
    final newFuture = NewsService.fetchSportsNews();
    setState(() {
      _newsFuture = newFuture;
    });
    await newFuture; // ✅ wait for completion
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ adapts to dark/light
      appBar: AppBar(
        title: const Text(
          "Sports News",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // ✅ fixed blue header
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        child: FutureBuilder<List<dynamic>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading news"));
            } else {
              final articles = snapshot.data ?? [];
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    color: theme.cardColor, // ✅ adapts to dark/light
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: article["urlToImage"] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                article["urlToImage"],
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.sports, size: 40, color: Colors.blueAccent),
                      title: Text(
                        article["title"] ?? "No title",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        article["description"] ?? "",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}