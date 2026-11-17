import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../services/match_store.dart';
import '../theme.dart';
import '../widgets/score_card.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _playerCount = 2;
  int _target = 10;
  bool _started = false;
  DateTime? _startedAt;
  List<Player> _players = const [];
  final _nameControllers = List.generate(4, TextEditingController.new);

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startMatch() {
    final names = _nameControllers
        .take(_playerCount)
        .map((controller) => controller.text.trim())
        .toList();
    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسم كل لاعب قبل بدء المباراة')),
      );
      return;
    }
    setState(() {
      _players = names.map((name) => Player(name: name)).toList();
      _startedAt = DateTime.now();
      _started = true;
    });
  }

  void _updateScore(int index, int delta) {
    if (!_started) return;
    setState(() {
      final next = (_players[index].score + delta).clamp(0, _target);
      _players = [
        for (var i = 0; i < _players.length; i++)
          i == index ? _players[i].copyWith(score: next) : _players[i],
      ];
    });
    if (_players[index].score >= _target) _finishMatch(index);
  }

  Future<void> _finishMatch(int winnerIndex) async {
    final store = context.read<MatchStore>();
    final record = MatchRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      players: _players,
      targetScore: _target,
      startedAt: _startedAt ?? DateTime.now(),
      finishedAt: DateTime.now(),
      winnerName: _players[winnerIndex].name,
    );
    await store.add(record);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.navyLight,
        title: const Text('المباراة خلصت — مبروك للفائز'),
        content: Text('الفائز هو ${record.winnerName}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))],
      ),
    );
    if (mounted) setState(() => _started = false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 150,
        pinned: true,
        backgroundColor: AppTheme.navy,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 14),
          title: Text(_started ? 'المباراة الحالية' : 'عداد المباريات', style: const TextStyle(fontWeight: FontWeight.w800)),
          background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.navy, AppTheme.navyLight], begin: Alignment.topRight, end: Alignment.bottomLeft))),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
        sliver: SliverList(delegate: SliverChildListDelegate([
          if (!_started) ..._setupContent() else ..._scoreContent(),
        ])),
      ),
    ]);
  }

  List<Widget> _setupContent() => [
        const Text('مين هيلعب؟', style: TextStyle(color: AppTheme.ivory, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('ابدأ مباراة جديدة وسجّل النقاط بسرعة.', style: TextStyle(color: AppTheme.muted, fontSize: 15)),
        const SizedBox(height: 24),
        _sectionLabel('عدد اللاعبين'),
        const SizedBox(height: 10),
        SegmentedButton<int>(segments: const [ButtonSegment(value: 2, label: Text('لاعبان')), ButtonSegment(value: 4, label: Text('أربعة لاعبين'))], selected: {_playerCount}, onSelectionChanged: (value) => setState(() => _playerCount = value.first)),
        const SizedBox(height: 24),
        _sectionLabel('أسماء اللاعبين'),
        const SizedBox(height: 10),
        for (var i = 0; i < _playerCount; i++) ...[
          TextField(
            controller: _nameControllers[i],
            textInputAction: i == _playerCount - 1 ? TextInputAction.done : TextInputAction.next,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(hintText: 'اسم اللاعب ${i + 1}', prefixIcon: const Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 24),
        _sectionLabel('حد الفوز'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Slider(value: _target.toDouble(), min: 1, max: 30, divisions: 29, activeColor: AppTheme.orange, onChanged: (value) => setState(() => _target = value.round()))),
          Container(width: 58, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: AppTheme.orange, borderRadius: BorderRadius.circular(14)), child: Text('$_target', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.navy, fontSize: 21, fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 8),
        Text('أول لاعب يوصل إلى $_target نقطة يفوز.', style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 34),
        SizedBox(height: 56, child: FilledButton.icon(onPressed: _startMatch, icon: const Icon(Icons.play_arrow_rounded), label: const Text('ابدأ المباراة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
      ];

  List<Widget> _scoreContent() => [
        Row(children: [const Icon(Icons.flag_outlined, color: AppTheme.orange), const SizedBox(width: 8), Text('حد الفوز: $_target نقطة', style: const TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 16),
        for (var i = 0; i < _players.length; i++) ...[
          ScoreCard(name: _players[i].name, score: _players[i].score, target: _target, onIncrease: () => _updateScore(i, 1), onDecrease: () => _updateScore(i, -1), isWinner: _players[i].score >= _target),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => setState(() => _started = false), icon: const Icon(Icons.refresh), label: const Text('مباراة جديدة'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.ivory, side: BorderSide(color: AppTheme.ivory.withValues(alpha: 0.3)), padding: const EdgeInsets.symmetric(vertical: 15))),
      ];

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w700));
}
