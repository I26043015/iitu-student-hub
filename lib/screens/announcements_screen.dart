import 'package:flutter/material.dart';
import '../models/campus_content.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, this.savedIds});
  final Set<String>? savedIds;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final Set<String> bookmarkedIds;
  final scroll = ScrollController();
  bool opening = false;

  @override
  void initState() {
    super.initState();
    // The shared set also keeps bookmarks when reopening from Home this session.
    bookmarkedIds = widget.savedIds ?? <String>{};
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void toggleBookmark(String id) => setState(() {
    if (!bookmarkedIds.add(id)) bookmarkedIds.remove(id);
  });

  Future<void> openAnnouncement(Announcement item) async {
    if (opening) return;
    opening = true;
    try {
      // push leaves this screen mounted: its scroll and bookmarks survive Back.
      await Navigator.push<void>(context, MaterialPageRoute<void>(
        settings: RouteSettings(name: '/announcement/${item.id}'),
        builder: (_) => AnnouncementDetailScreen(item: item),
      ));
    } finally {
      opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            // One bounded, primary scroll view contains the header and cards.
            child: ListView.builder(
              key: const PageStorageKey<String>('announcements-list'),
              controller: scroll,
              padding: const EdgeInsets.all(16),
              itemCount: campusAnnouncements.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Campus noticeboard',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Demonstration data — fictional campus notices.'),
                        const SizedBox(height: 8),
                        Text('${campusAnnouncements.length} announcements · '
                            '${bookmarkedIds.length} bookmarked'),
                      ],
                    ),
                  );
                }
                final item = campusAnnouncements[index - 1];
                final saved = bookmarkedIds.contains(item.id);
                return Card(
                  key: ValueKey('announcement-card-${item.id}'),
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(builder: (context, constraints) {
                    // At larger text sizes the badge moves into the subtitle,
                    // freeing horizontal room without dropping any metadata.
                    final compact = constraints.maxWidth < 400 ||
                        MediaQuery.textScalerOf(context).scale(14) > 21;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                      leading: compact ? null : CircleAvatar(
                        backgroundColor: color.withValues(alpha: .08),
                        child: Icon(item.icon, color: color),
                      ),
                      title: Text(item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          if (compact) Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Icon(item.icon, color: color),
                          ),
                          Text('${item.category} • ${item.date}'),
                          const SizedBox(height: 8),
                          Text(item.preview),
                        ],
                      ),
                      trailing: IconButton(
                        key: ValueKey('bookmark-${item.id}'),
                        tooltip: saved ? 'Remove bookmark' : 'Bookmark',
                        isSelected: saved,
                        color: color,
                        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () => toggleBookmark(item.id),
                      ),
                      onTap: () => openAnnouncement(item),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Announcement details')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft,
                  child: Icon(item.icon, size: 42,
                    color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 20),
                Text(item.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('${item.category} • ${item.date}'),
                const SizedBox(height: 24),
                SelectableText(item.detail,
                  style: const TextStyle(fontSize: 17, height: 1.6)),
                const SizedBox(height: 24),
                const Text('Demonstration data — this is not an official campus notice.'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
