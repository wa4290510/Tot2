import 'package:flutter/material.dart';
import '../theme.dart';

class AppNav extends StatelessWidget {
  const AppNav({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onChanged,
        backgroundColor: AppTheme.navyLight,
        indicatorColor: AppTheme.orange.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_score_outlined), selectedIcon: Icon(Icons.sports_score), label: 'المباراة'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'السجل'),
        ],
      );
}
