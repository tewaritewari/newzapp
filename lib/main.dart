import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List articles = [];
  bool loading = true;

  final String apiKey = "6a3acace9ba646ea9168782fd98a8f89";

  Future fetchNews() async {
    final url =
        "https://newsapi.org/v2/top-headlines?country=in&pageSize=50&apiKey=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    setState(() {
      articles = data["articles"];
      loading = false;
    });
  }

  String getSummary(String? text) {
    if (text == null || text.isEmpty) return "No summary available";
    return text.length > 120 ? text.substring(0, 120) + "..." : text;
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚡ Quick News"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final a = articles[index];

                return Container(
                  padding: const EdgeInsets.all(15),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a["title"] ?? "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getSummary(a["description"]),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
