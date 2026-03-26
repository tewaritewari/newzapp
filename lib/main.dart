import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

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

  Future fetchNews() async {
    try {
      final url =
          "https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en";

      final res = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent": "Mozilla/5.0",
          "Accept": "application/rss+xml",
        },
      );

      print("STATUS: ${res.statusCode}");

      if (res.statusCode != 200 || res.body.isEmpty) {
        throw Exception("Failed to load RSS");
      }

      final xml = XmlDocument.parse(res.body);
      final items = xml.findAllElements("item");

      if (items.isEmpty) {
        throw Exception("No news items");
      }

      List all = items.map((item) {
        return {
          "title": item.findElements("title").first.text,
          "desc": item.findElements("description").first.text,
        };
      }).toList();

      // Categorize
      List wb = [];
      List india = [];
      List world = [];

      for (var a in all) {
        final text =
            ((a["title"] ?? "") + (a["desc"] ?? "")).toLowerCase();

        if (text.contains("kolkata") ||
            text.contains("west bengal") ||
            text.contains("bengal")) {
          wb.add({...a, "tag": "📍 WB"});
        } else if (text.contains("india")) {
          india.add({...a, "tag": "🇮🇳 India"});
        } else {
          world.add({...a, "tag": "🌍 World"});
        }
      }

      List finalList = [...wb, ...india, ...world];

      setState(() {
        articles = finalList;
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");

      // Fallback so app never looks empty
      setState(() {
        articles = [
          {
            "title": "Unable to load news",
            "desc": "Check internet connection or try again later.",
            "tag": "⚠️"
          }
        ];
        loading = false;
      });
    }
  }

  String cleanSummary(String text) {
    text = text.replaceAll(RegExp(r"<[^>]*>"), "");
    return text.length > 140 ? text.substring(0, 140) + "..." : text;
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
        title: const Text("📰 Smart News"),
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
                        a["tag"] ?? "🌍",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.blue),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        a["title"] ?? "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cleanSummary(a["desc"] ?? ""),
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
