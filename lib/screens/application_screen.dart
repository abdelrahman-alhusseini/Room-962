import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/application_draft.dart';
import '../models/room_data.dart';
import '../theme.dart';
import '../widgets/room_widgets.dart';
import 'entry_gate_screen.dart';

class ApplicationScreen extends StatefulWidget {
  final String verifiedEmail;

  const ApplicationScreen({super.key, required this.verifiedEmail});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final PageController pageController = PageController();
  final ApplicationDraft draft = ApplicationDraft();

  int currentPage = 0;
  bool sending = false;
  bool received = false;
  String? errorText;

  late final Map<String, TextEditingController> controllers;

  static const List<String> nationalities = [
    'Jordanian',
    'Palestinian',
    'Lebanese',
    'Syrian',
    'Iraqi',
    'Egyptian',
    'Saudi',
    'Emirati',
    'Qatari',
    'Kuwaiti',
    'Bahraini',
    'Omani',
    'Yemeni',
    'Turkish',
    'British',
    'American',
    'Canadian',
    'French',
    'German',
    'Italian',
    'Spanish',
    'Other',
  ];

  static const List<_QuestionData> questions = [
    _QuestionData(
      text: 'What do you make of the world at the moment?',
      instruction:
          'Not your industry. The world. Two to three sentences is enough.',
    ),
    _QuestionData(
      text:
          'What are you building, creating, or working towards that did not exist before you began?',
      instruction:
          'This does not need to be a company. It can be a body of work, a way of thinking, a community. Tell us what you are making.',
    ),
    _QuestionData(
      text:
          'What would you bring to a room of exceptional people that no one else in that room could?',
      instruction:
          'Not your credentials. Your particular way of seeing, doing, or being. What is yours alone.',
    ),
    _QuestionData(
      text:
          'Describe a conversation that changed how you think about something.',
      instruction:
          'It can be recent or from years ago. What do you carry with you?',
    ),
    _QuestionData(
      text:
          'What do you want from this community, and what do you intend to give it?',
      instruction:
          'Be honest. We are not looking for the right answer. We are looking for the true one.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    controllers = {
      'fullName': TextEditingController(),
      'preferredName': TextEditingController(),
      'email': TextEditingController(),
      'nationality': TextEditingController(),
      'birthYear': TextEditingController(),
      'city': TextEditingController(),
      'professionalField': TextEditingController(),
      'organisation': TextEditingController(),
      'nominatorName': TextEditingController(),
      for (var i = 0; i < 5; i++) 'answer$i': TextEditingController(),
    };

    controllers['email']!.text = widget.verifiedEmail;
  }

  @override
  void dispose() {
    pageController.dispose();
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    draft.fullName = controllers['fullName']!.text;
    draft.preferredName = controllers['preferredName']!.text;
    draft.email = controllers['email']!.text;
    draft.nationality = controllers['nationality']!.text;
    draft.birthYear = controllers['birthYear']!.text;
    draft.city = controllers['city']!.text;
    draft.professionalField = controllers['professionalField']!.text;
    draft.organisation = controllers['organisation']!.text;
    draft.nominatorName = controllers['nominatorName']!.text;

    for (var i = 0; i < 5; i++) {
      draft.answers[i] = controllers['answer$i']!.text;
    }
  }

  bool _currentStepValid() {
    _syncDraft();

    if (currentPage == 0) return draft.hasParticulars;

    if (currentPage >= 1 && currentPage <= 5) {
      return draft.answers[currentPage - 1].trim().isNotEmpty;
    }

    if (currentPage == 6) return draft.hasAcknowledgement;

    return true;
  }

  Future<void> _next() async {
    setState(() {
      errorText = null;
    });

    if (!_currentStepValid()) {
      setState(() {
        errorText = currentPage == 6
            ? 'Confirm the covenant before submission.'
            : currentPage == 0
                ? 'Complete the required fields. Email must be verified.'
                : 'This section needs to be completed before continuing.';
      });
      return;
    }

    if (currentPage == 6) {
      await _submit();
      return;
    }

    final next = currentPage + 1;

    await pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
    );

    setState(() {
      currentPage = next;
    });
  }

  Future<void> _back() async {
    if (currentPage == 0 || sending) return;

    final previous = currentPage - 1;

    await pageController.animateToPage(
      previous,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
    );

    setState(() {
      currentPage = previous;
      errorText = null;
    });
  }

  void _backToEntry() {
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

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: RoomColors.obsidian,
              headerBackgroundColor: RoomColors.charcoal,
              headerForegroundColor: RoomColors.offWhite,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return RoomColors.voidBlack;
                }
                return RoomColors.offWhite;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return RoomColors.gold;
                }
                return Colors.transparent;
              }),
              todayForegroundColor:
                  const WidgetStatePropertyAll(RoomColors.gold),
              todayBorder: const BorderSide(color: RoomColors.gold),
            ),
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

    if (picked == null) return;

    controllers['birthYear']!.text = _formattedDate(picked);
    setState(() {});
  }

  static String _formattedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _submit() async {
    _syncDraft();

    if (!draft.canSubmit) {
      setState(() {
        errorText = 'The application is not complete.';
      });
      return;
    }

    setState(() {
      sending = true;
      errorText = null;
    });

    RoomRepository.instance.submitApplication(draft);

    await Future<void>.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      sending = false;
      received = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (received) {
      return const _ReceivedScreen();
    }

    return RoomShell(
      child: Column(
        children: [
          _Header(
            currentPage: currentPage,
            total: 7,
            onBack: currentPage == 0 ? _backToEntry : _back,
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ParticularsStep(
                  controllers: controllers,
                  verifiedEmail: widget.verifiedEmail,
                  nationalities: nationalities,
                  onPickBirthDate: _pickBirthDate,
                  onChanged: (_) => setState(() {}),
                ),
                for (var i = 0; i < 5; i++)
                  _QuestionStep(
                    index: i,
                    data: questions[i],
                    controller: controllers['answer$i']!,
                    onChanged: (_) => setState(() {}),
                  ),
                _CovenantStep(
                  acknowledged: draft.acknowledgedCovenant,
                  onChanged: (value) {
                    setState(() => draft.acknowledgedCovenant = value);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: errorText == null ? 0 : 1,
                    child: Text(
                      errorText ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: RoomColors.error,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const GoldRule(width: double.infinity, opacity: 0.40),
                  const SizedBox(height: 18),
                  QuietButton(
                    text: sending
                        ? 'Sending'
                        : currentPage == 6
                            ? 'Submit Application'
                            : 'Continue',
                    larger: currentPage == 6,
                    onPressed: sending ? null : _next,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Review can take up to 5 business days.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RoomColors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int currentPage;
  final int total;
  final VoidCallback? onBack;

  const _Header({
    required this.currentPage,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
      child: Row(
        children: [
          if (onBack != null) ...[
            InkWell(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: RoomColors.goldMuted,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Text(
            'ROOM +962',
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.goldMuted,
              fontSize: 14,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          ProgressDots(total: total, current: currentPage),
        ],
      ),
    );
  }
}

class _ParticularsStep extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final List<String> nationalities;
  final String verifiedEmail;
  final VoidCallback onPickBirthDate;
  final ValueChanged<String> onChanged;

  const _ParticularsStep({
    required this.controllers,
    required this.verifiedEmail,
    required this.nationalities,
    required this.onPickBirthDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      LineTextField(
        label: 'FULL NAME',
        controller: controllers['fullName']!,
        requiredField: true,
        onChanged: onChanged,
      ),
      LineTextField(
        label: 'PREFERRED NAME',
        controller: controllers['preferredName']!,
        onChanged: onChanged,
      ),
      LineTextField(
        label: 'EMAIL',
        controller: controllers['email']!,
        keyboardType: TextInputType.emailAddress,
        requiredField: true,
        readOnly: true,
        onChanged: onChanged,
      ),
      LineDropdownField(
        label: 'NATIONALITY',
        value: controllers['nationality']!.text,
        options: nationalities,
        requiredField: true,
        onChanged: (value) {
          controllers['nationality']!.text = value;
          onChanged(value);
        },
      ),
      LineDateField(
        label: 'DATE OF BIRTH',
        controller: controllers['birthYear']!,
        requiredField: true,
        onTap: onPickBirthDate,
      ),
      LineTextField(
        label: 'CURRENT CITY OF RESIDENCE',
        controller: controllers['city']!,
        requiredField: true,
        onChanged: onChanged,
      ),
      LineTextField(
        label: 'PRIMARY PROFESSIONAL FIELD',
        controller: controllers['professionalField']!,
        requiredField: true,
        onChanged: onChanged,
      ),
      LineTextField(
        label: 'CURRENT POSITION / ORGANISATION',
        hint: 'optional',
        controller: controllers['organisation']!,
        onChanged: onChanged,
      ),
      LineTextField(
        label: "NOMINATING MEMBER'S NAME",
        controller: controllers['nominatorName']!,
        requiredField: true,
        onChanged: onChanged,
      ),
    ];

    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMarker(text: 'I — Particulars'),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth > 620;

              if (!twoColumns) {
                return Column(
                  children: fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 26),
                          child: field,
                        ),
                      )
                      .toList(),
                );
              }

              return Wrap(
                spacing: 28,
                runSpacing: 26,
                children: fields
                    .map(
                      (field) => SizedBox(
                        width: (constraints.maxWidth - 28) / 2,
                        child: field,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  final int index;
  final _QuestionData data;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _QuestionStep({
    required this.index,
    required this.data,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScroll(
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            child: Text(
              _roman(index + 1),
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.gold.withOpacity(0.15),
                fontSize: MediaQuery.of(context).size.width < 700 ? 56 : 84,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.text,
                  style: GoogleFonts.cormorantGaramond(
                    color: RoomColors.offWhite,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    height: 1.75,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.instruction,
                  style: GoogleFonts.inter(
                    color: RoomColors.goldMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 34),
                LineTextField(
                  label: 'RESPONSE',
                  controller: controller,
                  maxLines: 7,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${controller.text.length} / 800',
                    style: TextStyle(
                      color: controller.text.length > 800
                          ? RoomColors.gold
                          : RoomColors.muted,
                      fontSize: 10,
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

  static String _roman(int number) {
    const values = ['I', 'II', 'III', 'IV', 'V'];
    return values[number - 1];
  }
}

class _CovenantStep extends StatelessWidget {
  final bool acknowledged;
  final ValueChanged<bool> onChanged;

  const _CovenantStep({
    required this.acknowledged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMarker(text: 'VI — The Covenant'),
          const SizedBox(height: 34),
          Text(
            'What is discussed within Room +962 remains within Room +962.\n'
            'Discretion is not a rule — it is a value shared by every member.\n\n'
            'Membership is not transferable and carries no automatic right of renewal.\n'
            'It is maintained on the basis of continued contribution to the community.\n\n'
            'Members are expected to attend, engage, and participate — not to spectate.',
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.offWhite,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 2.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 34),
          InkWell(
            onTap: () => onChanged(!acknowledged),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: RoomColors.obsidian,
                border: Border.fromBorderSide(
                  BorderSide(color: RoomColors.border),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: acknowledged
                          ? RoomColors.gold.withOpacity(0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: acknowledged
                            ? RoomColors.gold
                            : RoomColors.border,
                        width: 1,
                      ),
                    ),
                    child: acknowledged
                        ? const Icon(
                            Icons.check,
                            color: RoomColors.goldPale,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'I confirm that I have read and acknowledge the covenant above.',
                      style: GoogleFonts.inter(
                        color: RoomColors.offWhite,
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _formattedDate(DateTime.now()),
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.goldMuted,
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  static String _formattedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StepScroll extends StatelessWidget {
  final Widget child;

  const _StepScroll({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: child,
        ),
      ),
    );
  }
}

class _ReceivedScreen extends StatefulWidget {
  const _ReceivedScreen();

  @override
  State<_ReceivedScreen> createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends State<_ReceivedScreen> {
  bool showFooter = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showFooter = true);
    });
  }

  void _backToEntry() {
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
    return RoomShell(
      center: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoldRule(width: 120, opacity: 0.6),
            const SizedBox(height: 28),
            Text(
              'Your application has been received.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.offWhite,
                fontSize: 28,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A confirmation email has been sent. Review can take up to 5 business days.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: RoomColors.goldMuted,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            const GoldRule(width: 120, opacity: 0.6),
            const SizedBox(height: 28),
            QuietButton(
              text: 'Back to entry',
              onPressed: _backToEntry,
            ),
            const SizedBox(height: 32),
            AnimatedOpacity(
              opacity: showFooter ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: const Text(
                'ROOM +962 · AMMAN, JORDAN',
                style: TextStyle(
                  color: RoomColors.muted,
                  fontSize: 9,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionData {
  final String text;
  final String instruction;

  const _QuestionData({
    required this.text,
    required this.instruction,
  });
}
