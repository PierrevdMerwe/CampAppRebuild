import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final List<String> results;

  SearchScreen(this.results);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(results[index]),
          );
        },
      ),
    );
  }
}
