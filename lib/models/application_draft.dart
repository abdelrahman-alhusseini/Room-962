class ApplicationDraft {
  String fullName = '';
  String preferredName = '';
  String email = '';
  String nationality = '';
  String birthYear = '';
  String city = '';
  String professionalField = '';
  String organisation = '';
  String nominatorName = '';

  final List<String> answers = List.filled(5, '');

  bool acknowledgedCovenant = false;

  static final RegExp _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  bool get hasValidEmail {
    final value = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(value)) return false;
    if (value.endsWith('.local') || value.endsWith('@example.com')) {
      return false;
    }
    return true;
  }

  bool get hasParticulars {
    return fullName.trim().isNotEmpty &&
        hasValidEmail &&
        nationality.trim().isNotEmpty &&
        birthYear.trim().isNotEmpty &&
        city.trim().isNotEmpty &&
        professionalField.trim().isNotEmpty &&
        nominatorName.trim().isNotEmpty;
  }

  bool get hasAnswers {
    return answers.every((answer) => answer.trim().isNotEmpty);
  }

  bool get hasAcknowledgement {
    return acknowledgedCovenant;
  }

  bool get canSubmit {
    return hasParticulars && hasAnswers && hasAcknowledgement;
  }
}
