import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NewsScreen(),
  ));
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List articles = [];

  Future fetchNews() async {
    final url =
        "https://newsapi.org/v2/top-headlines?country=in&apiKey=6a3acace9ba646ea9168782fd98a8f89";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    setState(() {
      articles = data["articles"];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News Feed")),
      body: articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final a = articles[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(a["title"] ?? ""),
                    subtitle: Text(a["description"] ?? ""),
                  ),
                );
              },
            ),
    );
  }
}
