// lib/src/home/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../campsite/screens/campsite_search_screen.dart';
import '../../core/config/theme/theme_model.dart';

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Container(
          color: themeModel.isDark ? Colors.black : Colors.white,
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
                    cursorColor: const Color(0xff2e6f40),
                    decoration: InputDecoration(
                      hintText: 'What are you looking for?',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
              if (_hasText)
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
      },
    );
  }

  void _handleSearch(BuildContext context) {
    if (_searchController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(_searchController.text),
        ),
      );
    }
  }
}
