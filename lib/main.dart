
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NewsScreen(),
  ));
}

class NewsScreen extends StatelessWidget {
  final List<Map<String, String>> news = List.generate(
    10,
    (i) => {
      "title": "News Headline ${i + 1}",
      "summary": "This is a short summary of news ${i + 1}"
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News Feed")),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(news[index]["title"]!),
              subtitle: Text(news[index]["summary"]!),
            ),
          );
        },
      ),
    );
  }
}
