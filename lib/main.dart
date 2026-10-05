import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const red = Color(0xFFAD232C);
const ink = Color(0xFF18191C);
const bg = Color(0xFFF5F4F1);
const muted = Color(0xFF686B73);
const line = Color(0xFFE7E5E1);

void main() => runApp(const IituApp());

class IituApp extends StatelessWidget {
  const IituApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IITU Student Hub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: red,
        primary: red,
        secondary: ink,
        surface: Colors.white,
        error: const Color(0xFFBA1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F8F7),
        contentPadding: const EdgeInsets.all(17),
        errorMaxLines: 3,
        helperMaxLines: 3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red, width: 2),
        ),
      ),
    ),
    home: const StudentHub(),
  );
}

class UniversityLogo extends StatelessWidget {
  const UniversityLogo({
    super.key,
    this.width = 170,
  });

  final double width;

  @override
  Widget build(BuildContext context) => Image.memory(
    logoBytes,
    width: width,
    height: width * 34 / 207,
    fit: BoxFit.contain,
    semanticLabel:
    'International Information Technology University',
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = 24,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: line),
    ),
    child: Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    ),
  );
}

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: hovered
            ? const Color(0xFFFFF8F8)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hovered ? red : line,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: red,
                      size: 26,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_outward,
                      size: 18,
                      color: muted,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class StudentHub extends StatefulWidget {
  const StudentHub({super.key});

  @override
  State<StudentHub> createState() => _StudentHubState();
}

class _StudentHubState extends State<StudentHub> {
  static const pages = [
    'Overview',
    'Schedule',
    'Campus',
    'Requests',
    'Profile',
  ];

  static const icons = [
    Icons.dashboard_outlined,
    Icons.calendar_month_outlined,
    Icons.explore_outlined,
    Icons.inbox_outlined,
    Icons.person_outline,
  ];

  final store = SharedPreferencesAsync();

  int page = 0;
  int weekday = DateTime.now().weekday <= 5
      ? DateTime.now().weekday - 1
      : 0;

  bool loaded = false;

  String name = 'Azhar Akhmetova';
  String studentId = 'I26043015';
  String programme = 'Network Security';
  String email = '';

  List<String> reminders = [];
  Set<String> registered = {};
  Set<String> bookmarks = {};
  List<Map<String, String>> requests = [];

  String resourceQuery = '';

  static const events = [
    {
      'id': 'security',
      'day': '15',
      'month': 'OCT',
      'title': 'Cybersecurity workshop',
      'type': 'WORKSHOP',
      'time': '16:00 · Main building',
      'description':
      'A sample hands-on session on phishing, safe authentication '
          'and incident reporting. Bring a laptop. This is a demonstration '
          'event, not an official IITU announcement.',
    },
    {
      'id': 'career',
      'day': '19',
      'month': 'OCT',
      'title': 'Your first tech internship',
      'type': 'CAREER',
      'time': '14:00 · Career space',
      'description':
      'A sample session on preparing a CV, building a portfolio '
          'and practising interview questions. Registration here '
          'is local to your browser.',
    },
    {
      'id': 'community',
      'day': '23',
      'month': 'OCT',
      'title': 'Student community meetup',
      'type': 'COMMUNITY',
      'time': '17:00 · Student space',
      'description':
      'A demonstration meetup for discovering student clubs and '
          'finding teammates for projects. This listing is sample content.',
    },
  ];

  static const resources = [
    {
      'title': 'Library guide',
      'tag': 'STUDY',
      'body':
      'Plan your reading list, organise sources by course and '
          'record citations while you study. For actual book availability, '
          'check with the university library.',
    },
    {
      'title': 'Internship checklist',
      'tag': 'CAREER',
      'body':
      'Prepare a one-page CV, add two relevant projects, practise '
          'a short introduction and keep a list of application deadlines.',
    },
    {
      'title': 'Account security',
      'tag': 'IT SUPPORT',
      'body':
      'Use a unique password, enable multi-factor authentication '
          'and never share login codes. Report suspicious messages '
          'through a campus support request.',
    },
    {
      'title': 'Exchange preparation',
      'tag': 'MOBILITY',
      'body':
      'Prepare your transcript, course comparison, language '
          'certificate and a budget. Confirm current deadlines and '
          'eligibility with the responsible university office.',
    },
  ];

  @override
  void initState() {
    super.initState();
    restore();
  }

  // Browser storage preserves actions between visits.
  // It is local storage, not a university server.
  Future<void> restore() async {
    try {
      final data = await store.getString('iitu_hub_v3');
      final oldReminders =
      await store.getStringList('iitu_tasks_restored');

      if (!mounted) return;

      if (data != null) {
        final m = jsonDecode(data) as Map<String, dynamic>;

        name = m['name'] as String? ?? name;
        studentId = m['id'] as String? ?? studentId;
        programme = m['programme'] as String? ?? programme;
        email = m['email'] as String? ?? '';

        reminders = List<String>.from(m['reminders'] ?? []);
        registered = Set<String>.from(m['registered'] ?? []);
        bookmarks = Set<String>.from(m['bookmarks'] ?? []);

        requests = (m['requests'] as List? ?? [])
            .map((r) => Map<String, String>.from(r as Map))
            .toList();
      } else {
        reminders = oldReminders ?? [];

        name =
            await store.getString('iitu_name_restored') ?? name;
        studentId =
            await store.getString('iitu_id_restored') ?? studentId;
        programme =
            await store.getString('iitu_programme_restored') ??
                programme;
        email =
            await store.getString('iitu_email_restored') ?? '';
      }
    } catch (_) {
      if (mounted) {
        message('Saved data could not be loaded.');
      }
    }

    if (mounted) {
      setState(() => loaded = true);
    }
  }

  Future<void> persist() async {
    try {
      await store.setString(
        'iitu_hub_v3',
        jsonEncode({
          'name': name,
          'id': studentId,
          'programme': programme,
          'email': email,
          'reminders': reminders,
          'registered': registered.toList(),
          'bookmarks': bookmarks.toList(),
          'requests': requests,
        }),
      );
    } catch (_) {
      if (mounted) {
        message(
          'Changes are available in this session, '
              'but browser storage failed.',
        );
      }
    }
  }

  void message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );

  void go(int value) {
    setState(() {
      if (page != value) resourceQuery = '';
      page = value;
    });
  }

  Future<void> addReminder([String initial = '']) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => ReminderDialog(initial: initial),
    );

    if (!mounted || value == null || value.isEmpty) return;

    setState(() => reminders.add(value));
    await persist();

    if (mounted) {
      message('Reminder added to your plan.');
    }
  }

  void completeReminder(int index) {
    final task = reminders[index];

    setState(() => reminders.removeAt(index));
    persist();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Reminder completed.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;

              setState(
                    () => reminders.insert(
                  index.clamp(0, reminders.length).toInt(),
                  task,
                ),
              );
              persist();
            },
          ),
        ),
      );
  }

  Future<void> openRequest() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CampusRequestPage(
          student: {
            'name': name,
            'id': studentId,
            'email': email,
          },
          onRecord: (record) async {
            if (!mounted) return;

            setState(() => requests.insert(0, record));
            await persist();
          },
        ),
      ),
    );
  }

  Future<void> eventDetails(Map<String, String> event) async {
    final joined = registered.contains(event['id']);

    final change = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(event['title']!),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event['day']} ${event['month']} · ${event['time']}',
              ),
              const SizedBox(height: 16),
              Text(event['description']!),
              const SizedBox(height: 16),
              Text(
                joined
                    ? 'You have a local demo registration.'
                    : 'Demo registration will be saved on this browser.',
                style: const TextStyle(color: muted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(
              joined
                  ? 'Cancel registration'
                  : 'Register for demo',
            ),
          ),
        ],
      ),
    );

    if (!mounted || change != true) return;

    setState(() {
      if (joined) {
        registered.remove(event['id']);
      } else {
        registered.add(event['id']!);
      }
    });

    await persist();

    if (mounted) {
      message(
        joined
            ? 'Registration cancelled.'
            : 'Demo registration saved.',
      );
    }
  }

  Future<void> resourceDetails(Map<String, String> item) async {
    final saved = bookmarks.contains(item['title']);

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(item['title']!),
        content: SingleChildScrollView(
          child: Text(item['body']!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(c, true),
            icon: Icon(
              saved
                  ? Icons.bookmark_remove
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(
              saved ? 'Remove bookmark' : 'Save resource',
            ),
          ),
        ],
      ),
    );

    if (!mounted || result != true) return;

    setState(() {
      if (saved) {
        bookmarks.remove(item['title']);
      } else {
        bookmarks.add(item['title']!);
      }
    });

    await persist();
  }

  Future<void> editProfile() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ProfileDialog(
        data: {
          'name': name,
          'id': studentId,
          'programme': programme,
          'email': email,
        },
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      name = result['name']!;
      studentId = result['id']!;
      programme = result['programme']!;
      email = result['email']!;
    });

    await persist();
  }

  Widget title(String text, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(color: muted),
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget heading(String text, {Widget? action}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null) action,
      ],
    ),
  );

  Widget grid(
      List<Widget> children, {
        double minWidth = 240,
      }) =>
      LayoutBuilder(
        builder: (c, box) {
          final columns =
          (box.maxWidth / minWidth).floor().clamp(1, 3);
          final width =
              (box.maxWidth - 16 * (columns - 1)) / columns;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final child in children)
                SizedBox(width: width, child: child),
            ],
          );
        },
      );

  Widget split(Widget a, Widget b) => LayoutBuilder(
    builder: (c, box) => box.maxWidth >= 850
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: a),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: b),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        a,
        const SizedBox(height: 24),
        b,
      ],
    ),
  );

  Widget hero() => LayoutBuilder(
    builder: (c, box) => ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF19191D),
              Color(0xFF41151D),
              Color(0xFF8D202B),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CampusPattern(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                box.maxWidth > 650 ? 40 : 26,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IITU  /  STUDENT EXPERIENCE',
                    style: TextStyle(
                      color: Color(0xFFE9BFC3),
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'More possibilities.\nLess campus chaos.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: box.maxWidth > 650 ? 46 : 33,
                      height: 1.08,
                      letterSpacing: -1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 460,
                    child: Text(
                      'Your schedule, student services and next '
                          'opportunity — organised around you.',
                      style: TextStyle(
                        color: Color(0xFFE4DADC),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: openRequest,
                        icon: const Icon(
                          Icons.arrow_outward,
                          size: 19,
                        ),
                        label:
                        const Text('Get campus support'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ink,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => go(2),
                        icon: const Icon(
                          Icons.explore_outlined,
                          size: 20,
                        ),
                        label: const Text('Explore campus'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'ALMATY, KAZAKHSTAN  ·  '
                        'INTERNATIONAL IT UNIVERSITY',
                    style: TextStyle(
                      color: Color(0xFFCAB4B8),
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  List<Map<String, String>> lessons(int day) {
    const subjects = [
      'Cross-platform development',
      'Network security',
      'Machine learning',
      'Cloud & virtualization',
      'ERP programming',
    ];

    return [
      {
        'time': '09:00',
        'end': '10:20',
        'title': subjects[day],
        'room': 'Room ${201 + day * 10}',
        'type': 'Lecture',
      },
      {
        'time': '11:00',
        'end': '12:20',
        'title': subjects[(day + 2) % 5],
        'room': 'Lab ${302 + day}',
        'type': 'Practice',
      },
    ];
  }

  Widget lessonRow(Map<String, String> lesson) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        SizedBox(
          width: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson['time']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                lesson['end']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        Container(width: 3, height: 42, color: red),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${lesson['room']} · ${lesson['type']}',
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Add lesson reminder',
          onPressed: () => addReminder(
            '${lesson['title']} · ${lesson['time']} · '
                '${lesson['room']}',
          ),
          icon: const Icon(
            Icons.add_alert_outlined,
            size: 20,
          ),
        ),
      ],
    ),
  );

  Widget reminderPanel() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Your next steps',
          action: IconButton(
            tooltip: 'Add reminder',
            onPressed: () => addReminder(),
            icon: const Icon(Icons.add),
          ),
        ),
        if (reminders.isEmpty) ...[
          const Icon(
            Icons.checklist_rounded,
            size: 36,
            color: muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Make room for what matters.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a deadline, a class or a small task. '
                'Complete it here when you are done.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => addReminder(),
            child: const Text('Add your first reminder'),
          ),
        ] else
          for (var i = 0; i < reminders.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity:
              ListTileControlAffinity.leading,
              value: false,
              title: Text(reminders[i]),
              onChanged: (_) => completeReminder(i),
            ),
      ],
    ),
  );

  Widget eventCard(Map<String, String> event) => Panel(
    padding: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    event['day']!,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    event['month']!,
                    style: const TextStyle(
                      color: red,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (registered.contains(event['id']))
              const Icon(
                Icons.check_circle_outline,
                color: red,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          event['type']!,
          style: const TextStyle(
            color: red,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event['title']!,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event['time']!,
          style: const TextStyle(
            color: muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => eventDetails(event),
          icon: Icon(
            registered.contains(event['id'])
                ? Icons.how_to_reg_outlined
                : Icons.arrow_outward,
            size: 18,
          ),
          label: Text(
            registered.contains(event['id'])
                ? 'Manage registration'
                : 'View event',
          ),
        ),
      ],
    ),
  );

  Widget overview() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title(
        'Welcome back, ${name.trim().split(' ').first}.',
        'A clearer view of your campus day.',
      ),
      hero(),
      const SizedBox(height: 28),
      grid([
        ActionTile(
          title: 'Your timetable',
          subtitle: 'Plan your study week',
          icon: Icons.calendar_month_outlined,
          onTap: () => go(1),
        ),
        ActionTile(
          title: 'Campus helpdesk',
          subtitle: 'Create and review a request',
          icon: Icons.support_agent,
          onTap: openRequest,
        ),
        ActionTile(
          title: 'Student resources',
          subtitle: 'Guides, tools and opportunities',
          icon: Icons.menu_book_outlined,
          onTap: () => go(2),
        ),
      ]),
      const SizedBox(height: 28),
      split(
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(
                'Your study day',
                action: TextButton(
                  onPressed: () => go(1),
                  child: const Text('Full schedule'),
                ),
              ),
              const Text(
                'Example timetable · not synced with IITU',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
              for (final lesson in lessons(weekday))
                lessonRow(lesson),
            ],
          ),
        ),
        reminderPanel(),
      ),
      const SizedBox(height: 28),
      heading(
        'Beyond the classroom',
        action: TextButton(
          onPressed: () => go(2),
          child: const Text('Explore'),
        ),
      ),
      grid(
        events.map(eventCard).toList(),
        minWidth: 270,
      ),
      const SizedBox(height: 14),
      const Text(
        'Events above are sample listings for this student project.',
        style: TextStyle(color: muted, fontSize: 12),
      ),
    ],
  );

  Widget schedule() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title(
        'Make the week work for you.',
        'Example timetable for Network Security. '
            'Add a reminder directly from a lesson.',
      ),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < 5; i++)
            ChoiceChip(
              label: Text(
                [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                ][i],
              ),
              selected: weekday == i,
              onSelected: (_) => setState(() => weekday = i),
            ),
        ],
      ),
      const SizedBox(height: 24),
      split(
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(
                [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                ][weekday],
              ),
              for (final lesson in lessons(weekday)) ...[
                lessonRow(lesson),
                const Divider(color: line),
              ],
              const SizedBox(height: 12),
              const Text(
                'Room numbers and classes are illustrative. '
                    'Confirm your actual schedule with IITU.',
                style: TextStyle(color: muted),
              ),
            ],
          ),
        ),
        reminderPanel(),
      ),
    ],
  );

  Widget campus() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title(
        'Find your next opportunity.',
        'Useful resources, student experiences '
            'and support in one place.',
      ),
      heading('Campus experiences'),
      grid(
        events.map(eventCard).toList(),
        minWidth: 270,
      ),
      const SizedBox(height: 12),
      const Text(
        'Sample events · local demo registrations',
        style: TextStyle(color: muted, fontSize: 12),
      ),
      const SizedBox(height: 32),
      heading('Resource library'),
      TextField(
        onChanged: (value) => setState(
              () => resourceQuery = value.toLowerCase().trim(),
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Search guides',
          hintText: 'Try library, security, internship…',
        ),
      ),
      const SizedBox(height: 16),
      if (!resources.any(
            (r) => '${r['title']} ${r['tag']} ${r['body']}'
            .toLowerCase()
            .contains(resourceQuery),
      ))
        const Panel(
          child: Text(
            'No matching resources. Try a different keyword.',
          ),
        ),
      grid([
        for (final r in resources)
          if ('${r['title']} ${r['tag']} ${r['body']}'
              .toLowerCase()
              .contains(resourceQuery))
            ActionTile(
              title:
              '${bookmarks.contains(r['title']) ? '★ ' : ''}'
                  '${r['title']}',
              subtitle: r['tag']!,
              icon: Icons.article_outlined,
              onTap: () => resourceDetails(r),
            ),
      ]),
      const SizedBox(height: 28),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Need a person, not another page?'),
            const Text(
              'Describe your issue and choose the campus '
                  'team best placed to help.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: openRequest,
              icon: const Icon(Icons.support_agent),
              label: const Text('Open campus helpdesk'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget requestHistory() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title(
        'Support, with a clear record.',
        'Your demo requests are saved in this browser. '
            'They are not sent to university staff.',
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: openRequest,
          icon: const Icon(Icons.add),
          label: const Text('Create a request'),
        ),
      ),
      const SizedBox(height: 24),
      if (requests.isEmpty)
        const Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: muted,
              ),
              SizedBox(height: 16),
              Text(
                'A place for every request.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Submit a campus service request to see '
                    'its reference and summary here.',
                style: TextStyle(color: muted),
              ),
            ],
          ),
        )
      else
        for (final request in requests)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['Reference'] ?? '',
                    style: const TextStyle(
                      color: red,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request['Request subject'] ?? '',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${request['Campus service']} · '
                        '${request['Urgency']} urgency',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Recorded locally · Demo',
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Request summary'),
                        content: SizedBox(
                          width: 500,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final e
                                in request.entries)
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          e.key,
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight
                                                .w700,
                                          ),
                                        ),
                                        SelectableText(
                                          e.value.isEmpty
                                              ? 'Not provided'
                                              : e.value,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(c),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                    ),
                    label:
                    const Text('Read full request'),
                  ),
                ],
              ),
            ),
          ),
    ],
  );

  Widget profile() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      title(
        'Your student space.',
        'Keep your profile, saved resources '
            'and registrations together.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: ink,
              child: Text(
                name.isEmpty ? 'A' : name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$studentId · $programme',
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 8),
            Text(
              email.isEmpty
                  ? 'Add your campus email in Edit profile.'
                  : email,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: editProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit profile'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      heading('Saved resources'),
      if (bookmarks.isEmpty)
        const Panel(
          child: Text(
            'Save a resource from Campus to find it here.',
          ),
        )
      else
        grid([
          for (final r in resources)
            if (bookmarks.contains(r['title']))
              ActionTile(
                title: r['title']!,
                subtitle: r['tag']!,
                icon: Icons.bookmark_outline,
                onTap: () => resourceDetails(r),
              ),
        ]),
      const SizedBox(height: 28),
      heading('Your registrations'),
      if (registered.isEmpty)
        const Panel(
          child: Text(
            'No demo registrations yet. '
                'Explore campus events to get started.',
          ),
        )
      else
        grid(
          [
            for (final event in events)
              if (registered.contains(event['id']))
                eventCard(event),
          ],
          minWidth: 270,
        ),
    ],
  );

  Widget navigation({bool drawer = false}) => Container(
    color: Colors.white,
    width: 230,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding:
            const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UniversityLogo(width: 180),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  programme,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'STUDENT HUB',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < pages.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                minLeadingWidth: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                selected: page == i,
                selectedColor: red,
                selectedTileColor:
                const Color(0xFFF9ECEE),
                leading: Icon(icons[i], size: 22),
                title: Text(
                  pages[i],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  if (drawer) Navigator.pop(context);
                  go(i);
                },
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.support_agent,
                  color: red,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Need a hand?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start with campus support.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (drawer) Navigator.pop(context);
                    openRequest();
                  },
                  child: const Text('Create a request →'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Student project · Demo data',
            style: TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, box) {
      final desktop = box.maxWidth >= 1100;

      return Scaffold(
        drawer: Drawer(
          child: navigation(drawer: true),
        ),
        appBar: AppBar(
          title: Row(
            children: [
              const UniversityLogo(width: 150),
              if (box.maxWidth >= 600) ...[
                const SizedBox(width: 24),
                const Text(
                  'Student Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (desktop)
              TextButton.icon(
                onPressed: () => go(4),
                icon: const Icon(Icons.person_outline),
                label: Text(name),
              ),
            IconButton(
              tooltip: 'My reminders',
              onPressed: () => go(1),
              icon: const Icon(Icons.checklist),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: loaded
            ? FloatingActionButton(
          tooltip: 'Add a student reminder',
          backgroundColor: red,
          foregroundColor: Colors.white,
          onPressed: () => addReminder(),
          child: const Icon(Icons.add),
        )
            : null,
        bottomNavigationBar: desktop
            ? null
            : BottomNavigationBar(
          currentIndex: page,
          onTap: go,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: red,
          unselectedItemColor: muted,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: [
            for (var i = 0; i < pages.length; i++)
              BottomNavigationBarItem(
                icon: Icon(icons[i]),
                label: pages[i],
              ),
          ],
        ),
        body: Row(
          children: [
            if (desktop) navigation(),
            Expanded(
              child: SafeArea(
                child: !loaded
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : Column(
                  children: [
                    if (desktop)
                      Container(
                        height: 52,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: line,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Student Hub  /  '
                                  '${pages[page]}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'YOUR CAMPUS, CONNECTED',
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(
                          desktop ? 32 : 18,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                            const BoxConstraints(
                              maxWidth: 1320,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                              children: [
                                AnimatedSwitcher(
                                  duration:
                                  const Duration(
                                    milliseconds: 220,
                                  ),
                                  child: KeyedSubtree(
                                    key:
                                    ValueKey(page),
                                    child: [
                                      overview,
                                      schedule,
                                      campus,
                                      requestHistory,
                                      profile,
                                    ][page](),
                                  ),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                const Divider(
                                  color: line,
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                Wrap(
                                  alignment:
                                  WrapAlignment
                                      .spaceBetween,
                                  spacing: 20,
                                  runSpacing: 12,
                                  children: [
                                    const UniversityLogo(
                                      width: 155,
                                    ),
                                    const Text(
                                      'Designed for student life.\n'
                                          'Educational prototype · '
                                          'not an official university service',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class CampusPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 8; i++) {
      final x = size.width * .72 + i * 34;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            -40 + i * 24,
            150,
            size.height + 80,
          ),
          const Radius.circular(32),
        ),
        p,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .9, size.height * .7),
      140,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}

class ReminderDialog extends StatefulWidget {
  const ReminderDialog({
    super.key,
    this.initial = '',
  });

  final String initial;

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late final controller =
  TextEditingController(text: widget.initial);
  final key = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    if (key.currentState!.validate()) {
      Navigator.pop(context, controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Make a small plan'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => save(),
          validator: (v) => (v ?? '').trim().isEmpty
              ? 'Write a reminder first.'
              : null,
          decoration: const InputDecoration(
            labelText: 'Reminder',
            hintText: 'Finish my lab report before Tuesday',
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: save,
        child: const Text('Save reminder'),
      ),
    ],
  );
}

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({
    super.key,
    required this.data,
  });

  final Map<String, String> data;

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final key = GlobalKey<FormState>();

  late final inputs = {
    for (final e in widget.data.entries)
      e.key: TextEditingController(text: e.value),
  };

  @override
  void dispose() {
    for (final c in inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit student profile'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in inputs.entries)
                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: e.value,
                    keyboardType: e.key == 'email'
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: {
                        'name': 'Full name',
                        'id': 'Student ID',
                        'programme': 'Programme',
                        'email': 'Campus email (optional)',
                      }[e.key],
                    ),
                    validator: (raw) {
                      final v = (raw ?? '').trim();

                      if (e.key == 'email') {
                        return v.isNotEmpty &&
                            !RegExp(
                              r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$',
                            ).hasMatch(v)
                            ? 'Enter a valid email.'
                            : null;
                      }

                      if (e.key == 'id') {
                        return !RegExp(
                          r'^[A-Za-z0-9]{6,12}$',
                        ).hasMatch(v)
                            ? 'Use 6–12 letters or digits.'
                            : null;
                      }

                      return v.isEmpty
                          ? 'Complete this field.'
                          : null;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (key.currentState!.validate()) {
            Navigator.pop(
              context,
              {
                for (final e in inputs.entries)
                  e.key: e.value.text.trim(),
              },
            );
          }
        },
        child: const Text('Save profile'),
      ),
    ],
  );
}

class CampusRequestPage extends StatefulWidget {
  const CampusRequestPage({
    super.key,
    required this.student,
    required this.onRecord,
  });

  final Map<String, String> student;
  final Future<void> Function(Map<String, String>) onRecord;

  @override
  State<CampusRequestPage> createState() =>
      _CampusRequestPageState();
}

class _CampusRequestPageState extends State<CampusRequestPage> {
  // 1. The key provides access to validate, save and reset.
  final formKey = GlobalKey<FormState>();

  final inputs = {
    for (final k in [
      'name',
      'id',
      'email',
      'phone',
      'subject',
      'details',
      'room',
    ])
      k: TextEditingController(),
  };

  final saved = <String, String>{};

  String? category;
  int generation = 0;
  bool busy = false;
  bool submitted = false;

  static const services = [
    'IT support',
    'Library',
    'Career Center',
    'Facilities',
    'Student activities',
    'Academic support',
  ];

  DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  void message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );

  // 2. Controllers are released when the screen is removed.
  @override
  void dispose() {
    for (final c in inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  // 3. Specific error messages preserve all other valid entries.
  String? validate(String key, String? raw) {
    final v = (raw ?? '').trim();

    switch (key) {
      case 'name':
        return v
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .length <
            2
            ? 'Enter your first and last name.'
            : null;

      case 'id':
        return !RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(v)
            ? 'Use 6–12 letters or digits without spaces.'
            : null;

      case 'email':
        return !RegExp(
          r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$',
        ).hasMatch(v)
            ? 'Enter an email with @ and a valid domain.'
            : null;

      case 'phone':
        return v.isNotEmpty &&
            !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)
            ? 'Use 7–15 digits and an optional leading +.'
            : null;

      case 'subject':
        return v.length < 5
            ? 'Describe the topic in at least 5 characters.'
            : null;

      case 'details':
        return v.length < 20 || v.length > 500
            ? 'Explain your request in 20–500 characters.'
            : null;

      case 'room':
        return v.isEmpty
            ? 'Enter the room or campus location.'
            : null;
    }

    return null;
  }

  Widget field(
      String key,
      String label,
      IconData icon, {
        String? hint,
        String? helper,
        TextInputType keyboard = TextInputType.text,
        int lines = 1,
        int? limit,
      }) =>
      CampusTextField(
        controller: inputs[key]!,
        label: label,
        icon: icon,
        hint: hint,
        helper: helper,
        keyboard: keyboard,
        lines: lines,
        limit: limit,
        validator: (v) => validate(key, v),
        onSaved: (v) => saved[label] = (v ?? '').trim(),
      );

  Widget section(
      String number,
      String title,
      List<Widget> children,
      ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (final child in children) ...[
                child,
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      );

  Widget choices(String label, List<String> options) =>
      FormField<String>(
        validator: (v) => v == null ? 'Choose $label.' : null,
        onSaved: (v) => saved[label] = v!,
        builder: (f) => InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: f.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: f.value == option,
                  onSelected: (_) => f.didChange(option),
                ),
            ],
          ),
        ),
      );

  // 4. Required date accepts today and rejects previous days.
  Widget dateField() => FormField<DateTime>(
    validator: (d) => d == null
        ? 'Choose a preferred response date.'
        : d.isBefore(today)
        ? 'Choose today or a future date.'
        : null,
    onSaved: (d) =>
    saved['Preferred date'] = dateLabel(d!),
    builder: (f) => InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final first = today;

        final result = await showDatePicker(
          context: context,
          firstDate: first,
          lastDate: DateTime(
            first.year + 2,
            first.month,
            first.day,
          ),
          initialDate:
          f.value == null || f.value!.isBefore(first)
              ? first
              : f.value!,
          helpText: 'Preferred response date',
        );

        if (mounted && result != null) {
          f.didChange(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Preferred response date',
          helperText:
          'A preference, not a confirmed appointment.',
          prefixIcon:
          const Icon(Icons.calendar_today_outlined),
          errorText: f.errorText,
        ),
        child: Text(
          f.value == null
              ? 'Select a date'
              : dateLabel(f.value!),
        ),
      ),
    ),
  );

  Widget declaration() => FormField<bool>(
    initialValue: false,
    validator: (v) => v == true
        ? null
        : 'Confirm your information before submitting.',
    onSaved: (_) => saved['Declaration'] = 'Confirmed',
    builder: (f) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: f.value ?? false,
          onChanged: (v) => f.didChange(v ?? false),
          title: const Text(
            'I confirm that my details and request are correct.',
          ),
          subtitle: const Text(
            'I agree to be contacted about this request.',
          ),
        ),
        if (f.hasError)
          Text(
            f.errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    ),
  );

  // 5. Validate first, save second. Block duplicate submissions.
  Future<void> submit() async {
    if (busy || submitted) return;

    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      message(
        'Check the highlighted fields. Your entries have been kept.',
      );
      return;
    }

    saved.clear();
    formKey.currentState!.save();

    final summary = <String, String>{
      'Reference': 'IITU-${DateTime.now().microsecondsSinceEpoch}',
      ...saved,
    };

    setState(() => busy = true);

    try {
      await widget.onRecord(summary);
    } catch (_) {
      if (mounted) {
        setState(() => busy = false);
        message('Could not record the request. Please try again.');
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      busy = false;
      submitted = true;
    });

    // 6. Advanced summary dialog identifies the local demo submission.
    final another = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Your demo request is recorded'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF207348),
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Saved in your Student Hub on this browser. '
                      'This request has not been sent to IITU.',
                ),
                const Divider(height: 32),
                for (final e in summary.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SelectableText(
                          e.value.isEmpty
                              ? 'Not provided'
                              : e.value,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep summary'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('New request'),
          ),
        ],
      ),
    );

    if (mounted && another == true) reset();
  }

  // 7. Reset clears text, selections, dates, consent and errors.
  void reset() {
    FocusScope.of(context).unfocus();
    formKey.currentState?.reset();

    for (final c in inputs.values) {
      c.clear();
    }

    setState(() {
      category = null;
      saved.clear();
      submitted = false;
      generation++;
    });

    message('Form cleared. You can start a new request.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Campus helpdesk',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // 8. SafeArea and scrolling keep the form usable with a keyboard.
    body: SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const UniversityLogo(width: 207),
                const SizedBox(height: 28),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose a campus team, describe what you need '
                      'and set your contact preferences.',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Educational prototype. All fields required '
                      'except phone. Requests stay in this browser.',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: formKey,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  child: Column(
                    key: ValueKey(generation),
                    children: [
                      section(
                        '01',
                        'Student details',
                        [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: busy || submitted
                                  ? null
                                  : () {
                                for (final k in [
                                  'name',
                                  'id',
                                  'email',
                                ]) {
                                  inputs[k]!.text =
                                      widget.student[k] ??
                                          '';
                                }

                                message(
                                  'Profile details added. '
                                      'Complete any missing fields.',
                                );
                              },
                              icon: const Icon(
                                Icons.person_outline,
                              ),
                              label: const Text(
                                'Use my profile details',
                              ),
                            ),
                          ),
                          field(
                            'name',
                            'Full name',
                            Icons.person_outline,
                            hint: 'Azhar Akhmetova',
                          ),
                          field(
                            'id',
                            'Student ID',
                            Icons.badge_outlined,
                            hint: 'I26043015',
                            helper:
                            '6–12 letters or digits. '
                                'Example: I26043015.',
                          ),
                          field(
                            'email',
                            'Campus email',
                            Icons.mail_outline,
                            hint: 'student@iitu.edu.kz',
                            keyboard:
                            TextInputType.emailAddress,
                          ),
                          field(
                            'phone',
                            'Phone (optional)',
                            Icons.phone_outlined,
                            hint: '+77001234567',
                            keyboard: TextInputType.phone,
                          ),
                        ],
                      ),
                      section(
                        '02',
                        'Request details',
                        [
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration:
                            const InputDecoration(
                              labelText: 'Campus service',
                              prefixIcon: Icon(
                                Icons.apartment_outlined,
                              ),
                            ),
                            items: [
                              for (final s in services)
                                DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                            ],
                            validator: (v) => v == null
                                ? 'Select the campus team '
                                'that can help you.'
                                : null,
                            onSaved: (v) =>
                            saved['Campus service'] = v!,
                            onChanged: (v) => setState(() {
                              category = v;
                              inputs['room']!.clear();
                            }),
                          ),

                          // 9. Conditional location is an advanced feature.
                          if (category == 'Facilities')
                            field(
                              'room',
                              'Room / campus location',
                              Icons.location_on_outlined,
                              hint:
                              'Main building, room 204',
                            ),
                          field(
                            'subject',
                            'Request subject',
                            Icons.title,
                            hint:
                            'Cannot connect to campus Wi-Fi',
                          ),

                          // 10. Live character counter and maximum length.
                          field(
                            'details',
                            'Request description',
                            Icons.edit_note,
                            hint:
                            'What happened, and what help do you need?',
                            helper:
                            '20–500 characters. '
                                'Do not include passwords.',
                            keyboard:
                            TextInputType.multiline,
                            lines: 5,
                            limit: 500,
                          ),
                          choices(
                            'Urgency',
                            ['Low', 'Normal', 'High'],
                          ),
                        ],
                      ),
                      section(
                        '03',
                        'Contact preferences',
                        [
                          choices(
                            'Preferred contact',
                            [
                              'Campus email',
                              'In-person consultation',
                            ],
                          ),
                          dateField(),
                        ],
                      ),
                      section(
                        '04',
                        'Review and confirm',
                        [
                          declaration(),
                          if (submitted)
                            const Text(
                              'Recorded locally. Your summary '
                                  'is available in Requests. '
                                  'Reset to start a new request.',
                              style: TextStyle(
                                color: Color(0xFF207348),
                              ),
                            ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: busy || submitted
                                    ? null
                                    : submit,
                                icon: const Icon(
                                  Icons.send_outlined,
                                  size: 19,
                                ),
                                label: Text(
                                  busy
                                      ? 'Recording…'
                                      : 'Submit request',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed:
                                busy ? null : reset,
                                icon: const Icon(
                                  Icons.restart_alt,
                                ),
                                label:
                                const Text('Reset form'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Reusable field maintains labels, validation and keyboard focus flow.
class CampusTextField extends StatelessWidget {
  const CampusTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.onSaved,
    this.hint,
    this.helper,
    this.keyboard = TextInputType.text,
    this.lines = 1,
    this.limit,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? helper;
  final TextInputType keyboard;
  final int lines;
  final int? limit;
  final String? Function(String?) validator;
  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    textInputAction: lines > 1
        ? TextInputAction.newline
        : TextInputAction.next,
    onFieldSubmitted: lines == 1
        ? (_) => FocusScope.of(context).nextFocus()
        : null,
    minLines: lines,
    maxLines: lines,
    maxLength: limit,
    validator: validator,
    onSaved: onSaved,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: Icon(icon, color: muted),
    ),
  );
}

// Official IITU logo embedded as PNG bytes.
// This long string is the image, not random text.
// No assets or pubspec configuration is required for the logo.
final Uint8List logoBytes = base64Decode(logoBase64);

const String logoBase64 = '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';