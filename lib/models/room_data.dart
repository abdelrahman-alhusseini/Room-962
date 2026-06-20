import 'package:flutter/foundation.dart';

import 'application_draft.dart';

String roomLongDate(DateTime date, {bool includeTime = false}) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
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

  final day = weekdays[date.weekday - 1];
  final month = months[date.month - 1];
  final base = '$day, ${date.day} $month ${date.year}';

  if (!includeTime) return base;

  var hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$base · $hour:$minute $suffix';
}

String roomShortDate(DateTime date) {
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

String _newId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

class RoomApplicantAccount {
  final String id;
  final String email;
  final String password;
  bool emailVerified;
  final DateTime createdAt;

  RoomApplicantAccount({
    required this.id,
    required this.email,
    required this.password,
    this.emailVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class RoomApplicationRecord {
  final String id;
  final String fullName;
  final String preferredName;
  final String email;
  final String nationality;
  final String birthYear;
  final String city;
  final String professionalField;
  final String organisation;
  final String nominatorName;
  final List<String> answers;
  final DateTime submittedAt;
  String status;
  DateTime? reviewedAt;
  String? reviewNote;

  RoomApplicationRecord({
    required this.id,
    required this.fullName,
    required this.preferredName,
    required this.email,
    required this.nationality,
    required this.birthYear,
    required this.city,
    required this.professionalField,
    required this.organisation,
    required this.nominatorName,
    required this.answers,
    required this.submittedAt,
    this.status = 'pending',
    this.reviewedAt,
    this.reviewNote,
  });

  factory RoomApplicationRecord.fromDraft(ApplicationDraft draft) {
    return RoomApplicationRecord(
      id: _newId('application'),
      fullName: draft.fullName.trim(),
      preferredName: draft.preferredName.trim(),
      email: draft.email.trim().toLowerCase(),
      nationality: draft.nationality.trim(),
      birthYear: draft.birthYear.trim(),
      city: draft.city.trim(),
      professionalField: draft.professionalField.trim(),
      organisation: draft.organisation.trim(),
      nominatorName: draft.nominatorName.trim(),
      answers: List<String>.from(draft.answers.map((answer) => answer.trim())),
      submittedAt: DateTime.now(),
    );
  }

  String get displayName => preferredName.isEmpty ? fullName : preferredName;
  bool get isPending => status == 'pending' || status == 'under_review';
}

class RoomMemberRecord {
  final String id;
  final String fullName;
  final String email;
  final String professionalField;
  final String tier;
  final String memberNumber;
  final int yearJoined;
  String status;

  RoomMemberRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.professionalField,
    required this.tier,
    required this.memberNumber,
    required this.yearJoined,
    this.status = 'active',
  });
}

class RoomEventRecord {
  final String id;
  String type;
  String title;
  DateTime eventDate;
  String locationName;
  String description;
  int capacity;
  bool isPublished;
  bool visibleToAllMembers;
  bool showGuestCount;
  bool notifyMembers;
  int attendingCount;
  String? rsvpStatus;
  final DateTime createdAt;

  RoomEventRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.eventDate,
    required this.locationName,
    required this.description,
    required this.capacity,
    this.isPublished = false,
    this.visibleToAllMembers = true,
    this.showGuestCount = true,
    this.notifyMembers = false,
    this.attendingCount = 0,
    this.rsvpStatus,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case 'monthly_dinner':
        return 'MONTHLY DINNER';
      case 'quarterly_experience':
        return 'QUARTERLY EXPERIENCE';
      case 'annual_celebration':
        return 'ANNUAL CELEBRATION';
      case 'spontaneous':
        return 'SPONTANEOUS';
      default:
        return type.toUpperCase();
    }
  }

  String get dateLine => roomLongDate(eventDate, includeTime: true);
  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  int get seatsRemaining => capacity - attendingCount;
  bool get isFull => attendingCount >= capacity;
  String get capacityLine => '$attendingCount / $capacity attending';
}

class RoomAnnouncementRecord {
  final String id;
  String title;
  String body;
  bool isPublished;
  DateTime? publishedAt;
  final DateTime createdAt;

  RoomAnnouncementRecord({
    required this.id,
    required this.title,
    required this.body,
    this.isPublished = false,
    this.publishedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class RoomAdminNotification {
  final String id;
  final String title;
  final String body;
  final String channel;
  final String target;
  final DateTime createdAt;
  bool delivered;
  bool read;

  RoomAdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    required this.target,
    DateTime? createdAt,
    this.delivered = true,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

class RoomRepository extends ChangeNotifier {
  RoomRepository._() {
    _seed();
  }

  static final RoomRepository instance = RoomRepository._();

  static const String adminEmail = 'admin@room962.com';
  static const String adminPassword = 'admin962';
  static const String demoMemberEmail = 'member@room962.com';
  static const String demoMemberPassword = 'member962';
  static const String demoAllEmail = 'demo@room962.com';
  static const String demoAllPassword = 'demo962';

  final List<RoomApplicantAccount> applicantAccounts = <RoomApplicantAccount>[];
  final List<RoomApplicationRecord> applications = <RoomApplicationRecord>[];
  final List<RoomMemberRecord> members = <RoomMemberRecord>[];
  final List<RoomEventRecord> events = <RoomEventRecord>[];
  final List<RoomAnnouncementRecord> announcements = <RoomAnnouncementRecord>[];
  final List<RoomAdminNotification> adminNotifications = <RoomAdminNotification>[];
  final Set<String> revokedMemberEmails = <String>{};

  int get pendingApplications => applications.where((item) => item.isPending).length;
  int get unreadAdminNotifications => adminNotifications.where((item) => !item.read).length;

  bool emailInUse(String email) {
    final normalized = email.trim().toLowerCase();
    return applicantAccounts.any((account) => account.email == normalized) ||
        members.any((member) => member.email == normalized) ||
        normalized == adminEmail ||
        normalized == demoAllEmail ||
        revokedMemberEmails.contains(normalized);
  }

  RoomApplicantAccount createApplicantAccount({
    required String email,
    required String password,
  }) {
    final account = RoomApplicantAccount(
      id: _newId('account'),
      email: email.trim().toLowerCase(),
      password: password,
    );
    applicantAccounts.insert(0, account);
    _addAdminNotification(
      title: 'Verification email sent',
      body: 'Verification link sent to ${account.email}.',
      channel: 'Applicant email',
      target: account.email,
      read: true,
    );
    notifyListeners();
    return account;
  }

  void verifyApplicantAccount(String email) {
    final account = _findApplicantAccount(email);
    if (account == null) return;
    account.emailVerified = true;
    notifyListeners();
  }

  RoomApplicantAccount? authenticateApplicant(String email, String password) {
    final normalized = email.trim().toLowerCase();
    for (final account in applicantAccounts) {
      if (account.email == normalized && account.password == password && account.emailVerified) {
        return account;
      }
    }
    return null;
  }

  RoomApplicationRecord? applicationForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final application in applications) {
      if (application.email == normalized) return application;
    }
    return null;
  }

  bool isMemberEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return members.any((member) => member.email == normalized && member.status == 'active');
  }

  bool isAccessRevoked(String email) {
    return revokedMemberEmails.contains(email.trim().toLowerCase());
  }

  bool isDemoMemberCredential(String email, String password) {
    return email.trim().toLowerCase() == demoMemberEmail &&
        password == demoMemberPassword &&
        isMemberEmail(demoMemberEmail);
  }

  bool isDemoAllCredential(String email, String password) {
    return email.trim().toLowerCase() == demoAllEmail && password == demoAllPassword;
  }

  RoomMemberRecord? activeMemberForEmail(String? email) {
    final normalized = email?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return firstActiveMember;
    }
    for (final member in members) {
      if (member.email == normalized && member.status == 'active') return member;
    }
    return null;
  }

  RoomMemberRecord? get firstActiveMember {
    for (final member in members) {
      if (member.status == 'active') return member;
    }
    return null;
  }

  List<RoomEventRecord> memberEvents({required bool upcoming}) {
    final visibleEvents = events.where(
      (event) => event.isPublished && event.visibleToAllMembers,
    );

    final filtered = visibleEvents.where(
      (event) => upcoming ? event.isUpcoming : !event.isUpcoming,
    );

    final result = filtered.toList()
      ..sort((a, b) => upcoming
          ? a.eventDate.compareTo(b.eventDate)
          : b.eventDate.compareTo(a.eventDate));
    return result;
  }

  RoomEventRecord? get nextMemberGathering {
    final upcoming = memberEvents(upcoming: true);
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<RoomAnnouncementRecord> get publishedAnnouncements {
    final published = announcements.where((item) => item.isPublished).toList()
      ..sort((a, b) {
        final aDate = a.publishedAt ?? a.createdAt;
        final bDate = b.publishedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
    return published;
  }

  void submitApplication(ApplicationDraft draft) {
    final existing = applicationForEmail(draft.email);
    if (existing != null) {
      applications.remove(existing);
    }

    final application = RoomApplicationRecord.fromDraft(draft);
    applications.insert(0, application);

    _addAdminNotification(
      title: 'Application email sent',
      body: 'Thank-you email sent to ${application.email}. Review time: up to 5 business days.',
      channel: 'Applicant email',
      target: application.email,
      read: true,
    );
    _addAdminNotification(
      title: 'New application',
      body: '${application.fullName} applied. Open Applicants to review.',
      channel: 'Admin email + push',
      target: adminEmail,
    );
    notifyListeners();
  }

  void markApplicationUnderReview(String id) {
    final application = _findApplication(id);
    if (application == null) return;
    application.status = 'under_review';
    application.reviewedAt = DateTime.now();
    _addAdminNotification(
      title: 'Under review',
      body: '${application.fullName} moved to review.',
      channel: 'Admin log',
      target: 'Admin',
      read: true,
    );
    notifyListeners();
  }

  void acceptApplication(String id, {String tier = 'full'}) {
    final application = _findApplication(id);
    if (application == null) return;

    revokedMemberEmails.remove(application.email);
    application.status = 'accepted';
    application.reviewedAt = DateTime.now();
    application.reviewNote = 'Accepted. Email sent.';

    final existingMember = _findMemberByEmail(application.email);
    if (existingMember != null) {
      existingMember.status = 'active';
    } else {
      final memberNumber = 'R962 · ${(_nextMemberNumber()).toString().padLeft(4, '0')}';
      members.insert(
        0,
        RoomMemberRecord(
          id: _newId('member'),
          fullName: application.fullName,
          email: application.email,
          professionalField: application.professionalField,
          tier: tier,
          memberNumber: memberNumber,
          yearJoined: DateTime.now().year,
        ),
      );
    }

    _addAdminNotification(
      title: 'Acceptance email sent',
      body: '${application.fullName} can now sign in as a member.',
      channel: 'Applicant email',
      target: application.email,
    );
    notifyListeners();
  }

  void declineApplication(String id) {
    final application = _findApplication(id);
    if (application == null) return;

    application.status = 'declined';
    application.reviewedAt = DateTime.now();
    application.reviewNote = 'Declined. Email sent.';

    _addAdminNotification(
      title: 'Decision email sent',
      body: '${application.fullName} was notified.',
      channel: 'Applicant email',
      target: application.email,
    );
    notifyListeners();
  }

  void removeMember(String memberId) {
    final index = members.indexWhere((member) => member.id == memberId);
    if (index == -1) return;

    final removed = members.removeAt(index);
    revokedMemberEmails.add(removed.email.trim().toLowerCase());

    final application = applicationForEmail(removed.email);
    if (application != null) {
      application.status = 'access_removed';
      application.reviewedAt = DateTime.now();
      application.reviewNote = 'Membership access removed by admin.';
    }

    _addAdminNotification(
      title: 'Member access removed',
      body: '${removed.fullName} can no longer sign in as a member.',
      channel: 'Admin log',
      target: removed.email,
    );
    notifyListeners();
  }

  void createEvent(RoomEventRecord event) {
    events.insert(0, event);
    if (event.isPublished && event.notifyMembers) {
      _addAdminNotification(
        title: 'Gathering published',
        body: '${event.title} is live. Capacity: ${event.capacity}.',
        channel: 'Member push + email',
        target: event.visibleToAllMembers ? 'All active members' : 'Selected members',
      );
    }
    notifyListeners();
  }

  void toggleEventPublished(String eventId) {
    final event = _findEvent(eventId);
    if (event == null) return;

    event.isPublished = !event.isPublished;
    if (event.isPublished && event.notifyMembers) {
      _addAdminNotification(
        title: 'Gathering published',
        body: '${event.title} is live. Capacity: ${event.capacity}.',
        channel: 'Member push + email',
        target: event.visibleToAllMembers ? 'All active members' : 'Selected members',
      );
    }
    notifyListeners();
  }

  void deleteEvent(String eventId) {
    final index = events.indexWhere((event) => event.id == eventId);
    if (index == -1) return;
    final removed = events.removeAt(index);
    _addAdminNotification(
      title: 'Gathering removed',
      body: '${removed.title} was removed from the calendar.',
      channel: 'Admin log',
      target: 'Admin',
      read: true,
    );
    notifyListeners();
  }

  bool updateRsvp(String eventId, String? response) {
    final event = _findEvent(eventId);
    if (event == null) return false;

    final previous = event.rsvpStatus;
    if (response == 'ATTENDING' && previous != 'ATTENDING' && event.isFull) {
      return false;
    }

    if (previous == 'ATTENDING' && response != 'ATTENDING' && event.attendingCount > 0) {
      event.attendingCount = event.attendingCount - 1;
    }

    if (response == 'ATTENDING' && previous != 'ATTENDING') {
      event.attendingCount = event.attendingCount + 1;
    }

    event.rsvpStatus = response;
    notifyListeners();
    return true;
  }

  void createAnnouncement({
    required String title,
    required String body,
    required bool isPublished,
  }) {
    final announcement = RoomAnnouncementRecord(
      id: _newId('announcement'),
      title: title.trim(),
      body: body.trim(),
      isPublished: isPublished,
      publishedAt: isPublished ? DateTime.now() : null,
    );
    announcements.insert(0, announcement);

    if (isPublished) {
      _addAnnouncementNotification(announcement);
    }
    notifyListeners();
  }

  void updateAnnouncement({
    required String id,
    required String title,
    required String body,
    required bool isPublished,
  }) {
    final announcement = _findAnnouncement(id);
    if (announcement == null) return;

    final wasPublished = announcement.isPublished;
    announcement.title = title.trim();
    announcement.body = body.trim();
    announcement.isPublished = isPublished;
    if (isPublished && (!wasPublished || announcement.publishedAt == null)) {
      announcement.publishedAt = DateTime.now();
      _addAnnouncementNotification(announcement);
    }
    notifyListeners();
  }

  void toggleAnnouncementPublished(String id) {
    final announcement = _findAnnouncement(id);
    if (announcement == null) return;
    announcement.isPublished = !announcement.isPublished;
    if (announcement.isPublished) {
      announcement.publishedAt = DateTime.now();
      _addAnnouncementNotification(announcement);
    }
    notifyListeners();
  }

  void deleteAnnouncement(String id) {
    final index = announcements.indexWhere((announcement) => announcement.id == id);
    if (index == -1) return;
    announcements.removeAt(index);
    notifyListeners();
  }

  void markAdminNotificationsRead() {
    for (final notification in adminNotifications) {
      notification.read = true;
    }
    notifyListeners();
  }

  RoomApplicantAccount? _findApplicantAccount(String email) {
    final normalized = email.trim().toLowerCase();
    for (final account in applicantAccounts) {
      if (account.email == normalized) return account;
    }
    return null;
  }

  RoomApplicationRecord? _findApplication(String id) {
    for (final application in applications) {
      if (application.id == id) return application;
    }
    return null;
  }

  RoomMemberRecord? _findMemberByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final member in members) {
      if (member.email == normalized) return member;
    }
    return null;
  }

  RoomEventRecord? _findEvent(String id) {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  RoomAnnouncementRecord? _findAnnouncement(String id) {
    for (final announcement in announcements) {
      if (announcement.id == id) return announcement;
    }
    return null;
  }

  void _addAnnouncementNotification(RoomAnnouncementRecord announcement) {
    final body = announcement.body.trim();
    _addAdminNotification(
      title: 'Announcement published',
      body: body.length > 60 ? '${body.substring(0, 60)}…' : body,
      channel: 'Member push + email',
      target: 'All active members',
    );
  }

  void _addAdminNotification({
    required String title,
    required String body,
    required String channel,
    required String target,
    bool read = false,
  }) {
    adminNotifications.insert(
      0,
      RoomAdminNotification(
        id: _newId('notification'),
        title: title,
        body: body,
        channel: channel,
        target: target,
        read: read,
      ),
    );
  }

  int _nextMemberNumber() => members.length + 1;

  void _seed() {
    members.addAll([
      RoomMemberRecord(
        id: 'member-demo-1',
        fullName: 'Demo Member',
        email: demoMemberEmail,
        professionalField: 'Creative Direction',
        tier: 'founding',
        memberNumber: 'R962 · 0001',
        yearJoined: 2026,
      ),
    ]);

    applicantAccounts.add(
      RoomApplicantAccount(
        id: 'account-demo-1',
        email: 'leen@example.org',
        password: 'applicant962',
        emailVerified: true,
        createdAt: DateTime(2026, 6, 18, 18),
      ),
    );

    applications.addAll([
      RoomApplicationRecord(
        id: 'application-demo-1',
        fullName: 'Leen Haddad',
        preferredName: 'Leen',
        email: 'leen@example.org',
        nationality: 'Jordanian',
        birthYear: '1997',
        city: 'Amman',
        professionalField: 'Architecture',
        organisation: 'Independent studio',
        nominatorName: 'Demo Member',
        answers: const [
          'Amman is moving quickly. I think people need smaller spaces where conversations can slow down.',
          'I am starting a small architecture studio focused on residential projects.',
          'I pay attention to space, detail, and how people feel inside a room.',
          'A site conversation changed how I think about patience in design.',
          'I want to meet serious people and contribute through useful introductions and attendance.',
        ],
        submittedAt: DateTime(2026, 6, 18, 18, 20),
      ),
    ]);

    events.addAll([
      RoomEventRecord(
        id: 'event-demo-1',
        type: 'monthly_dinner',
        title: 'Founders Dinner',
        eventDate: DateTime(2026, 6, 26, 20),
        locationName: 'Amman',
        description: 'Dinner for members at a private table in Amman.',
        capacity: 18,
        isPublished: true,
        visibleToAllMembers: true,
        showGuestCount: true,
        attendingCount: 12,
      ),
      RoomEventRecord(
        id: 'event-demo-2',
        type: 'quarterly_experience',
        title: 'A Private Table',
        eventDate: DateTime(2026, 7, 10, 19, 30),
        locationName: 'Jabal Amman',
        description: 'Small table conversation with one invited guest.',
        capacity: 14,
        isPublished: true,
        visibleToAllMembers: true,
        showGuestCount: true,
        attendingCount: 14,
      ),
      RoomEventRecord(
        id: 'event-demo-3',
        type: 'monthly_dinner',
        title: 'First Room',
        eventDate: DateTime(2026, 5, 22, 20),
        locationName: 'Amman',
        description: 'Opening member gathering.',
        capacity: 12,
        isPublished: true,
        visibleToAllMembers: true,
        showGuestCount: false,
        attendingCount: 12,
        rsvpStatus: 'ATTENDING',
      ),
      RoomEventRecord(
        id: 'event-demo-4',
        type: 'spontaneous',
        title: 'Committee Preview',
        eventDate: DateTime(2026, 7, 2, 19),
        locationName: 'Private location',
        description: 'Draft calendar hold.',
        capacity: 8,
        isPublished: false,
        visibleToAllMembers: false,
        showGuestCount: false,
        attendingCount: 0,
      ),
    ]);

    announcements.addAll([
      RoomAnnouncementRecord(
        id: 'announcement-demo-1',
        title: 'Calendar update',
        body: 'Founders Dinner is now on the calendar.',
        isPublished: true,
        publishedAt: DateTime(2026, 6, 14),
      ),
      RoomAnnouncementRecord(
        id: 'announcement-demo-2',
        title: 'Attendance',
        body: 'Attendance helps shape the room.',
        isPublished: true,
        publishedAt: DateTime(2026, 6, 9),
      ),
    ]);

    adminNotifications.add(
      RoomAdminNotification(
        id: 'notification-demo-1',
        title: 'Admin ready',
        body: 'Use $adminEmail to sign in.',
        channel: 'Admin log',
        target: 'Admin',
        createdAt: DateTime(2026, 6, 14, 9),
        read: true,
      ),
    );
  }
}
