// lib/src/home/widgets/search_bar.dart
import 'package:flutter/material.dart';
import '../../campsite/screens/campsite_search_screen.dart';

class CustomSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController _searchController = TextEditingController();

  CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'What are you looking for?',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Color(0xff2e6f40)),
                  ),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 8),
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xff2e6f40),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _handleSearch(context),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(_searchController.text),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}