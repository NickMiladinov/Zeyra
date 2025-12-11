/// Gender enum for user profile personalization.
enum Gender {
  /// Female gender
  female,

  /// Male gender
  male,

  /// Non-binary gender
  nonBinary,

  /// Prefer not to disclose
  preferNotToSay;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case Gender.female:
        return 'Female';
      case Gender.male:
        return 'Male';
      case Gender.nonBinary:
        return 'Non-binary';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  /// Parse from string (case-insensitive)
  ///
  /// Throws [FormatException] if the value is invalid.
  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'female':
        return Gender.female;
      case 'male':
        return Gender.male;
      case 'nonbinary':
      case 'non-binary':
      case 'non_binary':
        return Gender.nonBinary;
      case 'prefernottosay':
      case 'prefer_not_to_say':
      case 'preferNotToSay':
        return Gender.preferNotToSay;
      default:
        throw FormatException('Invalid gender value: $value');
    }
  }
}
