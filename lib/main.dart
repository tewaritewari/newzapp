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
      final wb = await fetchRSS(
          "https://news.google.com/rss/search?q=West+Bengal+OR+Kolkata",
          "📍 WB");

      final india = await fetchRSS(
          "https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en",
          "🇮🇳 India");

      final world = await fetchRSS(
          "https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en",
          "🌍 World");

      List combined = [...wb, ...india, ...world];

      // Remove duplicates
      final unique = {
        for (var a in combined) a["title"]: a
      }.values.toList();

      setState(() {
        articles = unique;
        loading = false;
      });
    } catch (e) {
      print(e);
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
