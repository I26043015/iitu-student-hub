import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const red = Color(0xFFAD232C);
const ink = Color(0xFF202124);
const bg = Color(0xFFF6F5F3);
const muted = Color(0xFF676970);

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
      colorScheme: ColorScheme.fromSeed(seedColor: red),
    ),
    home: const CampusPage(),
  );
}

// Логотип создаётся прямо в Flutter, поэтому файл PNG не требуется.
class IituMark extends StatelessWidget {
  const IituMark({super.key, this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'i',
        style: TextStyle(
          fontSize: small ? 30 : 39,
          fontWeight: FontWeight.w900,
          color: ink,
          height: 1,
        ),
      ),
      Text(
        'IT',
        style: TextStyle(
          fontSize: small ? 30 : 39,
          fontWeight: FontWeight.w900,
          color: red,
          height: 1,
          letterSpacing: -3,
        ),
      ),
      const SizedBox(width: 9),
      Container(
        width: 1,
        height: small ? 24 : 30,
        color: Colors.black26,
      ),
      const SizedBox(width: 9),
      const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INTERNATIONAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            'IT UNIVERSITY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    ],
  );
}

class CampusPage extends StatefulWidget {
  const CampusPage({super.key});

  @override
  State<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends State<CampusPage> {
  final store = SharedPreferencesAsync();

  int index = 0;
  List<String> reminders = [];
  Set<String> savedClubs = {};

  String name = 'Akhmetova Azhar';
  String id = '';
  String programme = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r = await store.getStringList('iitu_tasks_restored');
      final c = await store.getStringList('iitu_clubs_restored');
      final n = await store.getString('iitu_name_restored');
      final s = await store.getString('iitu_id_restored');
      final p = await store.getString('iitu_programme_restored');
      final e = await store.getString('iitu_email_restored');

      if (!mounted) return;

      setState(() {
        reminders = r ?? [];
        savedClubs = (c ?? []).toSet();
        name = n ?? name;
        id = s ?? '';
        programme = p ?? '';
        email = e ?? '';
      });
    } catch (_) {
      if (mounted) toast('Saved information is unavailable');
    }
  }

  void toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void go(int page, {bool drawer = false}) {
    if (drawer) Navigator.pop(context);
    setState(() => index = page);
  }

  Future<void> addReminder([String initial = '']) async {
    final input = TextEditingController(text: initial);

    final answer = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Add a reminder'),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'What needs to be done?',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            Navigator.pop(dialog, input.text.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, input.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    input.dispose();

    if (!mounted || answer == null) return;

    if (answer.isEmpty) {
      toast('Enter a reminder first');
      return;
    }

    setState(() {
      reminders.insert(0, answer);
      index = 0;
    });

    try {
      await store.setStringList('iitu_tasks_restored', reminders);
    } catch (_) {
      if (mounted) toast('Could not save the reminder');
      return;
    }

    if (mounted) toast('Reminder added');
  }

  Future<void> removeReminder(String value) async {
    setState(() => reminders.remove(value));

    try {
      await store.setStringList('iitu_tasks_restored', reminders);
    } catch (_) {
      if (mounted) toast('Could not save changes');
      return;
    }

    if (mounted) toast('Reminder removed');
  }

  Future<void> toggleClub(String club) async {
    setState(() {
      if (!savedClubs.remove(club)) {
        savedClubs.add(club);
      }
    });

    try {
      await store.setStringList(
        'iitu_clubs_restored',
        savedClubs.toList(),
      );
    } catch (_) {
      if (mounted) toast('Could not save the club');
      return;
    }

    if (mounted) {
      toast(
        savedClubs.contains(club)
            ? '$club saved'
            : '$club removed',
      );
    }
  }

  Future<void> editProfile() async {
    final fields = [
      TextEditingController(text: name),
      TextEditingController(text: id),
      TextEditingController(text: programme),
      TextEditingController(text: email),
    ];

    final save = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Edit student information'),
        content: SizedBox(
          width: 410,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 4; i++) ...[
                  TextField(
                    controller: fields[i],
                    maxLength: 80,
                    keyboardType:
                    i == 3 ? TextInputType.emailAddress : null,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: [
                        'Full name',
                        'Student ID',
                        'Programme',
                        'Email',
                      ][i],
                    ),
                  ),
                  if (i < 3) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final values = fields.map((field) => field.text.trim()).toList();

    for (final field in fields) {
      field.dispose();
    }

    if (!mounted || save != true) return;

    if (values[0].isEmpty) {
      toast('Name cannot be empty');
      return;
    }

    setState(() {
      name = values[0];
      id = values[1];
      programme = values[2];
      email = values[3];
    });

    try {
      await Future.wait([
        store.setString('iitu_name_restored', name),
        store.setString('iitu_id_restored', id),
        store.setString('iitu_programme_restored', programme),
        store.setString('iitu_email_restored', email),
      ]);
    } catch (_) {
      if (mounted) toast('Could not save profile');
      return;
    }

    if (mounted) toast('Profile updated');
  }

  void detail(
      String title,
      String text, {
        String? action,
        VoidCallback? onAction,
      }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 12, 25, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: muted,
                ),
              ),
              if (action != null && onAction != null) ...[
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(sheet);
                    onAction();
                  },
                  child: Text(action),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget panel(Widget child, {Color color = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEAE7E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget heading(String title, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            color: ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: const TextStyle(color: muted),
        ),
      ],
    );
  }

  Widget hero(bool wide) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 275),
      padding: EdgeInsets.all(wide ? 33 : 23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [ink, Color(0xFF51252A), red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const IituMark(small: true),
          ),
          const SizedBox(height: 25),
          const Text(
            'WELCOME TO IITU',
            style: TextStyle(
              color: Color(0xFFFFC9CC),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Your campus,\nyour opportunities.',
            style: TextStyle(
              color: Colors.white,
              fontSize: wide ? 38 : 31,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Services, student life and your plans in one place.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget service(
      IconData icon,
      String title,
      String description,
      String info,
      String task,
      ) {
    return InkWell(
      onTap: () => detail(
        title,
        info,
        action: 'Add to my reminders',
        onAction: () => addReminder(task),
      ),
      borderRadius: BorderRadius.circular(19),
      child: panel(
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFFFEAEB),
              child: Icon(icon, color: red),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: red),
          ],
        ),
      ),
    );
  }

  Widget announcement(
      IconData icon,
      String label,
      String title,
      String description,
      ) {
    return InkWell(
      onTap: () => detail(
        title,
        description,
        action: 'Remind me to learn more',
        onAction: () => addReminder(title),
      ),
      borderRadius: BorderRadius.circular(19),
      child: panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: red, size: 30),
            const SizedBox(height: 13),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: red,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Read more  →',
              style: TextStyle(
                color: red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget remindersPanel() {
    return panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: red,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'My reminders',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              Text(
                '${reminders.length}',
                style: const TextStyle(
                  color: red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reminders.isEmpty)
            const Text(
              'Nothing planned yet. Press + to add a reminder.',
              style: TextStyle(color: muted),
            ),
          for (final task in reminders) ...[
            const Divider(),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: red,
                  size: 21,
                ),
                const SizedBox(width: 11),
                Expanded(child: Text(task)),
                IconButton(
                  tooltip: 'Remove reminder',
                  onPressed: () => removeReminder(task),
                  icon: const Icon(Icons.close, size: 19),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => addReminder(),
            icon: const Icon(Icons.add),
            label: const Text('Add reminder'),
          ),
        ],
      ),
    );
  }

  Widget home(bool wide) {
    final library = service(
      Icons.local_library_outlined,
      'Library',
      'Study resources and reading',
      'Use this section to plan library study, find learning materials and organise your reading tasks.',
      'Visit the university library',
    );

    final career = service(
      Icons.work_outline,
      'Career Center',
      'Internships and career planning',
      'Plan your CV, internship search and questions for the university Career Center.',
      'Prepare CV for Career Center',
    );

    final exchange = announcement(
      Icons.public,
      'OPPORTUNITIES',
      'International programmes',
      'Interested in an exchange or a double degree? Save a reminder to check requirements and deadlines with the university.',
    );

    final projects = announcement(
      Icons.code,
      'STUDENT LIFE',
      'Hackathons and projects',
      'Take part in university projects, practise teamwork and develop your ideas.',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: hero(true)),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: red,
                        size: 32,
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        'Made for IITU students',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Save clubs you like and keep your study plans nearby.',
                        style: TextStyle(
                          color: muted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: () => go(1),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Explore campus life'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          hero(false),
        const SizedBox(height: 32),
        heading(
          'Student services',
          'Useful places for your studies and career',
        ),
        const SizedBox(height: 16),
        if (wide)
          Row(
            children: [
              Expanded(child: library),
              const SizedBox(width: 16),
              Expanded(child: career),
            ],
          )
        else
          Column(
            children: [
              library,
              const SizedBox(height: 12),
              career,
            ],
          ),
        const SizedBox(height: 32),
        heading(
          'Announcements',
          'Ideas and opportunities for students',
        ),
        const SizedBox(height: 16),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: exchange),
              const SizedBox(width: 16),
              Expanded(child: projects),
            ],
          )
        else
          Column(
            children: [
              exchange,
              const SizedBox(height: 12),
              projects,
            ],
          ),
        const SizedBox(height: 32),
        remindersPanel(),
      ],
    );
  }

  Widget club(String title, String description, IconData icon) {
    final saved = savedClubs.contains(title);

    return panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFEAEB),
                child: Icon(icon, color: red),
              ),
              const Spacer(),
              IconButton(
                tooltip: saved
                    ? 'Remove saved club'
                    : 'Save club',
                icon: Icon(
                  saved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: red,
                ),
                onPressed: () => toggleClub(title),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => toggleClub(title),
            icon: Icon(
              saved
                  ? Icons.check
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(saved ? 'Saved' : 'Save club'),
          ),
        ],
      ),
    );
  }

  Widget campus(bool wide) {
    final clubs = [
      club(
        'Debate Club',
        'Practise public speaking and share ideas.',
        Icons.forum_outlined,
      ),
      club(
        'Enactus',
        'Build projects with a positive impact.',
        Icons.lightbulb_outline,
      ),
      club(
        'IITU Family',
        'Meet students and explore campus activities.',
        Icons.groups_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Campus life',
          'Discover communities at IITU',
        ),
        const SizedBox(height: 16),
        panel(
          Row(
            children: [
              const Icon(Icons.favorite_border, color: red),
              const SizedBox(width: 10),
              Text(
                'Saved clubs: ${savedClubs.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          color: const Color(0xFFFFF0F0),
        ),
        const SizedBox(height: 18),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: clubs[0]),
              const SizedBox(width: 14),
              Expanded(child: clubs[1]),
              const SizedBox(width: 14),
              Expanded(child: clubs[2]),
            ],
          )
        else
          Column(
            children: [
              clubs[0],
              const SizedBox(height: 13),
              clubs[1],
              const SizedBox(height: 13),
              clubs[2],
            ],
          ),
      ],
    );
  }

  Widget profileField(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: red),
          const SizedBox(width: 13),
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
                const SizedBox(height: 3),
                Text(
                  value.isEmpty
                      ? 'Tap Edit profile to add'
                      : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? muted : ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profile(bool wide) {
    final identity = panel(
      Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFFFEAEB),
            child: Icon(
              Icons.person,
              size: 56,
              color: red,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'IITU student · Almaty',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit profile'),
          ),
        ],
      ),
    );

    final details = panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          profileField(Icons.person_outline, 'Name', name),
          const Divider(),
          profileField(Icons.badge_outlined, 'Student ID', id),
          const Divider(),
          profileField(
            Icons.menu_book_outlined,
            'Programme',
            programme,
          ),
          const Divider(),
          profileField(Icons.email_outlined, 'Email', email),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('My profile', 'Your student information'),
        const SizedBox(height: 18),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: identity),
              const SizedBox(width: 15),
              Expanded(flex: 7, child: details),
            ],
          )
        else
          Column(
            children: [
              identity,
              const SizedBox(height: 14),
              details,
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 70,
      title: const IituMark(small: true),
      actions: [
        IconButton(
          tooltip: 'My reminders',
          onPressed: () => detail(
            'My reminders',
            reminders.isEmpty
                ? 'Nothing planned yet. Use the red + button to add a reminder.'
                : reminders.map((r) => '• $r').join('\n'),
            action: 'Add reminder',
            onAction: () => addReminder(),
          ),
          icon: const Icon(Icons.notifications_outlined),
        ),
        const SizedBox(width: 8),
      ],
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: ink),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  color: Colors.white,
                  child: const IituMark(small: true),
                ),
                const SizedBox(height: 13),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => go(0, drawer: true),
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Campus life'),
            onTap: () => go(1, drawer: true),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My profile'),
            onTap: () => go(2, drawer: true),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About IITU'),
            onTap: () {
              Navigator.pop(context);
              detail(
                'About IITU',
                'International Information Technology University is located in Almaty, Kazakhstan. This student hub helps organise your campus activities and plans.',
              );
            },
          ),
        ],
      ),
    ),
    body: LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 900;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 26 : 16,
                  24,
                  wide ? 26 : 16,
                  105,
                ),
                child: index == 0
                    ? home(wide)
                    : index == 1
                    ? campus(wide)
                    : profile(wide),
              ),
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => addReminder(),
      backgroundColor: red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add reminder'),
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      selectedItemColor: red,
      unselectedItemColor: muted,
      backgroundColor: Colors.white,
      onTap: (value) => go(value),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          label: 'Campus life',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    ),
  );
}