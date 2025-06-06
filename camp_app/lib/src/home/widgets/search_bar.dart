import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../campsite/screens/campsite_search_screen.dart';
import '../../core/config/theme/theme_model.dart';
import '../../shared/services/autocomplete_service.dart';

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final AutocompleteService _autocompleteService = AutocompleteService();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _searchKey = GlobalKey();
  bool _hasText = false;
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
      });
      _getSuggestions(_searchController.text);
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });

    // Listen for scroll changes to hide overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        _scrollPosition = scrollable.position;
        _scrollPosition!.addListener(_onScroll);
      }
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _hideOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Hide overlay when scrolling to prevent positioning issues
    _hideOverlay();
  }

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      _hideOverlay();
      return;
    }

    final suggestions = await _autocompleteService.getLocationSuggestions(query);
    setState(() {
      _suggestions = suggestions;
    });

    if (_focusNode.hasFocus && suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay(); // Remove existing overlay first

    if (_suggestions.isEmpty) return;

    final RenderBox? renderBox = _searchKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + horizontalPadding,
        top: offset.dy + size.height,
        width: size.width - (horizontalPadding * 2),
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Color(0xff2e6f40),
                    size: 20,
                  ),
                  title: Text(
                    _suggestions[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _selectSuggestion(_suggestions[index]),
                  dense: true,
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _hideOverlay();
    _focusNode.unfocus();
  }

  void _handleSearch(BuildContext context) {
    if (_searchController.text.isNotEmpty) {
      _hideOverlay();
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(_searchController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return GestureDetector(
          onTap: () {
            // Hide overlay when tapping outside
            if (!_focusNode.hasFocus) {
              _hideOverlay();
            }
          },
          child: Container(
            key: _searchKey,
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
                      focusNode: _focusNode,
                      cursorColor: const Color(0xff2e6f40),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _handleSearch(context);
                        }
                      },
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
                        suffixIcon: _hasText
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _suggestions = [];
                            });
                            _hideOverlay();
                          },
                        )
                            : null,
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
          ),
        );
      },
    );
  }
}