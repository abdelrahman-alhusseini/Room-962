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
          _QuietNavText(text: 'BACK', onTap: onBack),
          const Spacer(),
          Text(
            'MEMBER VIEW',
            style: GoogleFonts.dmSans(
              color: RoomColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
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
    final items = ['HOME', 'GATHERINGS', 'ABOUT', 'PROFILE'];

    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      color: RoomColors.voidBlack,
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: _labelStyle(
                    color: active ? RoomColors.gold : RoomColors.muted,
                    size: 11,
                    spacing: 1.8,
                  ),
                  child: Text(items[i]),
                ),
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
              const SizedBox(height: 30),
              if (nextGathering != null)
                _NextGatheringCard(event: nextGathering)
              else
                const _EmptyLine(
                  title: 'NO GATHERING ANNOUNCED',
                  body: 'The next gathering is being arranged. Members will be notified.',
                ),
              const SizedBox(height: 40),
              const _SmallLabel('FROM THE ROOM'),
              const SizedBox(height: 8),
              if (announcements.isEmpty)
                const _EmptyLine(
                  title: 'NO NOTICE',
                  body: 'Nothing has been posted from the room yet.',
                )
              else
                for (final announcement in announcements)
                  _AnnouncementEntry(
                    date: roomShortDate(
                      announcement.publishedAt ?? announcement.createdAt,
                    ),
                    body: announcement.body,
                  ),
              const SizedBox(height: 48),
              const GoldRule(width: double.infinity, opacity: 0.35),
              const SizedBox(height: 28),
              const _SmallLabel('FROM THE FOUNDER'),
              const SizedBox(height: 18),
              Text(
                'A room only matters when the people inside it make each other sharper, calmer, and more generous.',
                style: GoogleFonts.cormorantGaramond(
                  color: RoomColors.offWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
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
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        color: RoomColors.obsidian,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SmallLabel('NEXT GATHERING', gold: true),
            const SizedBox(height: 14),
            Text(
              event.title,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            _MetaText(event.homeDateLine, color: RoomColors.gold),
            const SizedBox(height: 18),
            const _SmallLabel('ENTER →', gold: true),
          ],
        ),
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyLine({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RoomColors.gold, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallLabel(title, gold: true),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.muted,
              fontSize: 15,
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
              const _TopTitle(title: 'GATHERINGS', structural: true),
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
              const SizedBox(height: 20),
              if (events.isEmpty)
                const _EmptyLine(
                  title: 'NO GATHERINGS',
                  body: 'The next gathering is being arranged. Members will be notified.',
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
            style: _labelStyle(
              color: active ? RoomColors.gold : RoomColors.muted,
              size: 11,
              spacing: 1.7,
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
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: RoomColors.gold, width: 0.5)),
        ),
        child: Container(
          width: double.infinity,
          color: RoomColors.obsidian,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _SmallLabel(event.typeLabel, gold: true),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.offWhite,
                fontSize: 34,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 10),
            _MetaText(event.dateLine, color: RoomColors.gold),
            const SizedBox(height: 6),
            _MetaText(event.locationName, color: RoomColors.muted),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.isFull
                        ? 'THIS GATHERING IS FULL'
                        : event.capacityLine.toUpperCase(),
                    style: _labelStyle(
                      color: event.isFull ? RoomColors.gold : RoomColors.muted,
                      size: 11,
                      spacing: 1.1,
                    ),
                  ),
                ),
                if (event.rsvpStatus != null) _StatusBadge(text: event.rsvpStatus!),
              ],
            ),
            ],
          ),
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
              child: _QuietNavText(
                text: 'BACK',
                onTap: () => Navigator.of(context).pop(),
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
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const GoldRule(width: double.infinity, opacity: 0.35),
                  const SizedBox(height: 22),
                  _MetaText(widget.event.dateLine, color: RoomColors.offWhite, size: 14),
                  const SizedBox(height: 10),
                  _MetaText(widget.event.locationName, color: const Color(0xFF7A7068)),
                  const SizedBox(height: 24),
                  const GoldRule(width: double.infinity, opacity: 0.35),
                  const SizedBox(height: 24),
                  Text(
                    widget.event.description,
                    style: GoogleFonts.dmSans(
                      color: RoomColors.offWhite,
                      fontSize: 15,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const GoldRule(width: double.infinity, opacity: 0.25),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.showGuestCount
                        ? (widget.event.isFull
                            ? 'THIS GATHERING IS FULL'
                            : widget.event.capacityLine.toUpperCase())
                        : 'CAPACITY ${widget.event.capacity}${widget.event.isFull ? ' · FULL' : ''}',
                    style: _labelStyle(
                      color: widget.event.isFull ? RoomColors.gold : RoomColors.muted,
                      size: 11,
                      spacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              22,
              18,
              22,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: RoomColors.voidBlack,
              border: Border(top: BorderSide(color: RoomColors.gold, width: 0.5)),
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
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TextAction(
                          text: 'UNABLE TO ATTEND',
                          onTap: () => _recordResponse('UNABLE'),
                        ),
                      ] else ...[
                        _FilledAction(
                          text: 'ATTENDING',
                          onTap: () => _recordResponse('ATTENDING'),
                        ),
                        const SizedBox(height: 8),
                        _TextAction(
                          text: 'UNABLE TO ATTEND',
                          onTap: () => _recordResponse('UNABLE'),
                        ),
                      ],
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: RoomColors.error, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _MetaText(
                        'RSVP changes are accepted up to 48 hours before the gathering.',
                        color: RoomColors.muted,
                        size: 12,
                        italic: true,
                        center: true,
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
                          fontSize: 18,
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
    return _ScreenScroll(
      topPadding: 28,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AboutHeader(),
          SizedBox(height: 32),
          _AboutBody(),
          SizedBox(height: 28),
          _AboutValue(
            label: 'QUALITY',
            lines: [
              'The room has always been small. That is the point.',
              'Size is not a constraint. It is the decision.',
            ],
          ),
          _AboutValue(
            label: 'TRUST',
            lines: [
              'What is said in this room stays in this room.',
              'This is not a rule. It is the culture.',
            ],
          ),
          _AboutValue(
            label: 'PURPOSE',
            lines: [
              'Nothing here is accidental.',
              'Every gathering, every seat, every conversation — considered.',
            ],
          ),
          _AboutValue(
            label: 'LONGEVITY',
            lines: [
              'The room is where it starts.',
              'What happens after is the point.',
            ],
          ),
          SizedBox(height: 56),
          _AboutClosing(),
          SizedBox(height: 56),
        ],
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROOM +962',
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.gold,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.24,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Private Members Community · Amman, Jordan',
          style: GoogleFonts.dmSans(
            color: const Color(0xFF7A7068),
            fontSize: 13,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        const GoldRule(width: double.infinity, opacity: 0.45),
      ],
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AboutParagraph(
          'We started with a simple question: who in Amman deserves to be in the same room?',
        ),
        const SizedBox(height: 16),
        const _AboutParagraph(
          'Not the loudest. Not the most connected. Not those with the most impressive title on a business card.',
        ),
        const SizedBox(height: 16),
        const _AboutParagraph(
          'The ones who make the people around them think differently. The ones who give before they take. The ones who, when they leave a gathering, are missed.',
        ),
        const SizedBox(height: 16),
        Text(
          'Room +962 was built for them.',
          style: GoogleFonts.dmSans(
            color: RoomColors.offWhite,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _AboutParagraph extends StatelessWidget {
  final String text;

  const _AboutParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        color: RoomColors.offWhite,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.7,
      ),
    );
  }
}

class _AboutValue extends StatelessWidget {
  final String label;
  final List<String> lines;

  const _AboutValue({required this.label, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RoomColors.gold, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: RoomColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.65,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lines.length; i++) ...[
            Text(
              lines[i],
              style: GoogleFonts.dmSans(
                color: RoomColors.offWhite,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
            if (i != lines.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _AboutClosing extends StatelessWidget {
  const _AboutClosing();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Arrive with generosity.\nLeave with discretion.\nContribute with intent.',
        textAlign: TextAlign.center,
        style: GoogleFonts.cormorantGaramond(
          color: RoomColors.gold,
          fontSize: 22,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          height: 1.8,
        ),
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
  static final Set<String> _seenProfileWelcome = <String>{};

  late final AnimationController controller;
  bool showingBack = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
                _EmptyLine(
                  title: 'NO ACTIVE MEMBERSHIP',
                  body: 'This member access is no longer active.',
                ),
              ],
            ),
          );
        }

        final welcomeKey = member.email.toLowerCase();
        final showWelcome = !_seenProfileWelcome.contains(welcomeKey);
        if (showWelcome) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _seenProfileWelcome.add(welcomeKey);
          });
        }

        return _ScreenScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _TextAction(
                  text: 'SHARE MEMBERSHIP CARD',
                  onTap: () {},
                  compact: true,
                  gold: true,
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 12),
              _MetaText(
                'Tap to reveal your access credential.',
                color: RoomColors.muted,
                size: 12,
                italic: true,
                center: true,
              ),
              if (showWelcome) ...[
                const SizedBox(height: 22),
                Text(
                  'Your place in this room is yours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: RoomColors.goldMuted,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const GoldRule(width: double.infinity, opacity: 0.35),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: _SmallLabel('YOUR RECORD', gold: true),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'MEMBER SINCE', value: member.yearJoined.toString()),
              _DetailRow(label: 'MEMBER NO.', value: member.memberNumber),
              _DetailRow(label: 'TIER', value: _tierLabel(member.tier), tier: true),
              const _DetailRow(label: 'GATHERINGS', value: '7'),
              const SizedBox(height: 28),
              const GoldRule(width: double.infinity, opacity: 0.35),
              const SizedBox(height: 24),
              _MetaText(
                'ROOM +962 · AMMAN, JORDAN',
                color: RoomColors.gold,
                size: 10,
                center: true,
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
                child: Text(
                  'SIGN OUT',
                  textAlign: TextAlign.center,
                  style: _labelStyle(color: RoomColors.error, size: 11, spacing: 1.4),
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
      return 'Member';
  }
}

class _MembershipCardFront extends StatelessWidget {
  final RoomMemberRecord member;

  const _MembershipCardFront({required this.member});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.75,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RoomColors.charcoal,
          border: const Border(top: BorderSide(color: RoomColors.gold, width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.44),
              blurRadius: 38,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                'ROOM +962',
                style: GoogleFonts.cormorantGaramond(
                  color: RoomColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: Text('◆', style: TextStyle(color: RoomColors.gold, fontSize: 14)),
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
                      border: Border.all(color: RoomColors.gold, width: 1),
                      color: RoomColors.slate,
                    ),
                    child: Center(
                      child: Text(
                        _initials(member.fullName),
                        style: GoogleFonts.cormorantGaramond(
                          color: RoomColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    member.fullName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.offWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.professionalField.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: _labelStyle(
                      color: RoomColors.gold,
                      size: 10,
                      spacing: 2.0,
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
              left: 0,
              right: 0,
              child: Center(
                child: _CardMeta(label: 'MEMBER NO.', value: member.memberNumber, center: true),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _CardMeta(label: 'TIER', value: _tierLabel(member.tier), alignEnd: true, tier: true),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'R';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class _MembershipCardBack extends StatelessWidget {
  final RoomMemberRecord member;

  const _MembershipCardBack({required this.member});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.75,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0C0B),
          border: const Border(top: BorderSide(color: RoomColors.gold, width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.44),
              blurRadius: 38,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: 'room962:${member.memberNumber}:${member.fullName}:${member.yearJoined}',
                    size: 120,
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
                  const SizedBox(height: 12),
                  _MetaText(
                    member.memberNumber,
                    color: RoomColors.goldMuted,
                    size: 11,
                    spacing: 1.6,
                    center: true,
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _MetaText(
                'ROOM +962 · AMMAN, JORDAN',
                color: RoomColors.gold,
                size: 9,
                center: true,
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
  final bool alignEnd;
  final bool center;
  final bool tier;

  const _CardMeta({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.center = false,
    this.tier = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : alignEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle(color: RoomColors.goldMuted, size: 9, spacing: 1.5),
        ),
        const SizedBox(height: 4),
        tier
            ? Text(
                value,
                style: GoogleFonts.cormorantGaramond(
                  color: RoomColors.offWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                ),
              )
            : label == 'MEMBER SINCE'
                ? Text(
                    value,
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.offWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.dmSans(
                      color: RoomColors.offWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool tier;

  const _DetailRow({
    required this.label,
    required this.value,
    this.tier = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RoomColors.border, width: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _labelStyle(color: RoomColors.goldMuted, size: 11, spacing: 1.4),
            ),
          ),
          tier
              ? Text(
                  value,
                  style: GoogleFonts.cormorantGaramond(
                    color: RoomColors.offWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.dmSans(
                    color: RoomColors.offWhite,
                    fontSize: 15,
                    fontWeight: label == 'MEMBER NO.' ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: label == 'MEMBER NO.' ? 0.4 : 0.1,
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

    return Text(
      label,
      style: _labelStyle(
        color: attending ? RoomColors.gold : RoomColors.muted,
        size: 10,
        spacing: 1.4,
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FilledAction({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.center,
        color: RoomColors.gold,
        child: Text(
          text,
          style: _labelStyle(color: RoomColors.voidBlack, size: 12, spacing: 1.8),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool compact;
  final bool gold;

  const _TextAction({
    required this.text,
    required this.onTap,
    this.compact = false,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: compact ? 30 : 46,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: _labelStyle(color: gold ? RoomColors.gold : RoomColors.muted, size: 11, spacing: 1.8),
          ),
        ),
      ),
    );
  }
}

class _QuietNavText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuietNavText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: _labelStyle(color: RoomColors.goldMuted, size: 10, spacing: 1.5),
      ),
    );
  }
}

class _AnnouncementEntry extends StatelessWidget {
  final String date;
  final String body;

  const _AnnouncementEntry({required this.date, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RoomColors.gold, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaText(date, color: RoomColors.gold, size: 11, spacing: 1.2),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.dmSans(
              color: RoomColors.offWhite,
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w400,
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
  final bool structural;

  const _TopTitle({
    required this.title,
    this.subtitle,
    this.structural = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: structural
              ? _labelStyle(color: RoomColors.gold, size: 28, spacing: 2.4)
              : GoogleFonts.cormorantGaramond(
                  color: RoomColors.gold,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          _MetaText(subtitle!, color: RoomColors.goldMuted, size: 13, italic: true),
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
      style: _labelStyle(
        color: gold ? RoomColors.gold : RoomColors.goldMuted,
        size: 11,
        spacing: 1.8,
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double spacing;
  final bool italic;
  final bool center;

  const _MetaText(
    this.text, {
    required this.color,
    this.size = 13,
    this.spacing = 0.2,
    this.italic = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.dmSans(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w300,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: spacing,
        height: 1.45,
      ),
    );
  }
}

TextStyle _labelStyle({required Color color, required double size, double spacing = 1.8}) {
  return GoogleFonts.dmSans(
    color: color,
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: spacing,
  );
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
