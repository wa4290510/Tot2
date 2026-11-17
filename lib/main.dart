import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/match_store.dart';
import 'screens/history_screen.dart';
import 'screens/match_screen.dart';
import 'theme.dart';
import 'widgets/app_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MatchStore();
  await store.load();
  runApp(MatchScoreApp(store: store));
}

class MatchScoreApp extends StatelessWidget {
  const MatchScoreApp({super.key, required this.store});
  final MatchStore store;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'عداد المباريات',
          theme: AppTheme.data,
          locale: const Locale('ar'),
          home: const HomeShell(),
        ),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [MatchScreen(), HistoryScreen()];

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
          bottomNavigationBar: AppNav(index: _index, onChanged: (index) => setState(() => _index = index)),
        ),
      );
}
