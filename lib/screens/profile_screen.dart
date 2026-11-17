import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/movies_grid.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final library = context.watch<LibraryProvider>();
    if (user == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surface,
                    backgroundImage: CachedNetworkImageProvider(AppConstants.avatarUrl(user.avatar)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Counter(value: library.watchlist.length, label: 'Wish List'),
                            const SizedBox(width: 32),
                            _Counter(value: library.history.length, label: 'History'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Edit Profile',
                      onTap: () => Navigator.pushNamed(context, '/update'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Exit',
                      color: AppColors.red,
                      textColor: Colors.white,
                      onTap: () async {
                        final auth = context.read<AuthProvider>();
                        final lib = context.read<LibraryProvider>();
                        final nav = Navigator.of(context);
                        await auth.logout();
                        lib.clear();
                        nav.pushNamedAndRemoveUntil('/login', (_) => false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const TabBar(
              indicatorColor: AppColors.yellow,
              labelColor: AppColors.yellow,
              unselectedLabelColor: Colors.white,
              dividerColor: AppColors.surface,
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Watch List'),
                Tab(icon: Icon(Icons.folder), text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  library.watchlist.isEmpty
                      ? const EmptyState(message: 'Your watch list is empty')
                      : MoviesGrid(movies: library.watchlist),
                  library.history.isEmpty
                      ? const EmptyState(message: 'No history yet')
                      : MoviesGrid(movies: library.history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final String label;

  const _Counter({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
