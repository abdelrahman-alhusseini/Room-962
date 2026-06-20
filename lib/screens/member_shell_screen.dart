import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/room_data.dart';
import '../theme.dart';
import '../widgets/room_widgets.dart';
import 'entry_gate_screen.dart';

class MemberShellScreen extends StatefulWidget {
  final String? memberEmail;

  const MemberShellScreen({super.key, this.memberEmail});

  @override
  State<MemberShellScreen> createState() => _MemberShellScreenState();
}

class _MemberShellScreenState extends State<MemberShellScreen> {
  int index = 0;

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const EventsScreen(),
      const AboutScreen(),
      ProfileScreen(memberEmail: widget.memberEmail),
    ];

    return RoomShell(
      child: Column(
        children: [
          _MemberTopBar(onBack: () => _leave(context)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: KeyedSubtree(
                key: ValueKey(index),
                child: pages[index],
              ),
            ),
          ),
          _BottomNav(
            index: index,
            onChanged: (next) => setState(() => index = next),
          ),
        ],
      ),
    );
  }
}

class _MemberTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _MemberTopBar({required this.onBack});

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
            'MEMBER VIEW',
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

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.crop_square_rounded,
      Icons.calendar_today_outlined,
      Icons.radio_button_unchecked_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
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
                  const SizedBox(height: 10),
                  Icon(
                    items[i],
                    color: active
                        ? RoomColors.gold
                        : RoomColors.muted.withOpacity(0.55),
                    size: 24,
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        final nextGathering = repo.nextMemberGathering;
        final announcements = repo.publishedAnnouncements.take(3).toList();

        return _ScreenScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopTitle(
                title: 'ROOM +962',
                subtitle: roomLongDate(DateTime.now()),
              ),
              const SizedBox(height: 28),
              if (nextGathering != null)
                _NextGatheringCard(event: nextGathering)
              else
                const _MutedMemberCard(
                  title: 'NO GATHERING ANNOUNCED',
                  body: 'The calendar is quiet for now.',
                ),
              const SizedBox(height: 34),
              const _SmallLabel('FROM THE ROOM'),
              const SizedBox(height: 14),
              if (announcements.isEmpty)
                const _MutedMemberCard(
                  title: 'NO NOTICE',
                  body: 'Nothing has been posted from the room yet.',
                )
              else
                for (final announcement in announcements)
                  _AnnouncementCard(
                    date: roomShortDate(
                      announcement.publishedAt ?? announcement.createdAt,
                    ),
                    body: announcement.body,
                  ),
              const SizedBox(height: 20),
              const _SmallLabel('A WORD FROM THE FOUNDER'),
              const SizedBox(height: 12),
              Text(
                'A room only matters when the people inside it make each other sharper, calmer, and more generous.',
                style: GoogleFonts.cormorantGaramond(
                  color: RoomColors.offWhite,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NextGatheringCard extends StatelessWidget {
  final RoomEventRecord event;

  const _NextGatheringCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: EventDetailScreen(event: event),
            );
          },
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: RoomColors.charcoal,
          border: Border.fromBorderSide(BorderSide(color: RoomColors.gold)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SmallLabel('NEXT GATHERING', gold: true),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.offWhite,
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.dateLine,
              style: const TextStyle(
                color: RoomColors.goldMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'VIEW DETAILS →',
              style: TextStyle(
                color: RoomColors.gold,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MutedMemberCard extends StatelessWidget {
  final String title;
  final String body;

  const _MutedMemberCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallLabel(title, gold: true),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: RoomColors.muted,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool upcoming = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final events = RoomRepository.instance.memberEvents(upcoming: upcoming);

        return _ScreenScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopTitle(title: 'GATHERINGS'),
              const SizedBox(height: 24),
              Row(
                children: [
                  _FilterText(
                    text: 'UPCOMING',
                    active: upcoming,
                    onTap: () => setState(() => upcoming = true),
                  ),
                  const SizedBox(width: 28),
                  _FilterText(
                    text: 'PAST',
                    active: !upcoming,
                    onTap: () => setState(() => upcoming = false),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              if (events.isEmpty)
                const _MutedMemberCard(
                  title: 'NO GATHERINGS',
                  body: 'The admin has not published anything in this section yet.',
                )
              else
                for (final event in events) _EventCard(event: event),
            ],
          ),
        );
      },
    );
  }
}

class _FilterText extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _FilterText({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: active ? RoomColors.gold : RoomColors.goldMuted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 1,
            color: active ? RoomColors.gold : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final RoomEventRecord event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: EventDetailScreen(event: event),
            );
          },
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: RoomColors.obsidian,
          border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SmallLabel(event.typeLabel, gold: true),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.offWhite,
                fontSize: 23,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.dateLine,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.goldMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.locationName,
              style: const TextStyle(color: RoomColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.isFull ? 'FULL · ${event.capacityLine.toUpperCase()}' : event.capacityLine.toUpperCase(),
                    style: TextStyle(
                      color: event.isFull ? RoomColors.gold : RoomColors.goldMuted,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (event.rsvpStatus != null) _StatusBadge(text: event.rsvpStatus!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatefulWidget {
  final RoomEventRecord event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? response;
  String? errorText;

  @override
  void initState() {
    super.initState();
    response = widget.event.rsvpStatus;
  }

  void _recordResponse(String next) {
    final saved = RoomRepository.instance.updateRsvp(widget.event.id, next);
    if (!saved) {
      setState(() => errorText = 'This gathering is full.');
      return;
    }
    setState(() {
      response = next;
      errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoomShell(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  '←',
                  style: TextStyle(color: RoomColors.goldMuted, fontSize: 22),
                ),
              ),
            ),
          ),
          Expanded(
            child: _ScreenScroll(
              topPadding: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmallLabel(widget.event.typeLabel, gold: true),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.title,
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.offWhite,
                      fontSize: 38,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const GoldRule(width: double.infinity, opacity: 0.35),
                  const SizedBox(height: 22),
                  Text(
                    widget.event.dateLine,
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.offWhite,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.event.locationName,
                    style: const TextStyle(
                      color: RoomColors.goldMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const GoldRule(width: double.infinity, opacity: 0.35),
                  const SizedBox(height: 22),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      color: RoomColors.offWhite,
                      fontSize: 14,
                      height: 1.8,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.event.showGuestCount
                        ? '${widget.event.capacityLine.toUpperCase()}${widget.event.isFull ? ' · FULL' : ''}'
                        : 'CAPACITY ${widget.event.capacity}${widget.event.isFull ? ' · FULL' : ''}',
                    style: TextStyle(
                      color: widget.event.isFull ? RoomColors.gold : RoomColors.goldMuted,
                      fontSize: 11,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              22,
              16,
              22,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: RoomColors.voidBlack,
              border: Border(top: BorderSide(color: RoomColors.gold)),
            ),
            child: response == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.event.isFull) ...[
                        Text(
                          'This gathering is full.',
                          style: GoogleFonts.cormorantGaramond(
                            color: RoomColors.goldMuted,
                            fontStyle: FontStyle.italic,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TextAction(
                          text: 'UNABLE TO ATTEND',
                          onTap: () => _recordResponse('UNABLE'),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _OutlineAction(
                                text: 'ATTENDING',
                                onTap: () => _recordResponse('ATTENDING'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _TextAction(
                                text: 'UNABLE TO ATTEND',
                                onTap: () => _recordResponse('UNABLE'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: RoomColors.error, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Text(
                        'RSVP changes are accepted up to 48 hours before the gathering.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: RoomColors.muted, fontSize: 11),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        response == 'ATTENDING'
                            ? 'You are attending.'
                            : 'Your response has been recorded.',
                        style: GoogleFonts.cormorantGaramond(
                          color: RoomColors.goldMuted,
                          fontStyle: FontStyle.italic,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TextAction(
                        text: 'CHANGE RESPONSE',
                        onTap: () {
                          RoomRepository.instance.updateRsvp(widget.event.id, null);
                          setState(() {
                            response = null;
                            errorText = null;
                          });
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pillars = [
      ('QUALITY', 'A community of fewer, better — not more.'),
      ('TRUST', 'Discretion is our foundation. What is said here, remains here.'),
      ('PURPOSE', 'Every gathering is curated to matter. Nothing here is accidental.'),
      ('LONGEVITY', 'Relationships that endure beyond the room.'),
    ];

    return _ScreenScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TopTitle(
            title: 'ROOM +962',
            subtitle: 'Private Members Community · Amman, Jordan',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Curated Connections.\\nMeaningful Relationships.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.offWhite,
                fontSize: 25,
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 34),
          const GoldRule(width: double.infinity, opacity: 0.35),
          const SizedBox(height: 24),
          for (final pillar in pillars)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: RoomColors.obsidian,
                border: Border.fromBorderSide(
                  BorderSide(color: RoomColors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmallLabel(pillar.$1, gold: true),
                  const SizedBox(height: 10),
                  Text(
                    pillar.$2,
                    style: const TextStyle(
                      color: RoomColors.offWhite,
                      fontSize: 14,
                      height: 1.65,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const GoldRule(width: double.infinity, opacity: 0.35),
          const SizedBox(height: 24),
          Text(
            'Members are expected to arrive with generosity, leave with discretion, and contribute with intent.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.offWhite,
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 34),
          const Center(
            child: Text(
              'MEMBERSHIP BY APPLICATION ONLY',
              style: TextStyle(
                color: RoomColors.goldMuted,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String? memberEmail;

  const ProfileScreen({super.key, this.memberEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool showingBack = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void flip() {
    if (showingBack) {
      controller.reverse();
    } else {
      controller.forward();
    }
    setState(() => showingBack = !showingBack);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final member = RoomRepository.instance.activeMemberForEmail(widget.memberEmail);

        if (member == null) {
          return _ScreenScroll(
            child: Column(
              children: const [
                SizedBox(height: 40),
                _MutedMemberCard(
                  title: 'NO ACTIVE MEMBERSHIP',
                  body: 'This member access is no longer active.',
                ),
              ],
            ),
          );
        }

        return _ScreenScroll(
          child: Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: flip,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final value = controller.value;
                    final angle = value * math.pi;
                    final showBack = value > 0.5;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: showBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _MembershipCardBack(member: member),
                            )
                          : _MembershipCardFront(member: member),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              const _SmallLabel('SHARE'),
              const SizedBox(height: 12),
              _TextAction(text: 'SHARE MEMBERSHIP CARD', onTap: () {}),
              const SizedBox(height: 28),
              const GoldRule(width: double.infinity, opacity: 0.35),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: _SmallLabel('YOUR MEMBERSHIP'),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'MEMBER SINCE', value: member.yearJoined.toString()),
              _DetailRow(label: 'MEMBER NUMBER', value: member.memberNumber),
              _DetailRow(label: 'TIER', value: _tierLabel(member.tier)),
              _DetailRow(label: 'STATUS', value: member.status == 'active' ? 'Active' : member.status),
              const _DetailRow(label: 'GATHERINGS ATTENDED', value: '7'),
              const SizedBox(height: 24),
              const GoldRule(width: double.infinity, opacity: 0.35),
              const SizedBox(height: 24),
              const Text(
                'ROOM +962 · AMMAN, JORDAN',
                style: TextStyle(
                  color: RoomColors.goldMuted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'v1.0.0',
                style: TextStyle(color: RoomColors.muted, fontSize: 9),
              ),
              const SizedBox(height: 28),
              InkWell(
                onTap: () {
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
                },
                child: const Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: RoomColors.muted,
                    fontSize: 10,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _tierLabel(String tier) {
  switch (tier) {
    case 'founding':
      return 'Founding Member';
    case 'under_35':
      return 'Under 35';
    case 'corporate':
      return 'Corporate';
    default:
      return 'Full Member';
  }
}

class _MembershipCardFront extends StatelessWidget {
  final RoomMemberRecord member;

  const _MembershipCardFront({required this.member});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RoomColors.charcoal,
          border: Border.all(color: RoomColors.gold.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              child: Text(
                'ROOM +962',
                style: TextStyle(
                  color: RoomColors.gold,
                  fontSize: 13,
                  letterSpacing: 3,
                ),
              ),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: Text(
                '◆',
                style: TextStyle(color: RoomColors.gold, fontSize: 10),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: RoomColors.gold, width: 1.5),
                      color: RoomColors.slate,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: RoomColors.goldMuted,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    member.fullName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.offWhite,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.professionalField.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: RoomColors.goldMuted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _CardMeta(label: 'MEMBER SINCE', value: member.yearJoined.toString()),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _CardMeta(label: 'TIER', value: _tierLabel(member.tier)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembershipCardBack extends StatelessWidget {
  final RoomMemberRecord member;

  const _MembershipCardBack({required this.member});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RoomColors.charcoal,
          border: Border.all(color: RoomColors.gold.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SmallLabel('MEMBERSHIP QR'),
            const SizedBox(height: 12),
            QrImageView(
              data: 'room962:${member.memberNumber}:${member.fullName}:${member.yearJoined}',
              size: 132,
              backgroundColor: Colors.transparent,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: RoomColors.gold,
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: RoomColors.gold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Room +962 · Amman, Jordan',
              style: TextStyle(color: RoomColors.goldMuted, fontSize: 9),
            ),
            const SizedBox(height: 4),
            Text(
              member.memberNumber,
              style: const TextStyle(color: RoomColors.muted, fontSize: 9),
            ),
            const SizedBox(height: 8),
            const Text(
              'This card is personal and non-transferable.',
              style: TextStyle(
                color: RoomColors.muted,
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  final String label;
  final String value;

  const _CardMeta({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          label == 'TIER' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RoomColors.goldMuted,
            fontSize: 8,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.gold,
            fontSize: label == 'TIER' ? 12 : 16,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RoomColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: RoomColors.goldMuted,
                fontSize: 10,
                letterSpacing: 1.3,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: RoomColors.offWhite,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;

  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final attending = text == 'ATTENDING';
    final label = text == 'UNABLE' ? 'UNABLE TO ATTEND' : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: attending ? RoomColors.gold : Colors.transparent,
        border: Border.all(
          color: attending ? RoomColors.gold : RoomColors.goldMuted,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: attending ? RoomColors.voidBlack : RoomColors.goldMuted,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlineAction({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: RoomColors.gold),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: RoomColors.gold,
            fontSize: 11,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _TextAction({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: RoomColors.goldMuted,
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String date;
  final String body;

  const _AnnouncementCard({
    required this.date,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: RoomColors.obsidian,
        border: Border(top: BorderSide(color: RoomColors.gold)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date.toUpperCase(),
            style: const TextStyle(
              color: RoomColors.goldMuted,
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: RoomColors.offWhite,
              fontSize: 14,
              height: 1.75,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _TopTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.gold,
            fontSize: 36,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.goldMuted,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 22),
        const GoldRule(width: double.infinity, opacity: 0.35),
      ],
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String text;
  final bool gold;

  const _SmallLabel(this.text, {this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: gold ? RoomColors.gold : RoomColors.goldMuted,
        fontSize: 10,
        letterSpacing: 1.8,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ScreenScroll extends StatelessWidget {
  final Widget child;
  final double topPadding;

  const _ScreenScroll({
    required this.child,
    this.topPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: child,
        ),
      ),
    );
  }
}
