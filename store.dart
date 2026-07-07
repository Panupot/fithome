import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/exercises.dart';
import 'data/programs.dart';
import 'i18n.dart';
import 'notif.dart';
import 'store.dart';

final ValueNotifier<int> appTick = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  L.lang = Store.lang;
  await Notif.init();
  runApp(const FitHomeApp());
}

class FitHomeApp extends StatelessWidget {
  const FitHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: appTick,
      builder: (context, _, __) {
        return MaterialApp(
          title: 'FitHome',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00A86B),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const HomeShell(),
        );
      },
    );
  }
}

// ============================================================
// Shared helpers
// ============================================================

const List<String> muscleKeys = [
  'chest',
  'legs',
  'core',
  'back',
  'shoulders',
  'arms',
  'cardio',
];

const Map<String, IconData> muscleIcons = {
  'chest': Icons.favorite,
  'legs': Icons.directions_walk,
  'core': Icons.circle_outlined,
  'back': Icons.swap_vert,
  'shoulders': Icons.expand,
  'arms': Icons.fitness_center,
  'cardio': Icons.local_fire_department,
};

const Map<String, Color> muscleColors = {
  'chest': Color(0xFFE53935),
  'legs': Color(0xFF1E88E5),
  'core': Color(0xFFFB8C00),
  'back': Color(0xFF8E24AA),
  'shoulders': Color(0xFF00897B),
  'arms': Color(0xFF3949AB),
  'cardio': Color(0xFFD81B60),
};

Exercise exerciseById(String id) =>
    exercises.firstWhere((e) => e.id == id, orElse: () => exercises.first);

String exName(Exercise e) => L.lang == 'th' ? e.nameTh : e.nameEn;

String diffLabel(int d) => L.t('diff$d');

Color diffColor(int d) {
  switch (d) {
    case 1:
      return Colors.green;
    case 2:
      return Colors.orange;
    default:
      return Colors.red;
  }
}

String fmtDate(DateTime d) =>
    '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String fmtClock(int totalSec) {
  final m = totalSec ~/ 60;
  final s = totalSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// ============================================================
// Home shell with bottom navigation
// ============================================================

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LibraryScreen(),
      const ProgramsScreen(),
      const QuickTimerScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.menu_book), label: L.t('tabLibrary')),
          NavigationDestination(
              icon: const Icon(Icons.event_note), label: L.t('tabPrograms')),
          NavigationDestination(
              icon: const Icon(Icons.timer), label: L.t('tabWorkout')),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart), label: L.t('tabHistory')),
          NavigationDestination(
              icon: const Icon(Icons.settings), label: L.t('tabSettings')),
        ],
      ),
    );
  }
}

// ============================================================
// 1) Exercise library
// ============================================================

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';
  String _muscle = 'all';

  @override
  Widget build(BuildContext context) {
    final list = exercises.where((e) {
      final okMuscle = _muscle == 'all' || e.muscle == _muscle;
      final q = _query.trim().toLowerCase();
      final okQuery = q.isEmpty ||
          e.nameEn.toLowerCase().contains(q) ||
          e.nameTh.contains(q);
      return okMuscle && okQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: L.t('searchHint'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip('all', L.t('all')),
              for (final m in muscleKeys) _chip(m, L.t('m_$m')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              final color = muscleColors[e.muscle] ?? Colors.grey;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(muscleIcons[e.muscle], color: color),
                  ),
                  title: Text(exName(e),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${L.t('m_${e.muscle}')} - ${diffLabel(e.difficulty)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(exercise: e)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String key, String label) {
    final selected = _muscle == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _muscle = key),
      ),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final e = exercise;
    final steps = L.lang == 'th' ? e.stepsTh : e.stepsEn;
    final caution = L.lang == 'th' ? e.cautionTh : e.cautionEn;
    final equip = L.lang == 'th' ? e.equipTh : e.equipEn;
    final color = muscleColors[e.muscle] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(title: Text(exName(e))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
                avatar: Icon(muscleIcons[e.muscle], size: 18, color: color),
                label: Text(L.t('m_${e.muscle}')),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(diffLabel(e.difficulty)),
                backgroundColor: diffColor(e.difficulty).withOpacity(0.15),
                labelStyle: TextStyle(color: diffColor(e.difficulty)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${L.t('equipment')}: $equip',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(L.t('howTo'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(steps[i])),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('${L.t('caution')}: $caution')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.play_circle_outline),
            label: Text(L.t('watchVideo')),
            onPressed: () {
              final q = Uri.encodeComponent('${e.nameEn} exercise how to');
              launchUrl(
                Uri.parse('https://www.youtube.com/results?search_query=$q'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 2) Programs
// ============================================================

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final p in programs)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor:
                    diffColor(p.level).withOpacity(0.15),
                child: Icon(Icons.fitness_center, color: diffColor(p.level)),
              ),
              title: Text(L.lang == 'th' ? p.nameTh : p.nameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${L.t('level')}: ${diffLabel(p.level)} - ${p.weeks} ${L.t('weeks')} - ${p.days.length} ${L.t('chooseDay').toLowerCase()}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProgramDetailScreen(program: p)),
              ),
            ),
          ),
      ],
    );
  }
}

class ProgramDetailScreen extends StatelessWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final p = program;
    return Scaffold(
      appBar: AppBar(title: Text(L.lang == 'th' ? p.nameTh : p.nameEn)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(L.lang == 'th' ? p.descTh : p.descEn),
          const SizedBox(height: 16),
          Text(L.t('chooseDay'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final day in p.days)
            Card(
              child: ExpansionTile(
                title: Text(L.lang == 'th' ? day.nameTh : day.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    Text('${day.items.length} ${L.t('exercisesCount')}'),
                children: [
                  for (final item in day.items)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        muscleIcons[exerciseById(item.exerciseId).muscle],
                        color: muscleColors[
                            exerciseById(item.exerciseId).muscle],
                      ),
                      title: Text(exName(exerciseById(item.exerciseId))),
                      subtitle: Text(item.seconds > 0
                          ? '${item.sets} ${L.t('set')} x ${item.seconds} ${L.t('seconds')}'
                          : '${item.sets} ${L.t('set')} x ${item.reps} ${L.t('reps')}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseDetailScreen(
                              exercise: exerciseById(item.exerciseId)),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(L.t('start')),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutPlayerScreen(
                              day: day,
                              programName:
                                  L.lang == 'th' ? p.nameTh : p.nameEn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Workout player
// ============================================================

enum Phase { ready, work, rest, done }

class WorkoutPlayerScreen extends StatefulWidget {
  final ProgramDay day;
  final String programName;

  const WorkoutPlayerScreen(
      {super.key, required this.day, required this.programName});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late DateTime _startedAt;
  int _itemIdx = 0;
  int _setNum = 1;
  Phase _phase = Phase.ready;
  int _remaining = 5;
  Timer? _ticker;
  bool _saved = false;

  ProgramExercise get _item => widget.day.items[_itemIdx];
  Exercise get _exercise => exerciseById(_item.exerciseId);
  bool get _isLastSetOfLastItem =>
      _itemIdx == widget.day.items.length - 1 && _setNum == _item.sets;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _startCountdown(5);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _ticker?.cancel();
    setState(() => _remaining = seconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        HapticFeedback.vibrate();
        _onCountdownEnd();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _onCountdownEnd() {
    switch (_phase) {
      case Phase.ready:
        _beginWork();
        break;
      case Phase.work:
        _endSet();
        break;
      case Phase.rest:
        _afterRest();
        break;
      case Phase.done:
        break;
    }
  }

  void _beginWork() {
    setState(() => _phase = Phase.work);
    if (_item.seconds > 0) {
      _startCountdown(_item.seconds);
    } else {
      _ticker?.cancel();
      setState(() => _remaining = 0);
    }
  }

  void _endSet() {
    if (_isLastSetOfLastItem) {
      _finish();
      return;
    }
    setState(() => _phase = Phase.rest);
    _startCountdown(_item.restSec);
  }

  void _afterRest() {
    if (_setNum < _item.sets) {
      setState(() => _setNum++);
    } else {
      setState(() {
        _itemIdx++;
        _setNum = 1;
      });
    }
    _beginWork();
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    setState(() => _phase = Phase.done);
    if (!_saved) {
      _saved = true;
      final mins =
          (DateTime.now().difference(_startedAt).inSeconds / 60).ceil();
      await Store.addSession(SessionRecord(
        date: _startedAt,
        programName:
            '${widget.programName} - ${L.lang == 'th' ? widget.day.nameTh : widget.day.nameEn}',
        minutes: mins,
        exerciseCount: widget.day.items.length,
      ));
    }
  }

  Future<bool> _confirmExit() async {
    if (_phase == Phase.done) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L.t('stopWorkout')),
        content: Text(L.t('confirmStop')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L.t('stay'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(L.t('exit'))),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final dayName = L.lang == 'th' ? widget.day.nameTh : widget.day.nameEn;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(dayName)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _phase == Phase.done ? _doneView() : _activeView(),
          ),
        ),
      ),
    );
  }

  Widget _activeView() {
    final e = _exercise;
    final steps = L.lang == 'th' ? e.stepsTh : e.stepsEn;
    final total = widget.day.items.length;
    final isRest = _phase == Phase.rest;
    final isReady = _phase == Phase.ready;

    String heading;
    if (isReady) {
      heading = L.t('getReady');
    } else if (isRest) {
      heading = L.t('rest');
    } else {
      heading = exName(e);
    }

    // During rest before a NEW exercise, show the next exercise name.
    Exercise? nextEx;
    if (isRest && _setNum >= _item.sets &&
        _itemIdx + 1 < widget.day.items.length) {
      nextEx = exerciseById(widget.day.items[_itemIdx + 1].exerciseId);
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_itemIdx + (_setNum - 1) / _item.sets) / total,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
            '${L.t('exercisesCount')} ${_itemIdx + 1}/$total   -   ${L.t('set')} $_setNum/${_item.sets}'),
        const SizedBox(height: 16),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (nextEx != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${L.t('nextUp')}: ${exName(nextEx)}',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: isRest || isReady || _item.seconds > 0
                ? Text(
                    fmtClock(_remaining),
                    style: TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                      color: isRest
                          ? Colors.blue
                          : (isReady ? Colors.grey : Colors.green.shade700),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_item.reps}',
                        style: const TextStyle(
                            fontSize: 88, fontWeight: FontWeight.bold),
                      ),
                      Text(L.t('reps'),
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
          ),
        ),
        if (!isRest && !isReady)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(steps.first, textAlign: TextAlign.center),
          ),
        const SizedBox(height: 16),
        if (_phase == Phase.work && _item.seconds == 0)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _endSet,
              child: Text(L.t('doneSet'),
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        if (isRest)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                _ticker?.cancel();
                _afterRest();
              },
              child: Text(L.t('skipRest')),
            ),
          ),
      ],
    );
  }

  Widget _doneView() {
    final mins = (DateTime.now().difference(_startedAt).inSeconds / 60).ceil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 96, color: Colors.amber),
          const SizedBox(height: 16),
          Text(L.t('workoutComplete'),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${L.t('duration')}: $mins ${L.t('minutes')}'),
          Text(L.t('saved'), style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(L.t('finishWorkout')),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3) Quick HIIT timer
// ============================================================

class QuickTimerScreen extends StatefulWidget {
  const QuickTimerScreen({super.key});

  @override
  State<QuickTimerScreen> createState() => _QuickTimerScreenState();
}

class _QuickTimerScreenState extends State<QuickTimerScreen> {
  int _workSec = 40;
  int _restSec = 20;
  int _rounds = 8;

  int _round = 1;
  bool _working = true;
  bool _running = false;
  bool _paused = false;
  bool _finished = false;
  int _remaining = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _paused = false;
      _finished = false;
      _round = 1;
      _working = true;
      _remaining = _workSec;
    });
    _tick();
  }

  void _tick() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return;
      if (_remaining <= 1) {
        HapticFeedback.vibrate();
        if (_working) {
          if (_round >= _rounds) {
            t.cancel();
            setState(() {
              _running = false;
              _finished = true;
            });
            return;
          }
          setState(() {
            _working = false;
            _remaining = _restSec;
          });
        } else {
          setState(() {
            _working = true;
            _round++;
            _remaining = _workSec;
          });
        }
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _paused = false;
      _finished = false;
      _round = 1;
      _working = true;
      _remaining = 0;
    });
  }

  Widget _stepper(String label, int value, void Function(int) onChanged,
      {int min = 5, int step = 5}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _running
                  ? null
                  : () {
                      if (value - step >= min) onChanged(value - step);
                    },
            ),
            SizedBox(
              width: 48,
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _running ? null : () => onChanged(value + step),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(L.t('quickTimer'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(L.t('freeWorkout'),
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        _stepper('${L.t('work')} (${L.t('seconds')})', _workSec,
            (v) => setState(() => _workSec = v)),
        _stepper('${L.t('rest')} (${L.t('seconds')})', _restSec,
            (v) => setState(() => _restSec = v)),
        _stepper(L.t('rounds'), _rounds, (v) => setState(() => _rounds = v),
            min: 1, step: 1),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: _finished
                ? Colors.amber.withOpacity(0.2)
                : (_running
                    ? (_working
                        ? Colors.green.withOpacity(0.12)
                        : Colors.blue.withOpacity(0.12))
                    : Theme.of(context).colorScheme.surfaceVariant),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                _finished
                    ? L.t('timerDone')
                    : (_running
                        ? '${_working ? L.t('work') : L.t('rest')}  -  ${L.t('round')} $_round/$_rounds'
                        : '${L.t('round')} 1/$_rounds'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                fmtClock(_running || _finished ? _remaining : _workSec),
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: _working ? Colors.green.shade700 : Colors.blue,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _running
                      ? () => setState(() => _paused = !_paused)
                      : _start,
                  child: Text(
                    _running
                        ? (_paused ? L.t('resume') : L.t('pause'))
                        : L.t('startTimer'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _reset,
                child: Text(L.t('reset')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// 4) History
// ============================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = Store.history;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _statCard(Icons.local_fire_department, Colors.orange,
                  '${Store.streakDays}', '${L.t('streak')} (${L.t('days')})'),
              _statCard(Icons.calendar_today, Colors.blue,
                  '${Store.sessionsThisWeek}',
                  '${L.t('thisWeek')} (${L.t('times')})'),
              _statCard(Icons.emoji_events, Colors.green,
                  '${Store.totalSessions}', L.t('totalSessions')),
            ],
          ),
        ),
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Text(L.t('historyEmpty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, i) {
                    final r = history[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.check, color: Colors.green)),
                        title: Text(r.programName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${fmtDate(r.date)}\n${r.exerciseCount} ${L.t('exercisesCount')} - ${r.minutes} ${L.t('minutes')}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
        if (history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(L.t('deleteHistory'),
                  style: const TextStyle(color: Colors.red)),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(L.t('deleteHistory')),
                    content: Text(L.t('confirmDelete')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(L.t('cancel'))),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(L.t('delete'),
                              style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (ok == true) {
                  await Store.clearHistory();
                  setState(() {});
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 5) Settings
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _applyReminder() async {
    if (Store.reminderOn) {
      await Notif.requestPermission();
      await Notif.scheduleDaily(Store.reminderHour, Store.reminderMinute);
    } else {
      await Notif.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
        hour: Store.reminderHour, minute: Store.reminderMinute);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(L.t('language')),
              ),
              RadioListTile<String>(
                title: const Text('ไทย'),
                value: 'th',
                groupValue: L.lang,
                onChanged: (v) async {
                  L.lang = 'th';
                  await Store.setLang('th');
                  await _applyReminder();
                  appTick.value++;
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: L.lang,
                onChanged: (v) async {
                  L.lang = 'en';
                  await Store.setLang('en');
                  await _applyReminder();
                  appTick.value++;
                },
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: Text(L.t('reminder')),
                value: Store.reminderOn,
                onChanged: (v) async {
                  await Store.setReminder(
                      v, Store.reminderHour, Store.reminderMinute);
                  await _applyReminder();
                  setState(() {});
                },
              ),
              ListTile(
                enabled: Store.reminderOn,
                leading: const Icon(Icons.access_time),
                title: Text(L.t('reminderTime')),
                trailing: Text(time.format(context),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: time);
                  if (picked != null) {
                    await Store.setReminder(
                        Store.reminderOn, picked.hour, picked.minute);
                    await _applyReminder();
                    setState(() {});
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(L.t('notifNote'),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(L.t('about')),
            subtitle: Text(L.t('aboutText')),
          ),
        ),
      ],
    );
  }
}
