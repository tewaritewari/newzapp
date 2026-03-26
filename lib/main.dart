import 'dart:async';
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

  final List keywords = [
    "kolkata",
    "west bengal",
    "howrah",
    "bengal"
  ];

  Future fetchNews() async {
    final url =
        "https://newsapi.org/v2/everything?q=kolkata OR west bengal&sortBy=publishedAt&apiKey=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    List all = data["articles"];

    // Extra filtering for WB relevance
    List filtered = all.where((a) {
      final text =
          (a["title"] ?? "").toLowerCase() +
          (a["description"] ?? "").toLowerCase();

      return keywords.any((k) => text.contains(k));
    }).toList();

    setState(() {
      articles = filtered;
      loading = false;
    });
  }

  String smartSummary(String? text) {
    if (text == null || text.isEmpty) return "No summary available";

    // Clean + shorten
    text = text.replaceAll(RegExp(r"\[.*?\]"), "");
    text = text.trim();

    if (text.length > 140) {
      return text.substring(0, 140) + "...";
    }
    return text;
  }

  @override
  void initState() {
    super.initState();
    fetchNews();

    // 🔁 Auto refresh every hour
    Timer.periodic(const Duration(hours: 1), (timer) {
      fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📍 WB Quick News"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? const Center(child: Text("No WB news found"))
              : ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final a = articles[index];

                    return Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            smartSummary(a["description"]),
                            style:
                                const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
