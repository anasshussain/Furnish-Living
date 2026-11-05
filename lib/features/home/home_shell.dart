import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/glass_nav_bar.dart';
import 'discover_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _index,
                children: [
                  DiscoverScreen(
                    onSearchTap: () => _go(1),
                    onProfileTap: () => _go(3),
                  ),
                  const SearchScreen(),
                  FavoritesScreen(onDiscoverTap: () => _go(0)),
                  const ProfileScreen(),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: bottomInset + 14,
              child: IgnorePointer(
                ignoring: keyboardOpen,
                child: AnimatedOpacity(
                  opacity: keyboardOpen ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: GlassNavBar(
                        index: _index,
                        onChanged: _go,
                        icons: const [
                          Icons.home_rounded,
                          Icons.search_rounded,
                          Icons.favorite_rounded,
                          Icons.person_rounded,
                        ],
                        labels: const [
                          'Home',
                          'Search',
                          'Favourites',
                          'Profile',
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}