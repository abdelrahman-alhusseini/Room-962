import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/room_data.dart';
import '../theme.dart';
import '../widgets/room_widgets.dart';
import 'entry_gate_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int index = 0;

  final pages = const [
    AdminApplicantsScreen(),
    AdminGatheringsScreen(),
    AdminMembersScreen(),
    AdminNoticesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return RoomShell(
      child: Column(
        children: [
          _AdminTopBar(onBack: () => _leave(context)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: KeyedSubtree(
                key: ValueKey(index),
                child: pages[index],
              ),
            ),
          ),
          _AdminBottomNav(
            index: index,
            onChanged: (next) => setState(() => index = next),
          ),
        ],
      ),
    );
  }

  void _leave(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: const EntryGateScreen(),
          );
        },
      ),
      (route) => false,
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _AdminTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            child: const Text(
              'BACK',
              style: TextStyle(
                color: RoomColors.goldMuted,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'ADMIN VIEW',
            style: TextStyle(
              color: RoomColors.muted,
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _AdminBottomNav({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.fact_check_outlined, 'APPLICANTS'),
      (Icons.calendar_month_outlined, 'GATHERINGS'),
      (Icons.people_outline, 'MEMBERS'),
      (Icons.campaign_outlined, 'ANNOUNCE'),
    ];

    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border(top: BorderSide(color: RoomColors.border, width: 1)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 16,
                    height: 2,
                    color: active ? RoomColors.gold : Colors.transparent,
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    items[i].$1,
                    color: active
                        ? RoomColors.gold
                        : RoomColors.muted.withOpacity(0.55),
                    size: 21,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? RoomColors.gold : RoomColors.muted,
                      fontSize: 8,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AdminApplicantsScreen extends StatelessWidget {
  const AdminApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        return _AdminScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdminHeader(
                title: 'Applicants',
              ),
              const SizedBox(height: 22),
              _StatsRow(
                items: [
                  ('PENDING', repo.pendingApplications.toString()),
                  ('MEMBERS', repo.members.length.toString()),
                  ('ALERTS', repo.unreadAdminNotifications.toString()),
                ],
              ),
              const SizedBox(height: 24),
              _NotificationCenter(repo: repo),
              const SizedBox(height: 26),
              const _AdminLabel('REVIEW'),
              const SizedBox(height: 14),
              if (repo.applications.isEmpty)
                const _EmptyAdminCard(
                  text: 'No applications have been received yet.',
                )
              else
                for (final application in repo.applications)
                  _ApplicantReviewCard(application: application),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationCenter extends StatelessWidget {
  final RoomRepository repo;

  const _NotificationCenter({required this.repo});

  @override
  Widget build(BuildContext context) {
    final notifications = repo.adminNotifications.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: RoomColors.charcoal,
        border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _AdminLabel('ALERTS')),
              if (repo.unreadAdminNotifications > 0)
                InkWell(
                  onTap: repo.markAdminNotificationsRead,
                  child: const Text(
                    'MARK READ',
                    style: TextStyle(
                      color: RoomColors.gold,
                      fontSize: 9,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (notifications.isEmpty)
            const Text(
              'No alerts.',
              style: TextStyle(color: RoomColors.muted, fontSize: 12),
            )
          else
            for (final notification in notifications)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 5, right: 10),
                      decoration: BoxDecoration(
                        color: notification.read
                            ? RoomColors.border
                            : RoomColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title.toUpperCase(),
                            style: const TextStyle(
                              color: RoomColors.goldMuted,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: const TextStyle(
                              color: RoomColors.offWhite,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${notification.channel} · ${notification.target}',
                            style: const TextStyle(
                              color: RoomColors.goldMuted,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ],
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

class _ApplicantReviewCard extends StatelessWidget {
  final RoomApplicationRecord application;

  const _ApplicantReviewCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final repo = RoomRepository.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: RoomColors.goldMuted,
          collapsedIconColor: RoomColors.goldMuted,
          title: Text(
            application.fullName,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.offWhite,
              fontSize: 22,
              letterSpacing: 0.6,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${application.professionalField} · ${application.city} · ${application.email}',
              style: const TextStyle(
                color: RoomColors.goldMuted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
          trailing: _AdminStatus(status: application.status),
          children: [
            const GoldRule(width: double.infinity, opacity: 0.25),
            const SizedBox(height: 16),
            _AdminDetailGrid(
              items: [
                ('NATIONALITY', application.nationality),
                ('BIRTH YEAR', application.birthYear),
                ('NOMINATOR', application.nominatorName),
                ('ORGANISATION', application.organisation.isEmpty ? '—' : application.organisation),
                ('RECEIVED', roomShortDate(application.submittedAt)),
                ('STATUS', application.status.toUpperCase()),
              ],
            ),
            const SizedBox(height: 18),
            for (final entry in application.answers.asMap().entries)
              _AnswerBlock(index: entry.key + 1, answer: entry.value),
            const SizedBox(height: 18),
            if (application.isPending)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _AdminAction(
                    text: 'UNDER REVIEW',
                    onTap: () => repo.markApplicationUnderReview(application.id),
                  ),
                  _AdminAction(
                    text: 'ACCEPT',
                    filled: true,
                    onTap: () => repo.acceptApplication(application.id),
                  ),
                  _AdminAction(
                    text: 'DECLINE',
                    muted: true,
                    onTap: () => repo.declineApplication(application.id),
                  ),
                ],
              )
            else
              Text(
                application.reviewNote ?? 'Reviewed.',
                style: GoogleFonts.cormorantGaramond(
                  color: RoomColors.goldMuted,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AdminGatheringsScreen extends StatefulWidget {
  const AdminGatheringsScreen({super.key});

  @override
  State<AdminGatheringsScreen> createState() => _AdminGatheringsScreenState();
}

class _AdminGatheringsScreenState extends State<AdminGatheringsScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final capacityController = TextEditingController();

  String type = 'monthly_dinner';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  bool published = false;
  bool visibleToAll = true;
  bool showGuestCount = true;
  bool notifyMembers = true;
  String? errorText;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: RoomColors.gold,
              onPrimary: RoomColors.voidBlack,
              surface: RoomColors.obsidian,
              onSurface: RoomColors.offWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: RoomColors.gold,
              onPrimary: RoomColors.voidBlack,
              surface: RoomColors.obsidian,
              onSurface: RoomColors.offWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _saveEvent() {
    if (titleController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      setState(() {
        errorText = 'Name, location, and description are required.';
      });
      return;
    }

    final capacity = int.tryParse(capacityController.text.trim());
    if (capacity == null || capacity <= 0) {
      setState(() {
        errorText = 'Capacity is required.';
      });
      return;
    }

    RoomRepository.instance.createEvent(
      RoomEventRecord(
        id: 'event-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        title: titleController.text.trim(),
        eventDate: selectedDate,
        locationName: locationController.text.trim(),
        description: descriptionController.text.trim(),
        capacity: capacity,
        isPublished: published,
        visibleToAllMembers: visibleToAll,
        showGuestCount: showGuestCount,
        notifyMembers: notifyMembers,
      ),
    );

    titleController.clear();
    locationController.clear();
    descriptionController.clear();
    capacityController.clear();
    setState(() {
      errorText = null;
      published = false;
      visibleToAll = true;
      showGuestCount = true;
      notifyMembers = true;
      selectedDate = DateTime.now().add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        return _AdminScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdminHeader(
                title: 'Gatherings',
              ),
              const SizedBox(height: 24),
              _AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AdminLabel('NEW GATHERING'),
                    const SizedBox(height: 18),
                    LineDropdownField(
                      label: 'TYPE',
                      value: type,
                      options: const [
                        'monthly_dinner',
                        'quarterly_experience',
                        'spontaneous',
                        'annual_celebration',
                      ],
                      onChanged: (value) => setState(() => type = value),
                    ),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'NAME',
                      controller: titleController,
                      requiredField: true,
                    ),
                    const SizedBox(height: 18),
                    _AdminDateField(
                      label: 'DATE AND TIME',
                      value: roomLongDate(selectedDate, includeTime: true),
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'LOCATION',
                      controller: locationController,
                      requiredField: true,
                    ),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'CAPACITY',
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      requiredField: true,
                    ),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'DESCRIPTION',
                      controller: descriptionController,
                      maxLines: 4,
                      requiredField: true,
                    ),
                    const SizedBox(height: 20),
                    _LineToggle(
                      label: 'PUBLISH',
                      value: published,
                      onChanged: (value) => setState(() => published = value),
                    ),
                    _LineToggle(
                      label: 'ALL MEMBERS',
                      value: visibleToAll,
                      onChanged: (value) => setState(() => visibleToAll = value),
                    ),
                    _LineToggle(
                      label: 'SHOW RSVP COUNT',
                      value: showGuestCount,
                      onChanged: (value) => setState(() => showGuestCount = value),
                    ),
                    _LineToggle(
                      label: 'SEND NOTIFICATION',
                      value: notifyMembers,
                      onChanged: (value) => setState(() => notifyMembers = value),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: RoomColors.error,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _AdminAction(
                      text: 'SAVE',
                      filled: true,
                      onTap: _saveEvent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const _AdminLabel('CALENDAR'),
              const SizedBox(height: 14),
              for (final event in repo.events)
                _AdminEventCard(event: event),
            ],
          ),
        );
      },
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  final RoomEventRecord event;

  const _AdminEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final visibleLabel = event.visibleToAllMembers ? 'ALL MEMBERS' : 'SELECTED ONLY';
    final status = event.isPublished ? (event.isFull ? 'FULL' : 'LIVE') : 'DRAFT';

    return _AdminCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _AdminLabel(event.typeLabel)),
              _AdminStatus(status: status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.title,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.offWhite,
              fontSize: 24,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.dateLine,
            style: const TextStyle(
              color: RoomColors.goldMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.locationName} · $visibleLabel · ${event.capacityLine} · ${event.showGuestCount ? 'RSVP count shown' : 'RSVP count hidden'}',
            style: const TextStyle(
              color: RoomColors.muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: const TextStyle(
              color: RoomColors.offWhite,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AdminAction(
                text: event.isPublished ? 'HIDE' : 'PUBLISH',
                onTap: () => RoomRepository.instance.toggleEventPublished(event.id),
              ),
              _AdminAction(
                text: 'DELETE',
                muted: true,
                onTap: () => RoomRepository.instance.deleteEvent(event.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        return _AdminScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdminHeader(
                title: 'Members',
              ),
              const SizedBox(height: 22),
              _StatsRow(
                items: [
                  ('ACTIVE', repo.members.where((m) => m.status == 'active').length.toString()),
                  ('ACCEPTED', repo.applications.where((a) => a.status == 'accepted').length.toString()),
                  ('FULL', repo.events.where((e) => e.isFull).length.toString()),
                ],
              ),
              const SizedBox(height: 24),
              for (final member in repo.members)
                _AdminCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.fullName,
                              style: GoogleFonts.cormorantGaramond(
                                color: RoomColors.offWhite,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          _AdminStatus(status: member.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _AdminDetailGrid(
                        items: [
                          ('EMAIL', member.email),
                          ('FIELD', member.professionalField),
                          ('TIER', member.tier.toUpperCase()),
                          ('NUMBER', member.memberNumber),
                          ('MEMBER SINCE', member.yearJoined.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _AdminAction(
                        text: 'REMOVE ACCESS',
                        muted: true,
                        onTap: () => RoomRepository.instance.removeMember(member.id),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  bool publish = true;
  String? editingId;
  String? errorText;

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void _saveAnnouncement() {
    if (bodyController.text.trim().isEmpty) {
      setState(() => errorText = 'Message is required.');
      return;
    }

    if (editingId == null) {
      RoomRepository.instance.createAnnouncement(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        isPublished: publish,
      );
    } else {
      RoomRepository.instance.updateAnnouncement(
        id: editingId!,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        isPublished: publish,
      );
    }

    _clearForm();
  }

  void _editAnnouncement(RoomAnnouncementRecord announcement) {
    setState(() {
      editingId = announcement.id;
      titleController.text = announcement.title;
      bodyController.text = announcement.body;
      publish = announcement.isPublished;
      errorText = null;
    });
  }

  void _clearForm() {
    titleController.clear();
    bodyController.clear();
    setState(() {
      editingId = null;
      publish = true;
      errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        return _AdminScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdminHeader(
                title: 'Announcements',
              ),
              const SizedBox(height: 24),
              _AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminLabel(editingId == null ? 'NEW ANNOUNCEMENT' : 'EDIT ANNOUNCEMENT'),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'TITLE',
                      controller: titleController,
                    ),
                    const SizedBox(height: 18),
                    LineTextField(
                      label: 'MESSAGE',
                      controller: bodyController,
                      maxLines: 5,
                      requiredField: true,
                    ),
                    const SizedBox(height: 18),
                    _LineToggle(
                      label: 'PUBLISH',
                      value: publish,
                      onChanged: (value) => setState(() => publish = value),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: RoomColors.error,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _AdminAction(
                          text: editingId == null ? 'SAVE' : 'UPDATE',
                          filled: true,
                          onTap: _saveAnnouncement,
                        ),
                        if (editingId != null)
                          _AdminAction(
                            text: 'CANCEL',
                            muted: true,
                            onTap: _clearForm,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const _AdminLabel('HISTORY'),
              const SizedBox(height: 14),
              if (repo.announcements.isEmpty)
                const _EmptyAdminCard(text: 'No announcements yet.')
              else
                for (final announcement in repo.announcements)
                  _AdminCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title.isEmpty
                                    ? 'Untitled'
                                    : announcement.title,
                                style: GoogleFonts.cormorantGaramond(
                                  color: RoomColors.offWhite,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            _AdminStatus(
                              status: announcement.isPublished ? 'LIVE' : 'DRAFT',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          announcement.body,
                          style: const TextStyle(
                            color: RoomColors.offWhite,
                            fontSize: 13,
                            height: 1.7,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          roomShortDate(announcement.publishedAt ?? announcement.createdAt),
                          style: const TextStyle(
                            color: RoomColors.goldMuted,
                            fontSize: 10,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _AdminAction(
                              text: 'EDIT',
                              onTap: () => _editAnnouncement(announcement),
                            ),
                            _AdminAction(
                              text: announcement.isPublished ? 'HIDE' : 'PUBLISH',
                              onTap: () => RoomRepository.instance.toggleAnnouncementPublished(announcement.id),
                            ),
                            _AdminAction(
                              text: 'DELETE',
                              muted: true,
                              onTap: () => RoomRepository.instance.deleteAnnouncement(announcement.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _AdminHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.offWhite,
            fontSize: 36,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              color: RoomColors.goldMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const GoldRule(width: double.infinity, opacity: 0.22),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<(String, String)> items;

  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        if (narrow) {
          return Column(
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StatCard(label: item.$1, value: item.$2),
                    ))
                .toList(),
          );
        }

        return Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _StatCard(label: item.$1, value: item.$2),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: RoomColors.goldMuted,
              fontSize: 9,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.offWhite,
              fontSize: 28,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const _AdminCard({required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
      ),
      child: child,
    );
  }
}

class _EmptyAdminCard extends StatelessWidget {
  final String text;

  const _EmptyAdminCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Text(
        text,
        style: const TextStyle(
          color: RoomColors.muted,
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}

class _AdminLabel extends StatelessWidget {
  final String text;

  const _AdminLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: RoomColors.goldMuted,
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AdminStatus extends StatelessWidget {
  final String status;

  const _AdminStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final isGood = normalized == 'ACCEPTED' ||
        normalized == 'LIVE' ||
        normalized == 'PUBLISHED' ||
        normalized == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isGood ? RoomColors.gold.withOpacity(0.10) : Colors.transparent,
        border: Border.all(
          color: isGood ? RoomColors.gold : RoomColors.border,
          width: 1,
        ),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: isGood ? RoomColors.goldPale : RoomColors.goldMuted,
          fontSize: 8,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AnswerBlock extends StatelessWidget {
  final int index;
  final String answer;

  const _AnswerBlock({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION $index',
            style: const TextStyle(
              color: RoomColors.goldMuted,
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              color: RoomColors.offWhite,
              fontSize: 13,
              height: 1.7,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDetailGrid extends StatelessWidget {
  final List<(String, String)> items;

  const _AdminDetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 560;
        final width = twoColumns ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: RoomColors.goldMuted,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: RoomColors.offWhite,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AdminAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool filled;
  final bool muted;

  const _AdminAction({
    required this.text,
    required this.onTap,
    this.filled = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? RoomColors.gold.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: muted ? RoomColors.border : RoomColors.gold,
            width: 1,
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: muted ? RoomColors.muted : RoomColors.goldPale,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


class _AdminDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AdminDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: RoomColors.goldMuted,
            size: 18,
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: RoomColors.offWhite,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _LineToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LineToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? RoomColors.gold.withOpacity(0.12) : Colors.transparent,
                border: Border.all(
                  color: value ? RoomColors.gold : RoomColors.border,
                  width: 1,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      color: RoomColors.goldPale,
                      size: 15,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: RoomColors.goldMuted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminScroll extends StatelessWidget {
  final Widget child;

  const _AdminScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: child,
        ),
      ),
    );
  }
}
