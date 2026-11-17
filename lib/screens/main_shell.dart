import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'browse_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _icons = [Icons.home_filled, Icons.search, Icons.explore, Icons.person];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          SearchScreen(),
          BrowseScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (i) {
              final selected = i == _index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _index = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black.withAlpha(120) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_icons[i], color: selected ? AppColors.yellow : Colors.white),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
