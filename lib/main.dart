import 'dart:convert';
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
  final String apiKey = "6a3acace9ba646ea9168782fd98a8f89";

  Future fetchRSS(String url, String tag) async {
    final res = await http.get(Uri.parse(url));
    final xml = XmlDocument.parse(res.body);

    final items = xml.findAllElements("item");

    return items.map((item) {
      return {
        "title": item.findElements("title").first.text,
        "desc": item.findElements("description").first.text,
        "tag": tag,
        "time": item.findElements("pubDate").first.text,
      };
    }).toList();
  }

Future fetchNews() async {
  try {
    List combined = [];

    // 🔥 1. NewsAPI (Primary)
    final newsApiUrl =
        "https://newsapi.org/v2/top-headlines?country=in&pageSize=50&apiKey=$apiKey";

    final res1 = await http.get(Uri.parse(newsApiUrl));
    final data1 = jsonDecode(res1.body);

    List apiNews = data1["articles"] ?? [];

    for (var a in apiNews) {
      combined.add({
        "title": a["title"],
        "desc": a["description"],
        "time": a["publishedAt"]
      });
    }

    // 🔥 2. Google RSS (Fallback)
    try {
      final rssUrl =
          "https://news.google.com/rss/search?q=India";

      final res2 = await http.get(
        Uri.parse(rssUrl),
        headers: {
          "User-Agent": "Mozilla/5.0"
        },
      );

      final xml = XmlDocument.parse(res2.body);

      final items = xml.findAllElements("item");

      for (var item in items.take(20)) {
        combined.add({
          "title": item.findElements("title").first.text,
          "desc": item.findElements("description").first.text,
          "time": item.findElements("pubDate").first.text,
        });
      }
    } catch (e) {
      print("RSS failed, ignoring...");
    }

    // 🔥 Remove duplicates
    final unique = {
      for (var a in combined) a["title"]: a
    }.values.toList();

    // 🔥 Categorize
    List wb = [];
    List india = [];
    List world = [];

    for (var a in unique) {
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
    setState(() {
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
                        a["tag"],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.blue),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        a["title"],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cleanSummary(a["desc"]),
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
