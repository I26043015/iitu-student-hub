import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const red = Color(0xFFAD232C);
const ink = Color(0xFF18191C);
const bg = Color(0xFFF5F4F1);
const muted = Color(0xFF686B73);
const line = Color(0xFFE7E5E1);

final hub = HubData();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hub.load();
  runApp(const IituApp());
}

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
          borderSide: const BorderSide(
            color: red,
            width: 2,
          ),
        ),
      ),
    ),

    // 1. Dashboard is registered once; home is not duplicated.
    initialRoute: AppRoutes.home,
    routes: {
      AppRoutes.home: (_) => const DashboardScreen(),
      AppRoutes.timetable: (_) => const TimetableScreen(),
      AppRoutes.services: (_) => const ServicesScreen(),
      AppRoutes.events: (_) => const EventsScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.resources: (_) => const ResourcesScreen(),
      AppRoutes.requests: (_) => const RequestsScreen(),
      AppRoutes.helpdesk: (_) => CampusRequestPage(
        student: {
          'name': hub.name,
          'id': hub.studentId,
          'email': hub.email,
        },
        onRecord: hub.recordRequest,
      ),
    },

    // 2. Dynamic route checks its argument before showing details.
    onGenerateRoute: (settings) {
      if (settings.name == AppRoutes.serviceDetail) {
        final selected = settings.arguments;

        if (selected is CampusService) {
          return MaterialPageRoute<ServiceResult>(
            settings: settings,
            builder: (_) =>
                ServiceDetailsScreen(service: selected),
          );
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRouteScreen(
            routeName: settings.name ?? '',
            reason: 'No valid campus service was supplied.',
          ),
        );
      }

      return null;
    },

    // 3. Unregistered routes receive a clear fallback.
    onUnknownRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => UnknownRouteScreen(
        routeName: settings.name ?? 'Unknown',
      ),
    ),
  );
}

// Route names are defined once and reused throughout the application.
class AppRoutes {
  static const home = '/';
  static const timetable = '/timetable';
  static const services = '/services';
  static const serviceDetail = '/service-detail';
  static const events = '/events';
  static const eventDetail = '/event-detail';
  static const profile = '/profile';
  static const resources = '/resources';
  static const requests = '/requests';
  static const helpdesk = '/helpdesk';
}

class CampusService {
  const CampusService(
      this.id,
      this.name,
      this.description,
      this.location,
      this.openingHours,
      this.contact,
      this.icon,
      this.status,
      );

  final String id;
  final String name;
  final String description;
  final String location;
  final String openingHours;
  final String contact;
  final String status;
  final IconData icon;
}

class CampusEvent {
  const CampusEvent(
      this.id,
      this.title,
      this.date,
      this.time,
      this.venue,
      this.category,
      this.description,
      this.icon,
      );

  final String id;
  final String title;
  final String date;
  final String time;
  final String venue;
  final String category;
  final String description;
  final IconData icon;
}

class CampusLesson {
  const CampusLesson(
      this.day,
      this.hour,
      this.minute,
      this.module,
      this.room,
      this.type,
      );

  final int day;
  final int hour;
  final int minute;
  final String module;
  final String room;
  final String type;

  String get dayName => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ][day - 1];

  String get time =>
      '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';

  DateTime nextStart(DateTime now) {
    var start =
    DateTime(now.year, now.month, now.day, hour, minute).add(
      Duration(days: (day - now.weekday + 7) % 7),
    );

    if (start.isBefore(now)) {
      start = start.add(const Duration(days: 7));
    }

    return start;
  }
}

class ServiceResult {
  const ServiceResult(this.service, this.reference);

  final String service;
  final String reference;
}

// All service locations, contacts and hours below are sample data.
const campusServices = [
  CampusService(
    'it',
    'IT support',
    'Get guidance on campus Wi-Fi, account access '
        'and safe use of student devices.',
    'Sample: Main building, room 204',
    'Sample: Mon–Fri, 09:00–18:00',
    'it-support@example.edu',
    Icons.wifi_outlined,
    'Demo service',
  ),
  CampusService(
    'library',
    'Library',
    'Ask about finding study materials, citation tools '
        'and using library spaces.',
    'Sample: Learning centre, level 2',
    'Sample: Mon–Fri, 09:00–19:00',
    'library@example.edu',
    Icons.local_library_outlined,
    'Demo service',
  ),
  CampusService(
    'career',
    'Career Center',
    'Prepare your CV, plan an internship search '
        'and practise for interviews.',
    'Sample: Student centre, room 105',
    'Sample: Mon–Fri, 10:00–17:00',
    'career@example.edu',
    Icons.work_outline,
    'Demo service',
  ),
  CampusService(
    'facilities',
    'Facilities',
    'Report a classroom issue or request help '
        'with campus equipment and spaces.',
    'Sample: Main building, reception',
    'Sample: Mon–Fri, 09:00–18:00',
    'facilities@example.edu',
    Icons.apartment_outlined,
    'Demo service',
  ),
  CampusService(
    'activities',
    'Student activities',
    'Discover student communities, volunteering '
        'and opportunities to organise an event.',
    'Sample: Student space, level 1',
    'Sample: Mon–Fri, 10:00–17:00',
    'activities@example.edu',
    Icons.groups_outlined,
    'Demo service',
  ),
  CampusService(
    'academic',
    'Academic support',
    'Ask for guidance on study planning, course choices '
        'and academic enquiries.',
    'Sample: Academic office, room 301',
    'Sample: Mon–Fri, 09:00–17:00',
    'academic@example.edu',
    Icons.school_outlined,
    'Demo service',
  ),
];

const campusEvents = [
  CampusEvent(
    'security',
    'Cybersecurity workshop',
    '15 OCT 2026',
    '16:00',
    'Sample: Main building, lab 204',
    'WORKSHOP',
    'Explore phishing, authentication and incident reporting '
        'in a sample practical workshop. Bring a laptop. '
        'This is an illustrative event, not an official announcement.',
    Icons.security_outlined,
  ),
  CampusEvent(
    'career',
    'Your first tech internship',
    '19 OCT 2026',
    '14:00',
    'Sample: Career space, room 105',
    'CAREER',
    'Prepare a one-page CV, present your projects and practise '
        'a short interview. Registrations are demonstrations '
        'stored in this browser.',
    Icons.work_outline,
  ),
  CampusEvent(
    'community',
    'Student community meetup',
    '23 OCT 2026',
    '17:00',
    'Sample: Student space, level 1',
    'COMMUNITY',
    'Discover clubs, share ideas and find teammates for your '
        'next project. This listing is sample content '
        'for the campus application.',
    Icons.groups_outlined,
  ),
];

const campusLessons = [
  CampusLesson(
    1, 9, 0,
    'Cross-platform development',
    'Lab 204',
    'Practice',
  ),
  CampusLesson(
    1, 11, 0,
    'Network security',
    'Room 301',
    'Lecture',
  ),
  CampusLesson(
    2, 9, 0,
    'Machine learning',
    'Lab 306',
    'Practice',
  ),
  CampusLesson(
    2, 14, 0,
    'ERP programming',
    'Room 210',
    'Lecture',
  ),
  CampusLesson(
    3, 10, 0,
    'Cloud & virtualization',
    'Lab 302',
    'Practice',
  ),
  CampusLesson(
    3, 13, 0,
    'Network security',
    'Lab 204',
    'Practice',
  ),
  CampusLesson(
    4, 9, 0,
    'ERP programming',
    'Lab 305',
    'Practice',
  ),
  CampusLesson(
    4, 11, 0,
    'Machine learning',
    'Room 301',
    'Lecture',
  ),
  CampusLesson(
    5, 10, 0,
    'Cross-platform development',
    'Room 210',
    'Lecture',
  ),
  CampusLesson(
    5, 13, 0,
    'Cloud & virtualization',
    'Room 304',
    'Lecture',
  ),
];

const campusResources = [
  {
    'title': 'Library guide',
    'tag': 'STUDY',
    'body':
    'Organise your reading list by course, record citations '
        'while you read and keep track of the sources used '
        'in each assignment.',
  },
  {
    'title': 'Internship checklist',
    'tag': 'CAREER',
    'body':
    'Prepare a one-page CV, add two relevant projects, '
        'practise your introduction and keep a list '
        'of application deadlines.',
  },
  {
    'title': 'Account security',
    'tag': 'IT SUPPORT',
    'body':
    'Use unique passwords and multi-factor authentication. '
        'Never share login codes. Report suspicious messages '
        'through campus support.',
  },
  {
    'title': 'Exchange preparation',
    'tag': 'MOBILITY',
    'body':
    'Prepare a transcript, course comparison, language '
        'certificate and budget. Confirm actual deadlines '
        'with your university mobility office.',
  },
];

// Shared local state survives route changes and browser refreshes.
class HubData extends ChangeNotifier {
  final storage = SharedPreferencesAsync();

  String name = 'Azhar Akhmetova';
  String studentId = 'I26043015';
  String programme = 'Network Security';
  String email = 'student@iitu.edu.kz';

  List<String> reminders = [];
  Set<String> registered = {};
  Set<String> bookmarks = {};
  Set<String> appointments = {};
  List<Map<String, String>> requests = [];

  String? storageWarning;

  CampusLesson get nextLesson {
    final now = DateTime.now();

    final ordered = [...campusLessons]
      ..sort(
            (a, b) =>
            a.nextStart(now).compareTo(b.nextStart(now)),
      );

    return ordered.first;
  }

  Future<void> load() async {
    try {
      final raw = await storage.getString('iitu_hub_v3');

      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;

        name = m['name'] as String? ?? name;
        studentId = m['id'] as String? ?? studentId;
        programme = m['programme'] as String? ?? programme;

        final e = m['email'] as String?;
        if (e != null && e.trim().isNotEmpty) email = e;

        reminders = List<String>.from(m['reminders'] ?? []);
        registered = Set<String>.from(m['registered'] ?? []);
        bookmarks = Set<String>.from(m['bookmarks'] ?? []);
        appointments = Set<String>.from(m['appointments'] ?? []);

        requests = (m['requests'] as List? ?? [])
            .map((r) => Map<String, String>.from(r as Map))
            .toList();
      } else {
        reminders =
            await storage.getStringList('iitu_tasks_restored') ??
                [];

        name =
            await storage.getString('iitu_name_restored') ?? name;
        studentId =
            await storage.getString('iitu_id_restored') ??
                studentId;
        programme =
            await storage.getString('iitu_programme_restored') ??
                programme;
      }
    } catch (_) {
      storageWarning = 'Saved information could not be loaded.';
    }
  }

  Future<void> save() async {
    notifyListeners();

    try {
      await storage.setString(
        'iitu_hub_v3',
        jsonEncode({
          'name': name,
          'id': studentId,
          'programme': programme,
          'email': email,
          'reminders': reminders,
          'registered': registered.toList(),
          'bookmarks': bookmarks.toList(),
          'appointments': appointments.toList(),
          'requests': requests,
        }),
      );

      storageWarning = null;
    } catch (_) {
      storageWarning =
      'Browser storage failed. Changes remain '
          'available in this session.';
    }

    notifyListeners();
  }

  Future<void> recordRequest(Map<String, String> record) async {
    requests.insert(0, record);
    await save();
  }
}

void notify(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );

// 4. Each screen blocks repeated navigation taps while its child is open.
// Child screens have their own guard, allowing nested navigation.
mixin RouteGuard<T extends StatefulWidget> on State<T> {
  bool opening = false;

  Future<R?> openNamed<R>(
      String route, {
        Object? arguments,
      }) async {
    if (opening) return null;

    opening = true;

    try {
      return await Navigator.pushNamed<R>(
        context,
        route,
        arguments: arguments,
      );
    } finally {
      opening = false;
    }
  }

  Future<R?> openDirect<R>(Route<R> route) async {
    if (opening) return null;

    opening = true;

    try {
      return await Navigator.push<R>(context, route);
    } finally {
      opening = false;
    }
  }
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
        border: Border.all(color: hovered ? red : line),
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
                    Icon(widget.icon, color: red, size: 26),
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

Widget pageTitle(String text, String subtitle) => Padding(
  padding: const EdgeInsets.only(bottom: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 30,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        subtitle,
        style: const TextStyle(color: muted),
      ),
    ],
  ),
);

Widget sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
    ),
  ),
);

Widget responsiveGrid(
    List<Widget> items, {
      double minimum = 250,
      int maximum = 3,
    }) =>
    LayoutBuilder(
      builder: (c, box) {
        final count =
        (box.maxWidth / minimum).floor().clamp(1, maximum);
        final width =
            (box.maxWidth - 16 * (count - 1)) / count;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final item in items)
              SizedBox(width: width, child: item),
          ],
        );
      },
    );

Widget twoColumns(Widget a, Widget b) => LayoutBuilder(
  builder: (_, box) => box.maxWidth >= 850
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

class CampusShell extends StatelessWidget {
  const CampusShell({
    super.key,
    required this.title,
    required this.child,
    this.home = false,
    this.onNavigate,
    this.controller,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final bool home;
  final void Function(String)? onNavigate;
  final ScrollController? controller;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, box) => Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        // 5. Back reveals the previous route, not a new Dashboard.
        leading: home
            ? null
            : IconButton(
          tooltip: 'Return to previous screen',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (home)
            IconButton(
              tooltip: 'My requests',
              icon: const Icon(Icons.inbox_outlined),
              onPressed: () =>
                  onNavigate?.call(AppRoutes.requests),
            ),
          if (box.maxWidth >= 650)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: UniversityLogo(width: 150),
              ),
            ),
        ],
      ),
      drawer: home
          ? Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const UniversityLogo(width: 180),
                    const SizedBox(height: 22),
                    Text(
                      hub.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hub.programme,
                      style:
                      const TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
              for (final item in [
                (
                AppRoutes.timetable,
                'Timetable',
                Icons.calendar_month_outlined,
                ),
                (
                AppRoutes.services,
                'Campus services',
                Icons.support_agent,
                ),
                (
                AppRoutes.events,
                'Campus events',
                Icons.event_outlined,
                ),
                (
                AppRoutes.profile,
                'Student profile',
                Icons.person_outline,
                ),
                (
                AppRoutes.resources,
                'Resource library',
                Icons.menu_book_outlined,
                ),
                (
                AppRoutes.requests,
                'My requests',
                Icons.inbox_outlined,
                ),
              ])
                ListTile(
                  leading: Icon(item.$3),
                  title: Text(item.$2),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate?.call(item.$1);
                  },
                ),
            ],
          ),
        ),
      )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: home
          ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: red,
        unselectedItemColor: muted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (i) {
          if (i > 0) {
            onNavigate?.call(
              [
                AppRoutes.home,
                AppRoutes.services,
                AppRoutes.events,
                AppRoutes.profile,
              ][i],
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.all(
            box.maxWidth >= 900 ? 32 : 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  child,
                  const SizedBox(height: 48),
                  const Divider(color: line),
                  const SizedBox(height: 18),
                  const Text(
                    'IITU Student Hub · Educational prototype\n'
                        'Campus schedules, locations, contacts '
                        'and events are sample data.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                  if (hub.storageWarning != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        hub.storageWarning!,
                        style: const TextStyle(color: red),
                      ),
                    ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> addStudentReminder(
    BuildContext context, [
      String initial = '',
    ]) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) => ReminderDialog(initial: initial),
  );

  if (!context.mounted ||
      result == null ||
      result.isEmpty) {
    return;
  }

  hub.reminders.add(result);
  await hub.save();

  if (context.mounted) {
    notify(context, 'Reminder added to your student plan.');
  }
}

class ReminderPanel extends StatelessWidget {
  const ReminderPanel({super.key});

  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your next steps',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Add reminder',
              onPressed: () => addStudentReminder(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hub.reminders.isEmpty) ...[
          const Text(
            'Keep one small goal in sight.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suggested reminder: review your course '
                'registration plan this week.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => addStudentReminder(
              context,
              'Review my course registration plan',
            ),
            child: const Text('Add this reminder'),
          ),
        ] else
          for (var i = 0; i < hub.reminders.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity:
              ListTileControlAffinity.leading,
              value: false,
              title: Text(hub.reminders[i]),
              onChanged: (_) async {
                final item = hub.reminders.removeAt(i);
                await hub.save();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                      const Text('Reminder completed.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          hub.reminders.insert(
                            i.clamp(
                              0,
                              hub.reminders.length,
                            ).toInt(),
                            item,
                          );
                          hub.save();
                        },
                      ),
                    ),
                  );
              },
            ),
      ],
    ),
  );
}

// SCREEN 1: DASHBOARD
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with RouteGuard<DashboardScreen> {
  Widget hero() => LayoutBuilder(
    builder: (_, box) => ClipRRect(
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
              child: CustomPaint(painter: CampusPattern()),
            ),
            Padding(
              padding: EdgeInsets.all(
                box.maxWidth > 650 ? 40 : 26,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IITU / STUDENT EXPERIENCE',
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
                      fontSize: box.maxWidth > 650 ? 46 : 32,
                      height: 1.08,
                      letterSpacing: -1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 480,
                    child: Text(
                      'Your classes, campus services and next '
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
                        onPressed: () =>
                            openNamed(AppRoutes.services),
                        icon:
                        const Icon(Icons.arrow_outward),
                        label: const Text(
                          'Explore campus services',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ink,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            openNamed(AppRoutes.helpdesk),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Create a support request →',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ALMATY, KAZAKHSTAN · '
                        'INTERNATIONAL IT UNIVERSITY',
                    style: TextStyle(
                      color: Color(0xFFCAB4B8),
                      fontSize: 10,
                      letterSpacing: 1,
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) {
      final next = hub.nextLesson;

      return CampusShell(
        title: 'IITU Student Hub',
        home: true,
        onNavigate: (r) => openNamed(r),
        floatingActionButton: FloatingActionButton(
          backgroundColor: red,
          foregroundColor: Colors.white,
          tooltip: 'Add a student reminder',
          onPressed: () => addStudentReminder(context),
          child: const Icon(Icons.add),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pageTitle(
              'Welcome back, '
                  '${hub.name.trim().split(' ').first}.',
              'A clearer view of your campus day.',
            ),
            hero(),
            const SizedBox(height: 28),
            sectionTitle('Your campus, one tap away'),
            responsiveGrid(
              [
                ActionTile(
                  title: 'Timetable',
                  subtitle: 'Plan your study week',
                  icon: Icons.calendar_month_outlined,
                  onTap: () =>
                      openNamed(AppRoutes.timetable),
                ),
                ActionTile(
                  title: 'Campus services',
                  subtitle: 'Find the right support team',
                  icon: Icons.support_agent,
                  onTap: () =>
                      openNamed(AppRoutes.services),
                ),
                ActionTile(
                  title: 'Campus events',
                  subtitle:
                  'Learn, connect and participate',
                  icon: Icons.event_outlined,
                  onTap: () =>
                      openNamed(AppRoutes.events),
                ),
                ActionTile(
                  title: 'Student profile',
                  subtitle:
                  'Your details and saved activity',
                  icon: Icons.person_outline,
                  onTap: () =>
                      openNamed(AppRoutes.profile),
                ),
              ],
              maximum: 4,
            ),
            const SizedBox(height: 28),
            twoColumns(
              Panel(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT SAMPLE CLASS',
                      style: TextStyle(
                        color: red,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      next.module,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${next.dayName} · ${next.time} · '
                          '${next.room}',
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () =>
                          openNamed(AppRoutes.timetable),
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                      ),
                      label:
                      const Text('View timetable'),
                    ),
                  ],
                ),
              ),
              const ReminderPanel(),
            ),
            const SizedBox(height: 28),
            responsiveGrid([
              ActionTile(
                title: 'Resource library',
                subtitle: 'Search and save useful guides',
                icon: Icons.menu_book_outlined,
                onTap: () =>
                    openNamed(AppRoutes.resources),
              ),
              ActionTile(
                title: 'My requests',
                subtitle:
                '${hub.requests.length} demo requests recorded',
                icon: Icons.inbox_outlined,
                onTap: () =>
                    openNamed(AppRoutes.requests),
              ),
            ]),
          ],
        ),
      );
    },
  );
}

// SCREEN 2: TIMETABLE
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() =>
      _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) {
      final next = hub.nextLesson;

      return CampusShell(
        title: 'Timetable',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pageTitle(
              'Make the week work for you.',
              'A sample Network Security timetable. '
                  'Confirm actual classes with your university.',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 6; i++)
                  ChoiceChip(
                    label: Text(
                      [
                        'All days',
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                      ][i],
                    ),
                    selected: filter == i,
                    onSelected: (_) =>
                        setState(() => filter = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            for (final lesson in campusLessons)
              if (filter == 0 || filter == lesson.day)
                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 14),
                  child: Panel(
                    padding: 20,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (identical(lesson, next))
                          const Padding(
                            padding:
                            EdgeInsets.only(bottom: 10),
                            child: Text(
                              'NEXT SAMPLE CLASS',
                              style: TextStyle(
                                color: red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                lesson.time,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 42,
                              color: red,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    lesson.module,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${lesson.dayName} · '
                                        '${lesson.room} · '
                                        '${lesson.type}',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Add class reminder',
                              onPressed: () =>
                                  addStudentReminder(
                                    context,
                                    '${lesson.module} · '
                                        '${lesson.dayName}, '
                                        '${lesson.time} · '
                                        '${lesson.room}',
                                  ),
                              icon: const Icon(
                                Icons.add_alert_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            const ReminderPanel(),
          ],
        ),
      );
    },
  );
}

// SCREEN 3: CAMPUS SERVICES
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with RouteGuard<ServicesScreen> {
  final search = TextEditingController();
  final scroll = ScrollController();
  String query = '';

  @override
  void dispose() {
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> details(CampusService service) async {
    // 6. Pass the selected object and await a typed returned result.
    final result = await openNamed<ServiceResult>(
      AppRoutes.serviceDetail,
      arguments: service,
    );

    if (!mounted || result == null) return;

    notify(
      context,
      '${result.service}: demo appointment interest recorded '
          '(${result.reference}).',
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) => CampusShell(
      title: 'Campus services',
      controller: scroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pageTitle(
            'Find the right people.',
            'Explore sample campus services. '
                'Open a service to see its own details.',
          ),

          // Extension: the retained route preserves search and scroll.
          TextField(
            controller: search,
            onChanged: (v) =>
                setState(() => query = v.toLowerCase().trim()),
            decoration: const InputDecoration(
              labelText: 'Search campus services',
              hintText: 'Library, IT, career…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          if (!campusServices.any(
                (s) => '${s.name} ${s.description}'
                .toLowerCase()
                .contains(query),
          ))
            const Panel(
              child: Text(
                'No matching services. Try a different keyword.',
              ),
            ),
          responsiveGrid([
            for (final service in campusServices)
              if ('${service.name} ${service.description}'
                  .toLowerCase()
                  .contains(query))
                Panel(
                  padding: 20,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // Extension: shared icon flies into Details.
                      Hero(
                        tag: 'service-${service.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: Icon(
                              service.icon,
                              color: red,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style:
                        const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 18),
                      if (hub.appointments
                          .contains(service.id))
                        const Padding(
                          padding:
                          EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Demo interest saved',
                            style: TextStyle(
                              color: red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => details(service),
                        icon: const Icon(
                          Icons.arrow_outward,
                          size: 18,
                        ),
                        label: const Text('View service'),
                      ),
                    ],
                  ),
                ),
          ]),
        ],
      ),
    ),
  );
}

// SCREEN 4: SERVICE DETAILS
class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  final CampusService service;

  @override
  State<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState
    extends State<ServiceDetailsScreen>
    with RouteGuard<ServiceDetailsScreen> {
  bool saving = false;

  Future<void> requestAppointment() async {
    if (saving) return;

    setState(() => saving = true);

    hub.appointments.add(widget.service.id);
    await hub.save();

    if (!mounted) return;

    // 7. Result returns to Services by popping this route.
    Navigator.pop(
      context,
      ServiceResult(
        widget.service.name,
        'DEMO-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
  }

  Widget info(
      IconData icon,
      String label,
      String value,
      ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: red),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                  SelectableText(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return CampusShell(
      title: 'Service details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'service-${s.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        s.icon,
                        color: red,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  s.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.status,
                  style: const TextStyle(
                    color: red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  s.description,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('Plan your visit'),
                info(
                  Icons.location_on_outlined,
                  'LOCATION',
                  s.location,
                ),
                info(
                  Icons.schedule_outlined,
                  'OPENING HOURS',
                  s.openingHours,
                ),
                info(
                  Icons.mail_outline,
                  'SAMPLE CONTACT',
                  s.contact,
                ),
                const Text(
                  'Locations, hours and contacts are illustrative. '
                      'No appointment is sent to university staff.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed:
                      saving ? null : requestAppointment,
                      icon: const Icon(
                        Icons.event_available_outlined,
                      ),
                      label: Text(
                        saving
                            ? 'Saving…'
                            : 'Save demo appointment interest',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: saving
                          ? null
                          : () => openNamed(AppRoutes.helpdesk),
                      child: const Text('Open request form'),
                    ),
                    TextButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.pop(context),
                      child:
                      const Text('Return to services'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SCREEN 5: CAMPUS EVENTS
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with RouteGuard<EventsScreen> {
  Future<void> details(CampusEvent event) async {
    // 8. Direct push + MaterialPageRoute passes the selected Event.
    final result = await openDirect<bool>(
      MaterialPageRoute<bool>(
        settings: RouteSettings(
          name: AppRoutes.eventDetail,
          arguments: event,
        ),
        builder: (_) => EventDetailsScreen(event: event),
      ),
    );

    if (!mounted || result == null) return;

    notify(
      context,
      result
          ? 'Demo registration saved for ${event.title}.'
          : 'Demo registration cancelled for ${event.title}.',
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) => CampusShell(
      title: 'Campus events',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pageTitle(
            'Beyond the classroom.',
            'Discover sample workshops, career sessions '
                'and community events.',
          ),
          responsiveGrid([
            for (final event in campusEvents)
              Panel(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      event.icon,
                      size: 40,
                      color: red,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      event.category,
                      style: const TextStyle(
                        color: red,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${event.date} · ${event.time}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.venue,
                      style:
                      const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      hub.registered.contains(event.id)
                          ? 'Registered locally · Demo'
                          : 'Registration available · Demo',
                      style: const TextStyle(
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => details(event),
                      icon:
                      const Icon(Icons.arrow_outward),
                      label: Text(
                        hub.registered.contains(event.id)
                            ? 'Manage registration'
                            : 'View event',
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ],
      ),
    ),
  );
}

// Extension: a separate Event Details route receives a CampusEvent.
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  final CampusEvent event;

  @override
  State<EventDetailsScreen> createState() =>
      _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool saving = false;

  Future<void> register() async {
    if (saving) return;

    setState(() => saving = true);

    final joined = hub.registered.contains(widget.event.id);

    if (joined) {
      hub.registered.remove(widget.event.id);
    } else {
      hub.registered.add(widget.event.id);
    }

    await hub.save();

    if (mounted) {
      Navigator.pop(context, !joined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final joined = hub.registered.contains(e.id);

    return CampusShell(
      title: 'Event details',
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(e.icon, color: red, size: 56),
            const SizedBox(height: 24),
            pageTitle(e.title, '${e.date} · ${e.time}'),
            Text(
              e.venue,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(e.description),
            const SizedBox(height: 24),
            Text(
              'Student: ${hub.name}\nContact: ${hub.email}',
            ),
            const SizedBox(height: 14),
            const Text(
              'This is a local demo registration. '
                  'It does not reserve a real university event place.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: saving ? null : register,
              icon: const Icon(Icons.how_to_reg_outlined),
              label: Text(
                saving
                    ? 'Saving…'
                    : joined
                    ? 'Cancel demo registration'
                    : 'Register for demo event',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN 6: STUDENT PROFILE
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with RouteGuard<ProfileScreen> {
  bool editing = false;

  Future<void> edit() async {
    if (editing) return;

    editing = true;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ProfileDialog(
        data: {
          'name': hub.name,
          'id': hub.studentId,
          'programme': hub.programme,
          'email': hub.email,
        },
      ),
    );

    editing = false;

    if (!mounted || result == null) return;

    hub.name = result['name']!;
    hub.studentId = result['id']!;
    hub.programme = result['programme']!;
    hub.email = result['email']!;

    await hub.save();

    if (mounted) {
      notify(context, 'Student profile updated.');
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) => CampusShell(
      title: 'Student profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pageTitle(
            'Your student space.',
            'A sample profile you can personalise. '
                'The default email is a placeholder.',
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: ink,
                  child: Text(
                    hub.name.isEmpty
                        ? 'A'
                        : hub.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  hub.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Student ID: ${hub.studentId}\n'
                      'Programme: ${hub.programme}\n'
                      'Email: ${hub.email}',
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          responsiveGrid([
            ActionTile(
              title:
              '${hub.registered.length} registrations',
              subtitle:
              'Manage your demo event activity',
              icon: Icons.event_outlined,
              onTap: () => openNamed(AppRoutes.events),
            ),
            ActionTile(
              title:
              '${hub.bookmarks.length} saved resources',
              subtitle: 'Open your resource library',
              icon: Icons.bookmark_outline,
              onTap: () =>
                  openNamed(AppRoutes.resources),
            ),
            ActionTile(
              title:
              '${hub.requests.length} support requests',
              subtitle:
              'Review your local request history',
              icon: Icons.inbox_outlined,
              onTap: () =>
                  openNamed(AppRoutes.requests),
            ),
          ]),
          const SizedBox(height: 24),
          const ReminderPanel(),
        ],
      ),
    ),
  );
}

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() =>
      _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String query = '';
  bool reading = false;

  Future<void> read(Map<String, String> r) async {
    if (reading) return;
    reading = true;

    final saved = hub.bookmarks.contains(r['title']);

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(r['title']!),
        content: SingleChildScrollView(
          child: Text(r['body']!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(
              saved ? 'Remove bookmark' : 'Save resource',
            ),
          ),
        ],
      ),
    );

    reading = false;

    if (!mounted || result != true) return;

    if (saved) {
      hub.bookmarks.remove(r['title']);
    } else {
      hub.bookmarks.add(r['title']!);
    }

    await hub.save();

    if (mounted) {
      notify(
        context,
        saved ? 'Bookmark removed.' : 'Resource saved.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) => CampusShell(
      title: 'Resource library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pageTitle(
            'Useful, when you need it.',
            'Search student guides and keep '
                'the ones that matter.',
          ),
          TextField(
            onChanged: (v) =>
                setState(() => query = v.toLowerCase().trim()),
            decoration: const InputDecoration(
              labelText: 'Search resources',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          if (!campusResources.any(
                (r) => '${r['title']} ${r['body']}'
                .toLowerCase()
                .contains(query),
          ))
            const Panel(
              child: Text(
                'No results. Try another keyword.',
              ),
            ),
          responsiveGrid([
            for (final r in campusResources)
              if ('${r['title']} ${r['body']}'
                  .toLowerCase()
                  .contains(query))
                ActionTile(
                  title:
                  '${hub.bookmarks.contains(r['title']) ? '★ ' : ''}'
                      '${r['title']}',
                  subtitle: r['tag']!,
                  icon: Icons.article_outlined,
                  onTap: () => read(r),
                ),
          ]),
        ],
      ),
    ),
  );
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with RouteGuard<RequestsScreen> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hub,
    builder: (_, __) => CampusShell(
      title: 'My requests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pageTitle(
            'Support, with a clear record.',
            'Local demonstration requests. '
                'Nothing is sent to university staff.',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () =>
                  openNamed(AppRoutes.helpdesk),
              icon: const Icon(Icons.add),
              label: const Text('Create a request'),
            ),
          ),
          const SizedBox(height: 24),
          if (hub.requests.isEmpty)
            const Panel(
              child: Text(
                'No requests yet. Create a campus request '
                    'to see its summary here.',
              ),
            ),
          for (final r in hub.requests)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Panel(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['Reference'] ?? '',
                      style: const TextStyle(
                        color: red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r['Request subject'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 28),
                    for (final e in r.entries)
                      if (e.key != 'Reference' &&
                          e.key != 'Request subject')
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
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
        ],
      ),
    ),
  );
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({
    super.key,
    required this.routeName,
    this.reason =
    'This page is not registered in Student Hub.',
  });

  final String routeName;
  final String reason;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Page not found')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(maxWidth: 650),
            child: Panel(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: red,
                    ),
                  ),
                  pageTitle(
                    'A wrong turn, not a dead end.',
                    reason,
                  ),
                  SelectableText(
                    'Requested route: $routeName',
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Return to the app'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
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
  State<ReminderDialog> createState() =>
      _ReminderDialogState();
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
            hintText:
            'Finish my lab report before Tuesday',
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
  State<ProfileDialog> createState() =>
      _ProfileDialogState();
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
                        'email': 'Campus email',
                      }[e.key],
                    ),
                    validator: (raw) {
                      final v = (raw ?? '').trim();

                      if (e.key == 'email') {
                        return !RegExp(
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

// Previous Form assignment remains available as a separate route.
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
  // One key coordinates form validation, saving and resetting.
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

  void message(String text) => notify(context, text);

  @override
  void dispose() {
    for (final c in inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Specific validation errors preserve other entered information.
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

  Widget choices(
      String label,
      List<String> options,
      ) =>
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
          controlAffinity:
          ListTileControlAffinity.leading,
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

  // Validation must succeed before onSaved callbacks are invoked.
  Future<void> submit() async {
    if (busy || submitted) return;

    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      message(
        'Check the highlighted fields. '
            'Your entries have been kept.',
      );
      return;
    }

    saved.clear();
    formKey.currentState!.save();

    final summary = <String, String>{
      'Reference':
      'IITU-${DateTime.now().microsecondsSinceEpoch}',
      ...saved,
    };

    setState(() => busy = true);

    try {
      await widget.onRecord(summary);
    } catch (_) {
      if (mounted) {
        setState(() => busy = false);
        message(
          'Could not record the request. Please try again.',
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      busy = false;
      submitted = true;
    });

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
                    padding:
                    const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
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

  // Full reset includes every non-text selection and error state.
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
    body: SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
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
                            alignment:
                            Alignment.centerLeft,
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

                          // Conditional field from the Form assignment.
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
                                  'is available in My requests. '
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

// Embedded official PNG logo. Keep this string unchanged.
final Uint8List logoBytes = base64Decode(logoBase64);

const String logoBase64 = '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';