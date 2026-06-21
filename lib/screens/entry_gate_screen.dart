import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/room_data.dart';
import '../theme.dart';
import '../widgets/room_widgets.dart';
import 'admin_shell_screen.dart';
import 'application_screen.dart';
import 'member_shell_screen.dart';

enum _EntryMode { landing, createAccount, verifyEmail, signIn }

class EntryGateScreen extends StatefulWidget {
  const EntryGateScreen({super.key});

  @override
  State<EntryGateScreen> createState() => _EntryGateScreenState();
}

class _EntryGateScreenState extends State<EntryGateScreen> {
  final TextEditingController signInEmailController = TextEditingController();
  final TextEditingController signInPasswordController = TextEditingController();
  final TextEditingController accountEmailController = TextEditingController();
  final TextEditingController accountPasswordController = TextEditingController();
  final TextEditingController accountConfirmController = TextEditingController();
  final TextEditingController verificationController = TextEditingController();

  _EntryMode mode = _EntryMode.landing;
  bool checking = false;
  bool hidePassword = true;
  String? message;
  String? pendingEmail;


  @override
  void dispose() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    accountEmailController.dispose();
    accountPasswordController.dispose();
    accountConfirmController.dispose();
    verificationController.dispose();
    super.dispose();
  }

  bool _isRealEmailFormat(String email) {
    final normalized = email.trim().toLowerCase();
    final pattern = RegExp(
      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
      caseSensitive: false,
    );

    if (!pattern.hasMatch(normalized)) return false;
    if (normalized.endsWith('.local') || normalized.endsWith('@example.com')) {
      return false;
    }

    const blockedDomains = {
      'mailinator.com',
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'yopmail.com',
    };
    final domain = normalized.split('@').last;
    return !blockedDomains.contains(domain);
  }

  Future<void> _createApplicantAccount() async {
    if (checking) return;

    final email = accountEmailController.text.trim().toLowerCase();
    final password = accountPasswordController.text;
    final confirm = accountConfirmController.text;

    setState(() {
      checking = true;
      message = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    if (!_isRealEmailFormat(email)) {
      setState(() {
        checking = false;
        message = 'Use a valid personal or business email.';
      });
      return;
    }

    if (RoomRepository.instance.emailInUse(email)) {
      setState(() {
        checking = false;
        message = 'This email is already registered.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        checking = false;
        message = 'Password must be at least 8 characters.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        checking = false;
        message = 'Passwords do not match.';
      });
      return;
    }

    RoomRepository.instance.createApplicantAccount(email: email, password: password);

    setState(() {
      pendingEmail = email;
      checking = false;
      message = null;
      mode = _EntryMode.verifyEmail;
    });
  }

  void _verifyEmail() {
    final email = pendingEmail;
    if (email == null) return;

    // In production Supabase verifies the email through a secure email link.
    // This local build simulates the verified callback so the flow can be tested.
    RoomRepository.instance.verifyApplicantAccount(email);
    _openApplication(email);
  }

  Future<void> _signIn() async {
    if (checking) return;

    final email = signInEmailController.text.trim().toLowerCase();
    final password = signInPasswordController.text;

    setState(() {
      checking = true;
      message = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    final repo = RoomRepository.instance;

    if (repo.isDemoAllCredential(email, password)) {
      _replaceWith(const DemoPerspectiveScreen());
      return;
    }

    if (email == RoomRepository.adminEmail && password == RoomRepository.adminPassword) {
      _replaceWith(const AdminShellScreen());
      return;
    }

    if (repo.isAccessRevoked(email)) {
      setState(() {
        checking = false;
        message = 'This membership access is no longer active.';
      });
      return;
    }

    if (repo.isDemoMemberCredential(email, password)) {
      _replaceWith(MemberShellScreen(memberEmail: email));
      return;
    }

    final account = RoomRepository.instance.authenticateApplicant(email, password);
    if (account == null) {
      setState(() {
        checking = false;
        message = 'Email or password is incorrect, or the email is not verified.';
      });
      return;
    }

    final application = RoomRepository.instance.applicationForEmail(account.email);
    if (application == null) {
      _openApplication(account.email, replace: true);
      return;
    }

    if (application.status == 'accepted' && repo.isMemberEmail(account.email)) {
      _replaceWith(MemberShellScreen(memberEmail: account.email));
      return;
    }

    _replaceWith(ApplicantStatusScreen(email: account.email));
  }

  void _openApplication(String email, {bool replace = false}) {
    final route = PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (_, animation, __) {
        return FadeTransition(
          opacity: animation,
          child: ApplicationScreen(verifiedEmail: email),
        );
      },
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  void _replaceWith(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, animation, __) {
          return FadeTransition(opacity: animation, child: screen);
        },
      ),
    );
  }

  void _backToLanding() {
    setState(() {
      mode = _EntryMode.landing;
      checking = false;
      message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 460;

    return RoomShell(
      center: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: compact ? 26 : 36),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: switch (mode) {
              _EntryMode.landing => _LandingPanel(
                  key: const ValueKey('landing'),
                  onApply: () {
                    setState(() {
                      mode = _EntryMode.createAccount;
                      message = null;
                    });
                  },
                  onSignIn: () {
                    setState(() {
                      mode = _EntryMode.signIn;
                      message = null;
                    });
                  },
                ),
              _EntryMode.createAccount => _CreateAccountPanel(
                  key: const ValueKey('create'),
                  emailController: accountEmailController,
                  passwordController: accountPasswordController,
                  confirmController: accountConfirmController,
                  hidePassword: hidePassword,
                  checking: checking,
                  message: message,
                  onTogglePassword: () => setState(() => hidePassword = !hidePassword),
                  onSubmit: _createApplicantAccount,
                  onBack: _backToLanding,
                ),
              _EntryMode.verifyEmail => _VerifyEmailPanel(
                  key: const ValueKey('verify'),
                  email: pendingEmail ?? '',
                  codeController: verificationController,
                  checking: checking,
                  message: message,
                  onSubmit: _verifyEmail,
                  onBack: _backToLanding,
                ),
              _EntryMode.signIn => _SignInPanel(
                  key: const ValueKey('signin'),
                  emailController: signInEmailController,
                  passwordController: signInPasswordController,
                  hidePassword: hidePassword,
                  checking: checking,
                  message: message,
                  onTogglePassword: () => setState(() => hidePassword = !hidePassword),
                  onSubmit: _signIn,
                  onBack: _backToLanding,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _LandingPanel extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onSignIn;

  const _LandingPanel({
    super.key,
    required this.onApply,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ROOM +962',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: MediaQuery.of(context).size.width < 480 ? 52 : 68,
              ),
        ),
        const SizedBox(height: 24),
        const GoldRule(width: 88, opacity: 0.65),
        const SizedBox(height: 32),
        Text(
          'PRIVATE MEMBERS COMMUNITY',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 42),
        _PrimaryLineButton(text: 'Create Account', onPressed: onApply),
        const SizedBox(height: 18),
        QuietButton(text: 'Sign In', onPressed: onSignIn),
        const SizedBox(height: 38),
        Text(
          'Create an account. The questionnaire opens after email verification.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.muted,
            fontSize: 11,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _CreateAccountPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool hidePassword;
  final bool checking;
  final String? message;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _CreateAccountPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.hidePassword,
    required this.checking,
    required this.message,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthPanelFrame(
      title: 'Create account',
      back: onBack,
      children: [
        _AuthTextField(
          label: 'EMAIL',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 24),
        _AuthTextField(
          label: 'PASSWORD',
          controller: passwordController,
          obscureText: hidePassword,
          suffixIcon: _PasswordIcon(
            hidden: hidePassword,
            onTap: onTogglePassword,
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 24),
        _AuthTextField(
          label: 'CONFIRM PASSWORD',
          controller: confirmController,
          obscureText: hidePassword,
          onSubmitted: (_) => onSubmit(),
        ),
        _MessageLine(message: message),
        const SizedBox(height: 26),
        _PrimaryLineButton(
          text: checking ? 'Creating' : 'Create account',
          onPressed: checking ? null : onSubmit,
        ),
        const SizedBox(height: 14),
        Text(
          'Only verified email addresses can continue.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.muted,
            fontSize: 10,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _VerifyEmailPanel extends StatelessWidget {
  final String email;
  final TextEditingController codeController;
  final bool checking;
  final String? message;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _VerifyEmailPanel({
    super.key,
    required this.email,
    required this.codeController,
    required this.checking,
    required this.message,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthPanelFrame(
      title: 'Check your email',
      back: onBack,
      children: [
        Text(
          'We sent a verification link to $email',
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.goldMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Open the link from your inbox to verify the email address. The questionnaire is available only after verification.',
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.muted,
            fontSize: 11,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'After verification, return here to continue.',
          style: GoogleFonts.cormorantGaramond(
            color: RoomColors.muted,
            fontSize: 10,
          ),
        ),
        _MessageLine(message: message),
        const SizedBox(height: 26),
        _PrimaryLineButton(
          text: checking ? 'Checking' : 'I verified my email',
          onPressed: checking ? null : onSubmit,
        ),
      ],
    );
  }
}

class _SignInPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final bool checking;
  final String? message;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _SignInPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.checking,
    required this.message,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthPanelFrame(
      title: 'Sign in',
      back: onBack,
      children: [
        _AuthTextField(
          label: 'EMAIL',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 24),
        _AuthTextField(
          label: 'PASSWORD',
          controller: passwordController,
          obscureText: hidePassword,
          suffixIcon: _PasswordIcon(hidden: hidePassword, onTap: onTogglePassword),
          onSubmitted: (_) => onSubmit(),
        ),
        _MessageLine(message: message),
        const SizedBox(height: 26),
        _PrimaryLineButton(
          text: checking ? 'Signing in' : 'Sign in',
          onPressed: checking ? null : onSubmit,
        ),
      ],
    );
  }
}

class _AuthPanelFrame extends StatelessWidget {
  final String title;
  final VoidCallback back;
  final List<Widget> children;

  const _AuthPanelFrame({
    required this.title,
    required this.back,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: back,
          child: Text(
            'BACK',
            style: GoogleFonts.cormorantGaramond(
              color: RoomColors.goldMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: RoomColors.gold,
              ),
        ),
        const SizedBox(height: 34),
        ...children,
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const _AuthTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: RoomColors.gold,
      style: GoogleFonts.cormorantGaramond(
        color: RoomColors.offWhite,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
      onSubmitted: onSubmitted,
    );
  }
}

class _PasswordIcon extends StatelessWidget {
  final bool hidden;
  final VoidCallback onTap;

  const _PasswordIcon({required this.hidden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: RoomColors.goldMuted,
        size: 18,
      ),
    );
  }
}

class _MessageLine extends StatelessWidget {
  final String? message;

  const _MessageLine({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: message == null ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Text(
          message ?? '',
          style: const TextStyle(
            color: RoomColors.error,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _PrimaryLineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryLineButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: enabled ? RoomColors.gold : RoomColors.border,
            width: 1,
          ),
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: enabled ? RoomColors.gold : RoomColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.8,
          ),
        ),
      ),
    );
  }
}

class ApplicantStatusScreen extends StatelessWidget {
  final String email;

  const ApplicantStatusScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final application = RoomRepository.instance.applicationForEmail(email);
        final status = application?.status ?? 'pending';
        final title = status == 'declined'
            ? 'Application reviewed.'
            : status == 'accepted'
                ? 'Welcome.'
                : status == 'access_removed'
                    ? 'Membership access removed.'
                    : 'Application received.';
        final body = status == 'declined'
            ? 'A decision email has been sent.'
            : status == 'accepted'
                ? 'Your membership is active. Sign in again to continue.'
                : status == 'access_removed'
                    ? 'This email no longer has member access.'
                    : 'Review can take up to 5 business days.';

        return RoomShell(
          center: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GoldRule(width: 120, opacity: 0.6),
                  const SizedBox(height: 28),
                  Text(
                    title,
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
                    body,
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
                  const SizedBox(height: 32),
                  QuietButton(
                    text: 'Back to sign in',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 520),
                          pageBuilder: (_, animation, __) => FadeTransition(
                            opacity: animation,
                            child: const EntryGateScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DemoPerspectiveScreen extends StatelessWidget {
  const DemoPerspectiveScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: screen,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoomRepository.instance,
      builder: (context, _) {
        final repo = RoomRepository.instance;
        return RoomShell(
          center: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      'BACK',
                      style: GoogleFonts.cormorantGaramond(
                        color: RoomColors.goldMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Demo view',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: RoomColors.gold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Preview each side of the app. Anything changed in admin is kept live in this demo session.',
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.goldMuted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: RoomColors.obsidian,
                      border: Border.fromBorderSide(BorderSide(color: RoomColors.border)),
                    ),
                    child: Text(
                      'Applicants: ${repo.applications.length} · Members: ${repo.members.length} · Published gatherings: ${repo.memberEvents(upcoming: true).length} · Announcements: ${repo.publishedAnnouncements.length}',
                      style: const TextStyle(
                        color: RoomColors.goldMuted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _PrimaryLineButton(
                    text: 'View as Applicant',
                    onPressed: () {
                      _open(
                        context,
                        const ApplicantStatusScreen(email: 'leen@example.org'),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _PrimaryLineButton(
                    text: 'View as Member',
                    onPressed: () {
                      _open(
                        context,
                        const MemberShellScreen(memberEmail: RoomRepository.demoMemberEmail),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _PrimaryLineButton(
                    text: 'View as Admin',
                    onPressed: () {
                      _open(context, const AdminShellScreen());
                    },
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Demo access is for testing only.',
                    style: GoogleFonts.cormorantGaramond(
                      color: RoomColors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

