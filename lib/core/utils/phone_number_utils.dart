import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberUtils {
  static const Map<String, String> _countryDialCodes = {
    'AD': '+376', // Andorra
    'AE': '+971', // United Arab Emirates
    'AF': '+93', // Afghanistan
    'AG': '+1', // Antigua and Barbuda
    'AI': '+1', // Anguilla
    'AL': '+355', // Albania
    'AM': '+374', // Armenia
    'AO': '+244', // Angola
    'AQ': '+672', // Antarctica
    'AR': '+54', // Argentina
    'AS': '+1', // American Samoa
    'AT': '+43', // Austria
    'AU': '+61', // Australia
    'AW': '+297', // Aruba
    'AX': '+358', // Åland Islands
    'AZ': '+994', // Azerbaijan
    'BA': '+387', // Bosnia and Herzegovina
    'BB': '+1', // Barbados
    'BD': '+880', // Bangladesh
    'BE': '+32', // Belgium
    'BF': '+226', // Burkina Faso
    'BG': '+359', // Bulgaria
    'BH': '+973', // Bahrain
    'BI': '+257', // Burundi
    'BJ': '+229', // Benin
    'BL': '+590', // Saint Barthélemy
    'BM': '+1', // Bermuda
    'BN': '+673', // Brunei
    'BO': '+591', // Bolivia
    'BQ': '+599', // Caribbean Netherlands
    'BR': '+55', // Brazil
    'BS': '+1', // Bahamas
    'BT': '+975', // Bhutan
    'BV': '+47', // Bouvet Island
    'BW': '+267', // Botswana
    'BY': '+375', // Belarus
    'BZ': '+501', // Belize
    'CA': '+1', // Canada
    'CC': '+61', // Cocos Islands
    'CD': '+243', // Democratic Republic of the Congo
    'CF': '+236', // Central African Republic
    'CG': '+242', // Republic of the Congo
    'CH': '+41', // Switzerland
    'CI': '+225', // Côte d'Ivoire
    'CK': '+682', // Cook Islands
    'CL': '+56', // Chile
    'CM': '+237', // Cameroon
    'CN': '+86', // China
    'CO': '+57', // Colombia
    'CR': '+506', // Costa Rica
    'CU': '+53', // Cuba
    'CV': '+238', // Cape Verde
    'CW': '+599', // Curaçao
    'CX': '+61', // Christmas Island
    'CY': '+357', // Cyprus
    'CZ': '+420', // Czech Republic
    'DE': '+49', // Germany
    'DJ': '+253', // Djibouti
    'DK': '+45', // Denmark
    'DM': '+1', // Dominica
    'DO': '+1', // Dominican Republic
    'DZ': '+213', // Algeria
    'EC': '+593', // Ecuador
    'EE': '+372', // Estonia
    'EG': '+20', // Egypt
    'EH': '+212', // Western Sahara
    'ER': '+291', // Eritrea
    'ES': '+34', // Spain
    'ET': '+251', // Ethiopia
    'FI': '+358', // Finland
    'FJ': '+679', // Fiji
    'FK': '+500', // Falkland Islands
    'FM': '+691', // Micronesia
    'FO': '+298', // Faroe Islands
    'FR': '+33', // France
    'GA': '+241', // Gabon
    'GB': '+44', // United Kingdom
    'GD': '+1', // Grenada
    'GE': '+995', // Georgia
    'GF': '+594', // French Guiana
    'GG': '+44', // Guernsey
    'GH': '+233', // Ghana
    'GI': '+350', // Gibraltar
    'GL': '+299', // Greenland
    'GM': '+220', // Gambia
    'GN': '+224', // Guinea
    'GP': '+590', // Guadeloupe
    'GQ': '+240', // Equatorial Guinea
    'GR': '+30', // Greece
    'GS': '+500', // South Georgia and the South Sandwich Islands
    'GT': '+502', // Guatemala
    'GU': '+1', // Guam
    'GW': '+245', // Guinea-Bissau
    'GY': '+592', // Guyana
    'HK': '+852', // Hong Kong
    'HM': '+672', // Heard Island and McDonald Islands
    'HN': '+504', // Honduras
    'HR': '+385', // Croatia
    'HT': '+509', // Haiti
    'HU': '+36', // Hungary
    'ID': '+62', // Indonesia
    'IE': '+353', // Ireland
    'IL': '+972', // Israel
    'IM': '+44', // Isle of Man
    'IN': '+91', // India
    'IO': '+246', // British Indian Ocean Territory
    'IQ': '+964', // Iraq
    'IR': '+98', // Iran
    'IS': '+354', // Iceland
    'IT': '+39', // Italy
    'JE': '+44', // Jersey
    'JM': '+1', // Jamaica
    'JO': '+962', // Jordan
    'JP': '+81', // Japan
    'KE': '+254', // Kenya
    'KG': '+996', // Kyrgyzstan
    'KH': '+855', // Cambodia
    'KI': '+686', // Kiribati
    'KM': '+269', // Comoros
    'KN': '+1', // Saint Kitts and Nevis
    'KP': '+850', // North Korea
    'KR': '+82', // South Korea
    'KW': '+965', // Kuwait
    'KY': '+1', // Cayman Islands
    'KZ': '+7', // Kazakhstan
    'LA': '+856', // Laos
    'LB': '+961', // Lebanon
    'LC': '+1', // Saint Lucia
    'LI': '+423', // Liechtenstein
    'LK': '+94', // Sri Lanka
    'LR': '+231', // Liberia
    'LS': '+266', // Lesotho
    'LT': '+370', // Lithuania
    'LU': '+352', // Luxembourg
    'LV': '+371', // Latvia
    'LY': '+218', // Libya
    'MA': '+212', // Morocco
    'MC': '+377', // Monaco
    'MD': '+373', // Moldova
    'ME': '+382', // Montenegro
    'MF': '+590', // Saint Martin
    'MG': '+261', // Madagascar
    'MH': '+692', // Marshall Islands
    'MK': '+389', // North Macedonia
    'ML': '+223', // Mali
    'MM': '+95', // Myanmar
    'MN': '+976', // Mongolia
    'MO': '+853', // Macao
    'MP': '+1', // Northern Mariana Islands
    'MQ': '+596', // Martinique
    'MR': '+222', // Mauritania
    'MS': '+1', // Montserrat
    'MT': '+356', // Malta
    'MU': '+230', // Mauritius
    'MV': '+960', // Maldives
    'MW': '+265', // Malawi
    'MX': '+52', // Mexico
    'MY': '+60', // Malaysia
    'MZ': '+258', // Mozambique
    'NA': '+264', // Namibia
    'NC': '+687', // New Caledonia
    'NE': '+227', // Niger
    'NF': '+672', // Norfolk Island
    'NG': '+234', // Nigeria
    'NI': '+505', // Nicaragua
    'NL': '+31', // Netherlands
    'NO': '+47', // Norway
    'NP': '+977', // Nepal
    'NR': '+674', // Nauru
    'NU': '+683', // Niue
    'NZ': '+64', // New Zealand
    'OM': '+968', // Oman
    'PA': '+507', // Panama
    'PE': '+51', // Peru
    'PF': '+689', // French Polynesia
    'PG': '+675', // Papua New Guinea
    'PH': '+63', // Philippines
    'PK': '+92', // Pakistan
    'PL': '+48', // Poland
    'PM': '+508', // Saint Pierre and Miquelon
    'PN': '+64', // Pitcairn Islands
    'PR': '+1', // Puerto Rico
    'PS': '+970', // Palestine
    'PT': '+351', // Portugal
    'PW': '+680', // Palau
    'PY': '+595', // Paraguay
    'QA': '+974', // Qatar
    'RE': '+262', // Réunion
    'RO': '+40', // Romania
    'RS': '+381', // Serbia
    'RU': '+7', // Russia
    'RW': '+250', // Rwanda
    'SA': '+966', // Saudi Arabia
    'SB': '+677', // Solomon Islands
    'SC': '+248', // Seychelles
    'SD': '+249', // Sudan
    'SE': '+46', // Sweden
    'SG': '+65', // Singapore
    'SH': '+290', // Saint Helena
    'SI': '+386', // Slovenia
    'SJ': '+47', // Svalbard and Jan Mayen
    'SK': '+421', // Slovakia
    'SL': '+232', // Sierra Leone
    'SM': '+378', // San Marino
    'SN': '+221', // Senegal
    'SO': '+252', // Somalia
    'SR': '+597', // Suriname
    'SS': '+211', // South Sudan
    'ST': '+239', // São Tomé and Príncipe
    'SV': '+503', // El Salvador
    'SX': '+1', // Sint Maarten
    'SY': '+963', // Syria
    'SZ': '+268', // Eswatini
    'TC': '+1', // Turks and Caicos Islands
    'TD': '+235', // Chad
    'TF': '+262', // French Southern Territories
    'TG': '+228', // Togo
    'TH': '+66', // Thailand
    'TJ': '+992', // Tajikistan
    'TK': '+690', // Tokelau
    'TL': '+670', // Timor-Leste
    'TM': '+993', // Turkmenistan
    'TN': '+216', // Tunisia
    'TO': '+676', // Tonga
    'TR': '+90', // Turkey
    'TT': '+1', // Trinidad and Tobago
    'TV': '+688', // Tuvalu
    'TW': '+886', // Taiwan
    'TZ': '+255', // Tanzania
    'UA': '+380', // Ukraine
    'UG': '+256', // Uganda
    'UM': '+1', // United States Minor Outlying Islands
    'US': '+1', // United States
    'UY': '+598', // Uruguay
    'UZ': '+998', // Uzbekistan
    'VA': '+39', // Vatican City
    'VC': '+1', // Saint Vincent and the Grenadines
    'VE': '+58', // Venezuela
    'VG': '+1', // British Virgin Islands
    'VI': '+1', // U.S. Virgin Islands
    'VN': '+84', // Vietnam
    'VU': '+678', // Vanuatu
    'WF': '+681', // Wallis and Futuna
    'WS': '+685', // Samoa
    'YE': '+967', // Yemen
    'YT': '+262', // Mayotte
    'ZA': '+27', // South Africa
    'ZM': '+260', // Zambia
    'ZW': '+263', // Zimbabwe
  };

  static const Map<String, String> _dialCodeToCountry = {
    '+1': 'US', // Default to US for +1 (also covers CA, etc.)
    '+7': 'RU', // Default to Russia for +7 (also covers KZ)
    '+20': 'EG', // Egypt
    '+27': 'ZA', // South Africa
    '+30': 'GR', // Greece
    '+31': 'NL', // Netherlands
    '+32': 'BE', // Belgium
    '+33': 'FR', // France
    '+34': 'ES', // Spain
    '+36': 'HU', // Hungary
    '+39': 'IT', // Italy
    '+40': 'RO', // Romania
    '+41': 'CH', // Switzerland
    '+43': 'AT', // Austria
    '+44': 'GB', // United Kingdom
    '+45': 'DK', // Denmark
    '+46': 'SE', // Sweden
    '+47': 'NO', // Norway
    '+48': 'PL', // Poland
    '+49': 'DE', // Germany
    '+51': 'PE', // Peru
    '+52': 'MX', // Mexico
    '+53': 'CU', // Cuba
    '+54': 'AR', // Argentina
    '+55': 'BR', // Brazil
    '+56': 'CL', // Chile
    '+57': 'CO', // Colombia
    '+58': 'VE', // Venezuela
    '+60': 'MY', // Malaysia
    '+61': 'AU', // Australia
    '+62': 'ID', // Indonesia
    '+63': 'PH', // Philippines
    '+64': 'NZ', // New Zealand
    '+65': 'SG', // Singapore
    '+66': 'TH', // Thailand
    '+81': 'JP', // Japan
    '+82': 'KR', // South Korea
    '+84': 'VN', // Vietnam
    '+86': 'CN', // China
    '+90': 'TR', // Turkey
    '+91': 'IN', // India
    '+92': 'PK', // Pakistan
    '+93': 'AF', // Afghanistan
    '+94': 'LK', // Sri Lanka
    '+95': 'MM', // Myanmar
    '+98': 'IR', // Iran
    '+212': 'MA', // Morocco
    '+213': 'DZ', // Algeria
    '+216': 'TN', // Tunisia
    '+218': 'LY', // Libya
    '+220': 'GM', // Gambia
    '+221': 'SN', // Senegal
    '+222': 'MR', // Mauritania
    '+223': 'ML', // Mali
    '+224': 'GN', // Guinea
    '+225': 'CI', // Côte d'Ivoire
    '+226': 'BF', // Burkina Faso
    '+227': 'NE', // Niger
    '+228': 'TG', // Togo
    '+229': 'BJ', // Benin
    '+230': 'MU', // Mauritius
    '+231': 'LR', // Liberia
    '+232': 'SL', // Sierra Leone
    '+233': 'GH', // Ghana
    '+234': 'NG', // Nigeria
    '+235': 'TD', // Chad
    '+236': 'CF', // Central African Republic
    '+237': 'CM', // Cameroon
    '+238': 'CV', // Cape Verde
    '+239': 'ST', // São Tomé and Príncipe
    '+240': 'GQ', // Equatorial Guinea
    '+241': 'GA', // Gabon
    '+242': 'CG', // Republic of the Congo
    '+243': 'CD', // Democratic Republic of the Congo
    '+244': 'AO', // Angola
    '+245': 'GW', // Guinea-Bissau
    '+246': 'IO', // British Indian Ocean Territory
    '+248': 'SC', // Seychelles
    '+249': 'SD', // Sudan
    '+250': 'RW', // Rwanda
    '+251': 'ET', // Ethiopia
    '+252': 'SO', // Somalia
    '+253': 'DJ', // Djibouti
    '+254': 'KE', // Kenya
    '+255': 'TZ', // Tanzania
    '+256': 'UG', // Uganda
    '+257': 'BI', // Burundi
    '+258': 'MZ', // Mozambique
    '+260': 'ZM', // Zambia
    '+261': 'MG', // Madagascar
    '+262': 'RE', // Réunion
    '+263': 'ZW', // Zimbabwe
    '+264': 'NA', // Namibia
    '+265': 'MW', // Malawi
    '+266': 'LS', // Lesotho
    '+267': 'BW', // Botswana
    '+268': 'SZ', // Eswatini
    '+269': 'KM', // Comoros
    '+290': 'SH', // Saint Helena
    '+291': 'ER', // Eritrea
    '+297': 'AW', // Aruba
    '+298': 'FO', // Faroe Islands
    '+299': 'GL', // Greenland
    '+350': 'GI', // Gibraltar
    '+351': 'PT', // Portugal
    '+352': 'LU', // Luxembourg
    '+353': 'IE', // Ireland
    '+354': 'IS', // Iceland
    '+355': 'AL', // Albania
    '+356': 'MT', // Malta
    '+357': 'CY', // Cyprus
    '+358': 'FI', // Finland
    '+359': 'BG', // Bulgaria
    '+370': 'LT', // Lithuania
    '+371': 'LV', // Latvia
    '+372': 'EE', // Estonia
    '+373': 'MD', // Moldova
    '+374': 'AM', // Armenia
    '+375': 'BY', // Belarus
    '+376': 'AD', // Andorra
    '+377': 'MC', // Monaco
    '+378': 'SM', // San Marino
    '+380': 'UA', // Ukraine
    '+381': 'RS', // Serbia
    '+382': 'ME', // Montenegro
    '+383': 'XK', // Kosovo
    '+385': 'HR', // Croatia
    '+386': 'SI', // Slovenia
    '+387': 'BA', // Bosnia and Herzegovina
    '+389': 'MK', // North Macedonia
    '+420': 'CZ', // Czech Republic
    '+421': 'SK', // Slovakia
    '+423': 'LI', // Liechtenstein
    '+500': 'FK', // Falkland Islands
    '+501': 'BZ', // Belize
    '+502': 'GT', // Guatemala
    '+503': 'SV', // El Salvador
    '+504': 'HN', // Honduras
    '+505': 'NI', // Nicaragua
    '+506': 'CR', // Costa Rica
    '+507': 'PA', // Panama
    '+508': 'PM', // Saint Pierre and Miquelon
    '+509': 'HT', // Haiti
    '+590': 'GP', // Guadeloupe
    '+591': 'BO', // Bolivia
    '+592': 'GY', // Guyana
    '+593': 'EC', // Ecuador
    '+594': 'GF', // French Guiana
    '+595': 'PY', // Paraguay
    '+596': 'MQ', // Martinique
    '+597': 'SR', // Suriname
    '+598': 'UY', // Uruguay
    '+599': 'CW', // Curaçao
    '+670': 'TL', // Timor-Leste
    '+672': 'NF', // Norfolk Island
    '+673': 'BN', // Brunei
    '+674': 'NR', // Nauru
    '+675': 'PG', // Papua New Guinea
    '+676': 'TO', // Tonga
    '+677': 'SB', // Solomon Islands
    '+678': 'VU', // Vanuatu
    '+679': 'FJ', // Fiji
    '+680': 'PW', // Palau
    '+681': 'WF', // Wallis and Futuna
    '+682': 'CK', // Cook Islands
    '+683': 'NU', // Niue
    '+684': 'AS', // American Samoa
    '+685': 'WS', // Samoa
    '+686': 'KI', // Kiribati
    '+687': 'NC', // New Caledonia
    '+688': 'TV', // Tuvalu
    '+689': 'PF', // French Polynesia
    '+690': 'TK', // Tokelau
    '+691': 'FM', // Micronesia
    '+692': 'MH', // Marshall Islands
    '+850': 'KP', // North Korea
    '+852': 'HK', // Hong Kong
    '+853': 'MO', // Macao
    '+855': 'KH', // Cambodia
    '+856': 'LA', // Laos
    '+880': 'BD', // Bangladesh
    '+886': 'TW', // Taiwan
    '+960': 'MV', // Maldives
    '+961': 'LB', // Lebanon
    '+962': 'JO', // Jordan
    '+963': 'SY', // Syria
    '+964': 'IQ', // Iraq
    '+965': 'KW', // Kuwait
    '+966': 'SA', // Saudi Arabia
    '+967': 'YE', // Yemen
    '+968': 'OM', // Oman
    '+970': 'PS', // Palestine
    '+971': 'AE', // United Arab Emirates
    '+972': 'IL', // Israel
    '+973': 'BH', // Bahrain
    '+974': 'QA', // Qatar
    '+975': 'BT', // Bhutan
    '+976': 'MN', // Mongolia
    '+977': 'NP', // Nepal
    '+992': 'TJ', // Tajikistan
    '+993': 'TM', // Turkmenistan
    '+994': 'AZ', // Azerbaijan
    '+995': 'GE', // Georgia
    '+996': 'KG', // Kyrgyzstan
    '+998': 'UZ', // Uzbekistan
  };

  static String getDialCodeFromCountryCode(String countryCode) {
    final dialCode = _countryDialCodes[countryCode.toUpperCase()];
    return dialCode ?? '+1';
  }

  static String getCountryCodeFromDialCode(String dialCode) {
    final countryCode = _dialCodeToCountry[dialCode];
    return countryCode ?? 'US';
  }

  static String getCountryCodeFromPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'US';
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleanNumber.startsWith('+')) {
      return 'US';
    }

    final sortedDialCodes = _dialCodeToCountry.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

    for (final dialCode in sortedDialCodes) {
      if (cleanNumber.startsWith(dialCode)) {
        final countryCode = _dialCodeToCountry[dialCode]!;
        return countryCode;
      }
    }

    return 'US';
  }

  static String getDialCodeFromPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '+1';
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleanNumber.startsWith('+')) {
      return '+1';
    }

    final sortedDialCodes = _dialCodeToCountry.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

    for (final dialCode in sortedDialCodes) {
      if (cleanNumber.startsWith(dialCode)) {
        return dialCode;
      }
    }

    return '+1';
  }

  static String? getLocalPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }

    final dialCode = getDialCodeFromPhoneNumber(phoneNumber);
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final localNumber = cleanNumber.replaceFirst(dialCode, '');

    return localNumber.isEmpty ? null : localNumber;
  }

  static PhoneNumber createPhoneNumberFromInternational(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return PhoneNumber(isoCode: 'US', dialCode: '+1');
    }

    final countryCode = getCountryCodeFromPhoneNumber(phoneNumber);
    final dialCode = getDialCodeFromPhoneNumber(phoneNumber);

    return PhoneNumber(phoneNumber: phoneNumber, isoCode: countryCode, dialCode: dialCode);
  }

  static PhoneNumber createPhoneNumberForField(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return PhoneNumber(isoCode: 'US', dialCode: '+1');
    }

    final countryCode = getCountryCodeFromPhoneNumber(phoneNumber);
    final dialCode = getDialCodeFromPhoneNumber(phoneNumber);
    final localNumber = getLocalPhoneNumber(phoneNumber);

    final completeNumber = '$dialCode$localNumber';

    return PhoneNumber(phoneNumber: completeNumber, isoCode: countryCode, dialCode: dialCode);
  }

  static bool isValidPhoneNumberFormat(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false;
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleanNumber.startsWith('+')) {
      return false;
    }

    final digitsOnly = cleanNumber.replaceAll('+', '');
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }

  static String formatPhoneNumberForDisplay(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '';
    }

    final dialCode = getDialCodeFromPhoneNumber(phoneNumber);
    final localNumber = getLocalPhoneNumber(phoneNumber);

    if (localNumber == null || localNumber.isEmpty) {
      return phoneNumber;
    }

    if (dialCode == '+1' && localNumber.length == 10) {
      return '$dialCode (${localNumber.substring(0, 3)}) ${localNumber.substring(3, 6)}-${localNumber.substring(6)}';
    } else if (dialCode == '+44' && localNumber.length >= 10) {
      return '$dialCode ${localNumber.substring(0, 2)} ${localNumber.substring(2, 6)} ${localNumber.substring(6)}';
    } else {
      final formatted = StringBuffer(dialCode);
      formatted.write(' ');

      for (int i = 0; i < localNumber.length; i++) {
        if (i > 0 && i % 3 == 0) {
          formatted.write(' ');
        }
        formatted.write(localNumber[i]);
      }

      return formatted.toString();
    }
  }

  static Map<String, String> getAllCountriesWithDialCodes() {
    return Map.from(_countryDialCodes);
  }

  static bool isCountryCodeSupported(String countryCode) {
    return _countryDialCodes.containsKey(countryCode.toUpperCase());
  }

  static bool isDialCodeSupported(String dialCode) {
    return _dialCodeToCountry.containsKey(dialCode);
  }
}
