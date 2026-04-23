// ignore_for_file: constant_identifier_names

enum HaroldEndpoint { EVALUATE, ELIGIBILITY_CHECK }

enum HaroldUserType { creator, accused, unsure, unknown }

extension HaroldUserTypeParsing on HaroldUserType {
  static HaroldUserType fromApi(String? raw) {
    final normalized = (raw ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'creator':
        return HaroldUserType.creator;
      case 'accused':
        return HaroldUserType.accused;
      case 'unsure':
      case 'unknown':
        return HaroldUserType.unsure;
      default:
        return HaroldUserType.unknown;
    }
  }
}
