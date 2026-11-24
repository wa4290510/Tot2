import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../services/match_store.dart';
import '../theme.dart';
import '../widgets/team_score_card.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const _defaultPlayers = [
    'احمد فتحي', 'د.شريف كرشه', 'د. عصام', 'عبد الله اشرف',
    'وليد عجمي', 'الحاج ابراهيم', 'الحاج درويش', 'م. احمد ريحان',
    'ا.اواب شعبان', 'م.عمر هيبه', 'د.محمود عباس', 'ا.وائل الصاوي',
    'يوسف', 'حسن', 'سامر', 'حسين',
  ];
  final _teamNames = [TextEditingController(text: 'فريق ١'), TextEditingController(text: 'فريق ٢')];
  final _groupController = TextEditingController(text: _defaultPlayers.join('\n'));
  final _memberControllers = [TextEditingController(), TextEditingController()];
  final _playerTeams = <String, int>{};
  final _audio = AudioPlayer();
  final _confetti = ConfettiController(duration: const Duration(seconds: 4));
  List<Team> _teams = const [];
  List<RoundScore> _rounds = const [];
  bool _started = false;
  int _selectedTeam = 0;
  int _selectedPoints = 1;
  int _target = 30;
  DateTime? _startedAt;
  List<String> get _groupNames => _groupController.text.split(RegExp(r'[\n,،;؛]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();

  @override
  void dispose() {
    for (final c in [..._teamNames, ..._memberControllers, _groupController]) {
      c.dispose();
    }
    _audio.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _startMatch() {
    final names = [_teamNames[0].text.trim(), _teamNames[1].text.trim()];
    if (names.any((e) => e.isEmpty)) {
      _toast('اكتب اسم الفريقين أولًا');
      return;
    }
    final members = [for (var i = 0; i < 2; i++) _memberControllers[i].text.split(RegExp(r'[\n,،;؛]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList()];
    if (members.any((team) => team.isEmpty || team.length > 2)) {
      _toast('اختار لاعبًا واحدًا أو لاعبين فقط لكل فريق');
      return;
    }
    setState(() {
      _teams = [Team(name: names[0], members: members[0]), Team(name: names[1], members: members[1])];
      _rounds = const [];
      _selectedTeam = 0;
      _startedAt = DateTime.now();
      _started = true;
    });
  }

  Future<void> _addRound() async {
    final current = _teams[_selectedTeam];
    final updated = current.copyWith(totalScore: current.totalScore + _selectedPoints, roundScores: [...current.roundScores, _selectedPoints]);
    final teams = [..._teams]..[_selectedTeam] = updated;
    final rounds = [..._rounds, RoundScore(round: _rounds.length + 1, teamName: current.name, points: _selectedPoints)];
    setState(() { _teams = teams; _rounds = rounds; });
    if (updated.totalScore >= _target) await _finishMatch(_selectedTeam);
  }

  void _removeRound(int roundIndex) {
    if (roundIndex < 0 || roundIndex >= _rounds.length) return;
    final remaining = [..._rounds]..removeAt(roundIndex);
    final rounds = [
      for (var i = 0; i < remaining.length; i++)
        RoundScore(round: i + 1, teamName: remaining[i].teamName, points: remaining[i].points),
    ];
    final teams = [
      for (final team in _teams)
        team.copyWith(
          totalScore: rounds.where((round) => round.teamName == team.name).fold(0, (sum, round) => sum + round.points),
          roundScores: rounds.where((round) => round.teamName == team.name).map((round) => round.points).toList(),
        ),
    ];
    setState(() {
      _rounds = rounds;
      _teams = teams;
    });
  }

  Future<void> _finishMatch(int winnerIndex) async {
    final winner = _teams[winnerIndex];
    final record = MatchRecord(id: DateTime.now().microsecondsSinceEpoch.toString(), teams: _teams, rounds: _rounds, targetScore: _target, startedAt: _startedAt ?? DateTime.now(), finishedAt: DateTime.now(), winnerName: _teams[winnerIndex].name);
    await context.read<MatchStore>().add(record);
    _confetti.play();
    try { await _audio.play(AssetSource('audio/winner.mp3')); } catch (_) {}
    if (!mounted) return;
    await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => _WinnerDialog(team: record.winnerName, members: winner.members, confetti: _confetti));
    if (mounted) _newMatch();
  }

  void _newMatch() {
    setState(() {
      _started = false;
      _playerTeams.clear();
      for (final controller in _memberControllers) {
        controller.clear();
      }
    });
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 150, pinned: true, backgroundColor: AppTheme.navy, flexibleSpace: FlexibleSpaceBar(titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 14), title: Text(_started ? 'المباراة الحالية' : 'عداد الفرق', style: const TextStyle(fontWeight: FontWeight.w800)), background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.navy, AppTheme.navyLight], begin: Alignment.topRight, end: Alignment.bottomLeft))))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(18, 20, 18, 32), sliver: SliverList(delegate: SliverChildListDelegate(_started ? _scoreContent() : _setupContent()))),
      ]);

  List<Widget> _setupContent() => [
        const Text('اختار الفرق', style: TextStyle(color: AppTheme.ivory, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('الأسماء الافتراضية جاهزة. اختار لاعبًا أو لاعبين لكل فريق، أو عدّل القائمة والصق أسماء جروب واتساب.', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
        const SizedBox(height: 20),
        _label('أسماء المجموعة من واتساب'),
        const SizedBox(height: 8),
        TextField(controller: _groupController, minLines: 3, maxLines: 6, onChanged: (_) => setState(() {}), textDirection: TextDirection.rtl, decoration: const InputDecoration(hintText: 'انسخ الأسماء من واتساب والصقها هنا، كل اسم في سطر')),
        if (_groupNames.isNotEmpty) ...[
          const SizedBox(height: 12),
        const Text('توزيع الأسماء على الفرق — لاعب أو لاعبان لكل فريق', style: TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ..._groupNames.map((name) => _memberAssignment(name)),
        ],
        const SizedBox(height: 18),
        for (var i = 0; i < 2; i++) ...[
          _label('اسم الفريق ${i + 1}'),
          const SizedBox(height: 7),
          TextField(controller: _teamNames[i], textDirection: TextDirection.rtl, decoration: InputDecoration(prefixIcon: const Icon(Icons.groups_outlined), hintText: 'الفريق ${i + 1}')),
          const SizedBox(height: 7),
          TextField(controller: _memberControllers[i], minLines: 1, maxLines: 3, textDirection: TextDirection.rtl, decoration: InputDecoration(prefixIcon: const Icon(Icons.people_outline), hintText: 'أسماء أعضاء الفريق ${i + 1} — اختياري')),
          const SizedBox(height: 14),
        ],
        _label('حد الفوز'),
        Row(children: [Expanded(child: Slider(value: _target.toDouble(), min: 1, max: 60, divisions: 59, activeColor: AppTheme.orange, onChanged: (v) => setState(() => _target = v.round()))), Container(width: 60, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: AppTheme.orange, borderRadius: BorderRadius.circular(14)), child: Text('$_target', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.navy, fontSize: 21, fontWeight: FontWeight.w900)))]),
        const SizedBox(height: 20),
        SizedBox(height: 56, child: FilledButton.icon(onPressed: _startMatch, icon: const Icon(Icons.play_arrow_rounded), label: const Text('ابدأ المباراة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
      ];

  Widget _memberAssignment(String name) => Card(color: AppTheme.navyLight, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Row(children: [Expanded(child: Text(name, style: const TextStyle(color: AppTheme.ivory))), DropdownButton<int>(value: _playerTeams[name], hint: const Text('اختار الفريق', style: TextStyle(color: AppTheme.muted)), dropdownColor: AppTheme.navyLight, items: const [DropdownMenuItem(value: 0, child: Text('فريق ١')), DropdownMenuItem(value: 1, child: Text('فريق ٢'))], onChanged: (value) { if (value == null) return; final oldTeam = _playerTeams[name]; final alreadyInTeam = _groupNames.where((n) => _playerTeams[n] == value && n != name).length; if (alreadyInTeam >= 2) { _toast('كل فريق يمكنه اختيار لاعب أو لاعبين فقط'); return; } setState(() { _playerTeams[name] = value; for (var i = 0; i < 2; i++) { final names = _groupNames.where((n) => _playerTeams[n] == i).toList(); _memberControllers[i].text = names.join('\n'); } if (oldTeam != null && oldTeam != value) { _memberControllers[oldTeam].text = _groupNames.where((n) => _playerTeams[n] == oldTeam).join('\n'); } }); })])));

  List<Widget> _scoreContent() => [
        Row(children: [const Icon(Icons.flag_outlined, color: AppTheme.orange), const SizedBox(width: 8), Text('الفوز عند $_target نقطة • الجولة ${_rounds.length + 1}', style: const TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (var i = 0; i < _teams.length; i++) Expanded(child: Padding(padding: EdgeInsetsDirectional.only(end: i == 0 ? 6 : 0, start: i == 1 ? 6 : 0), child: TeamScoreCard(team: _teams[i].name, members: _teams[i].members, score: _teams[i].totalScore, target: _target, accent: i == 0 ? const Color(0xFFBDEBFF) : const Color(0xFFC7F7E7), selected: _selectedTeam == i, onSelect: () => setState(() => _selectedTeam = i))))]),
        const SizedBox(height: 6),
        const Text('اختار عدد النقاط المضافة', style: TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (var value = 1; value <= 9; value++) ChoiceChip(label: Text('$value'), selected: _selectedPoints == value, onSelected: (_) => setState(() => _selectedPoints = value), selectedColor: AppTheme.orange, labelStyle: TextStyle(color: _selectedPoints == value ? AppTheme.navy : AppTheme.ivory, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 14),
        SizedBox(height: 54, child: FilledButton.icon(onPressed: _addRound, icon: const Icon(Icons.add_circle_outline), label: Text('أضف $_selectedPoints نقطة إلى ${_teams[_selectedTeam].name}'), style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy))),
        const SizedBox(height: 18),
        if (_rounds.isNotEmpty) ...[
          _label('تفاصيل الجولات — اضغط سلة المهملات لمسح جولة'),
          const SizedBox(height: 7),
          ..._rounds.asMap().entries.toList().reversed.map((entry) {
            final index = entry.key;
            final round = entry.value;
            return ListTile(
              dense: true,
              tileColor: AppTheme.navyLight,
              leading: CircleAvatar(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy, child: Text('${round.round}')),
              title: Text(round.teamName, style: const TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w700)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('+${round.points}', style: const TextStyle(color: AppTheme.orange, fontSize: 19, fontWeight: FontWeight.w900)),
                IconButton(onPressed: () => _removeRound(index), tooltip: 'مسح الجولة', icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
              ]),
            );
          }),
        ],
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: _newMatch, icon: const Icon(Icons.refresh), label: const Text('مباراة جديدة'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.ivory, side: BorderSide(color: AppTheme.ivory.withOpacity(.3)), padding: const EdgeInsets.symmetric(vertical: 15))),
      ];

  Widget _label(String value) => Text(value, style: const TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w800));
}

class _WinnerDialog extends StatelessWidget {
  const _WinnerDialog({required this.team, required this.members, required this.confetti});
  final String team;
  final List<String> members;
  final ConfettiController confetti;
  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: AppTheme.navyLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Stack(alignment: Alignment.center, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('والله وعملوها الرجالة!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.orange, fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('مبروك الفوز لـ $team', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.ivory, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(members.join('، '), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.orange, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 22),
              FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy), child: const Text('تمام')),
            ]),
          ),
          ConfettiWidget(confettiController: confetti, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, numberOfParticles: 35, colors: const [Colors.orange, Colors.yellow, Colors.blue, Colors.pink, Colors.green]),
        ]),
      );
}
