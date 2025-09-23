import '../constants/app_strings.dart';
import '../utils/logger/logger.dart';

/// Helper class for timezone operations using Flutter's native functionality
/// Handles ALL world timezones with comprehensive IANA timezone mapping
class TimezoneHelper {
  static const String _fallbackTimezone = 'UTC';

  /// Gets the user's local timezone using Dart's native DateTime functionality
  /// Returns a proper IANA timezone identifier based on UTC offset
  static Future<String> getUserTimezone() async {
    try {
      final String timezone = _getTimezoneFromOffset();
      Log.i(TimezoneHelper, 'User timezone detected: $timezone');
      return timezone;
    } catch (e) {
      Log.e(TimezoneHelper, '${AppStrings.failedToGetTimezone}: $e');
      return _fallbackTimezone;
    }
  }

  /// Gets timezone using Dart's DateTime offset calculation
  static String _getTimezoneFromOffset() {
    final DateTime now = DateTime.now();
    final Duration offset = now.timeZoneOffset;

    final int totalMinutes = offset.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    // Create offset string for mapping
    final String sign = totalMinutes >= 0 ? '+' : '-';
    final String formattedHours = hours.abs().toString().padLeft(2, '0');
    final String formattedMinutes = minutes.abs().toString().padLeft(2, '0');
    final String offsetString = '$sign$formattedHours:$formattedMinutes';

    // Map UTC offsets to IANA timezone identifiers
    return _getTimezoneFromOffsetString(offsetString, now);
  }

  /// Comprehensive mapping of ALL world timezones by UTC offset
  /// Covers every possible timezone offset used globally
  static String _getTimezoneFromOffsetString(String offsetString, DateTime now) {
    final Map<String, List<String>> offsetToTimezones = {
      // UTC-12:00 (Baker Island, Howland Island)
      '-12:00': ['Etc/GMT+12', 'Pacific/Baker', 'Pacific/Howland'],

      // UTC-11:00 (American Samoa, Niue)
      '-11:00': ['Pacific/Pago_Pago', 'Pacific/Niue', 'Pacific/Midway', 'Etc/GMT+11'],

      // UTC-10:00 (Hawaii, Cook Islands, French Polynesia)
      '-10:00': ['Pacific/Honolulu', 'Pacific/Rarotonga', 'Pacific/Tahiti', 'America/Adak'],

      // UTC-09:30 (Marquesas Islands)
      '-09:30': ['Pacific/Marquesas'],

      // UTC-09:00 (Alaska, French Polynesia)
      '-09:00': ['America/Anchorage', 'America/Juneau', 'Pacific/Gambier', 'Etc/GMT+9'],

      // UTC-08:00 (Pacific Time - US/Canada, Baja California)
      '-08:00': ['America/Los_Angeles', 'America/Vancouver', 'America/Tijuana', 'America/Whitehorse', 'Pacific/Pitcairn'],

      // UTC-07:00 (Mountain Time - US/Canada, Arizona)
      '-07:00': ['America/Denver', 'America/Phoenix', 'America/Edmonton', 'America/Mazatlan', 'America/Hermosillo'],

      // UTC-06:00 (Central Time - US/Canada, Mexico, Central America)
      '-06:00': [
        'America/Chicago',
        'America/Mexico_City',
        'America/Winnipeg',
        'America/Guatemala',
        'America/Tegucigalpa',
        'America/Managua',
        'America/Costa_Rica',
        'America/Belize',
        'Pacific/Easter',
        'Pacific/Galapagos',
      ],

      // UTC-05:00 (Eastern Time - US/Canada, Colombia, Peru, Ecuador)
      '-05:00': [
        'America/New_York',
        'America/Toronto',
        'America/Bogota',
        'America/Lima',
        'America/Panama',
        'America/Havana',
        'America/Jamaica',
        'America/Cayman',
        'America/Eirunepe',
        'America/Rio_Branco',
      ],

      // UTC-04:00 (Atlantic Time, Venezuela, Bolivia, Brazil West)
      '-04:00': [
        'America/Halifax',
        'America/Caracas',
        'America/La_Paz',
        'America/Santiago',
        'America/Asuncion',
        'America/Campo_Grande',
        'America/Cuiaba',
        'America/Porto_Velho',
        'America/Boa_Vista',
        'America/Manaus',
        'America/Barbados',
        'America/Martinique',
        'America/Puerto_Rico',
        'America/Santo_Domingo',
        'Atlantic/Bermuda',
      ],

      // UTC-03:30 (Newfoundland Time)
      '-03:30': ['America/St_Johns'],

      // UTC-03:00 (Brazil, Argentina, Uruguay, French Guiana)
      '-03:00': [
        'America/Sao_Paulo',
        'America/Argentina/Buenos_Aires',
        'America/Montevideo',
        'America/Cayenne',
        'America/Paramaribo',
        'America/Fortaleza',
        'America/Recife',
        'America/Araguaina',
        'America/Bahia',
        'America/Maceio',
        'Atlantic/Stanley',
      ],

      // UTC-02:00 (South Georgia, Brazil Atlantic islands)
      '-02:00': ['America/Noronha', 'Atlantic/South_Georgia', 'Etc/GMT+2'],

      // UTC-01:00 (Azores, Cape Verde)
      '-01:00': ['Atlantic/Azores', 'Atlantic/Cape_Verde', 'Etc/GMT+1'],

      // UTC+00:00 (GMT, Western Europe, West Africa)
      '+00:00': [
        'UTC',
        'Europe/London',
        'Europe/Dublin',
        'Europe/Lisbon',
        'Africa/Casablanca',
        'Africa/Accra',
        'Africa/Abidjan',
        'Africa/Dakar',
        'Africa/Bamako',
        'Africa/Conakry',
        'Africa/Bissau',
        'Africa/Monrovia',
        'Africa/Freetown',
        'Atlantic/Canary',
        'Atlantic/Madeira',
        'Atlantic/Reykjavik',
      ],

      // UTC+01:00 (Central Europe, West/Central Africa)
      '+01:00': [
        'Europe/Berlin',
        'Europe/Paris',
        'Europe/Rome',
        'Europe/Madrid',
        'Europe/Amsterdam',
        'Europe/Brussels',
        'Europe/Vienna',
        'Europe/Prague',
        'Europe/Warsaw',
        'Europe/Stockholm',
        'Europe/Oslo',
        'Europe/Copenhagen',
        'Europe/Zurich',
        'Europe/Budapest',
        'Europe/Belgrade',
        'Europe/Zagreb',
        'Europe/Ljubljana',
        'Europe/Sarajevo',
        'Europe/Skopje',
        'Europe/Podgorica',
        'Europe/Tirane',
        'Africa/Lagos',
        'Africa/Kinshasa',
        'Africa/Luanda',
        'Africa/Porto-Novo',
        'Africa/Douala',
        'Africa/Bangui',
        'Africa/Ndjamena',
        'Africa/Brazzaville',
        'Africa/Malabo',
        'Africa/Libreville',
        'Africa/Niamey',
        'Africa/Algiers',
        'Africa/Tunis',
      ],

      // UTC+02:00 (Eastern Europe, Central/Eastern Africa, Middle East)
      '+02:00': [
        'Europe/Athens',
        'Europe/Helsinki',
        'Europe/Tallinn',
        'Europe/Riga',
        'Europe/Vilnius',
        'Europe/Kiev',
        'Europe/Chisinau',
        'Europe/Bucharest',
        'Europe/Sofia',
        'Europe/Istanbul',
        'Africa/Cairo',
        'Africa/Johannesburg',
        'Africa/Harare',
        'Africa/Maputo',
        'Africa/Windhoek',
        'Africa/Lusaka',
        'Africa/Blantyre',
        'Africa/Bujumbura',
        'Africa/Gaborone',
        'Africa/Maseru',
        'Africa/Mbabane',
        'Africa/Kigali',
        'Asia/Jerusalem',
        'Asia/Damascus',
        'Asia/Beirut',
        'Asia/Amman',
        'Asia/Gaza',
        'Asia/Hebron',
      ],

      // UTC+03:00 (Moscow Time, East Africa, Arabian Peninsula)
      '+03:00': [
        'Europe/Moscow',
        'Europe/Minsk',
        'Asia/Riyadh',
        'Asia/Kuwait',
        'Asia/Qatar',
        'Asia/Bahrain',
        'Asia/Baghdad',
        'Africa/Nairobi',
        'Africa/Dar_es_Salaam',
        'Africa/Kampala',
        'Africa/Khartoum',
        'Africa/Addis_Ababa',
        'Africa/Asmara',
        'Africa/Djibouti',
        'Africa/Mogadishu',
        'Indian/Comoro',
        'Indian/Antananarivo',
        'Indian/Mayotte',
      ],

      // UTC+03:30 (Iran Standard Time)
      '+03:30': ['Asia/Tehran'],

      // UTC+04:00 (Gulf Time, Armenia, Azerbaijan, Georgia)
      '+04:00': [
        'Asia/Dubai',
        'Asia/Muscat',
        'Asia/Baku',
        'Asia/Yerevan',
        'Asia/Tbilisi',
        'Europe/Samara',
        'Indian/Mauritius',
        'Indian/Reunion',
        'Indian/Mahe',
      ],

      // UTC+04:30 (Afghanistan Time)
      '+04:30': ['Asia/Kabul'],

      // UTC+05:00 (Pakistan, Uzbekistan, Kazakhstan West)
      '+05:00': [
        'Asia/Karachi',
        'Asia/Tashkent',
        'Asia/Samarkand',
        'Asia/Dushanbe',
        'Asia/Ashgabat',
        'Asia/Yekaterinburg',
        'Asia/Oral',
        'Asia/Aqtobe',
        'Asia/Aqtau',
        'Indian/Kerguelen',
        'Indian/Maldives',
      ],

      // UTC+05:30 (India, Sri Lanka)
      '+05:30': ['Asia/Kolkata', 'Asia/Colombo'],

      // UTC+05:45 (Nepal Time)
      '+05:45': ['Asia/Kathmandu'],

      // UTC+06:00 (Bangladesh, Bhutan, Kazakhstan East, Kyrgyzstan)
      '+06:00': ['Asia/Dhaka', 'Asia/Thimphu', 'Asia/Almaty', 'Asia/Bishkek', 'Asia/Omsk', 'Asia/Qyzylorda', 'Indian/Chagos'],

      // UTC+06:30 (Myanmar Time, Cocos Islands)
      '+06:30': ['Asia/Yangon', 'Indian/Cocos'],

      // UTC+07:00 (Southeast Asia, Western Indonesia)
      '+07:00': [
        'Asia/Bangkok',
        'Asia/Ho_Chi_Minh',
        'Asia/Jakarta',
        'Asia/Phnom_Penh',
        'Asia/Vientiane',
        'Asia/Krasnoyarsk',
        'Asia/Barnaul',
        'Asia/Hovd',
        'Asia/Novokuznetsk',
        'Asia/Novosibirsk',
        'Asia/Tomsk',
        'Indian/Christmas',
      ],

      // UTC+08:00 (China, Southeast Asia, Western Australia)
      '+08:00': [
        'Asia/Shanghai',
        'Asia/Singapore',
        'Asia/Manila',
        'Asia/Kuala_Lumpur',
        'Asia/Brunei',
        'Asia/Makassar',
        'Asia/Taipei',
        'Asia/Hong_Kong',
        'Asia/Macau',
        'Asia/Irkutsk',
        'Asia/Ulaanbaatar',
        'Asia/Choibalsan',
        'Australia/Perth',
      ],

      // UTC+08:30 (North Korea - Pyongyang Time)
      '+08:30': ['Asia/Pyongyang'],

      // UTC+08:45 (Australia - Eucla)
      '+08:45': ['Australia/Eucla'],

      // UTC+09:00 (Japan, Korea, Eastern Indonesia, Eastern Russia)
      '+09:00': ['Asia/Tokyo', 'Asia/Seoul', 'Asia/Jayapura', 'Asia/Yakutsk', 'Asia/Chita', 'Asia/Khandyga', 'Pacific/Palau'],

      // UTC+09:30 (Australia Central Time)
      '+09:30': ['Australia/Adelaide', 'Australia/Darwin', 'Australia/Broken_Hill'],

      // UTC+10:00 (Australia Eastern Time, Pacific Islands)
      '+10:00': [
        'Australia/Sydney',
        'Australia/Melbourne',
        'Australia/Brisbane',
        'Australia/Hobart',
        'Asia/Vladivostok',
        'Asia/Ust-Nera',
        'Asia/Sakhalin',
        'Pacific/Guam',
        'Pacific/Saipan',
        'Pacific/Chuuk',
        'Pacific/Port_Moresby',
      ],

      // UTC+10:30 (Australia - Lord Howe Island)
      '+10:30': ['Australia/Lord_Howe'],

      // UTC+11:00 (Solomon Islands, Vanuatu, New Caledonia)
      '+11:00': [
        'Asia/Magadan',
        'Asia/Srednekolymsk',
        'Pacific/Guadalcanal',
        'Pacific/Efate',
        'Pacific/Noumea',
        'Pacific/Norfolk',
        'Pacific/Kosrae',
        'Pacific/Pohnpei',
      ],

      // UTC+12:00 (New Zealand, Fiji, Marshall Islands)
      '+12:00': [
        'Pacific/Auckland',
        'Pacific/Fiji',
        'Asia/Kamchatka',
        'Asia/Anadyr',
        'Pacific/Majuro',
        'Pacific/Kwajalein',
        'Pacific/Tarawa',
        'Pacific/Nauru',
        'Pacific/Funafuti',
        'Pacific/Wake',
        'Pacific/Wallis',
      ],

      // UTC+12:45 (New Zealand - Chatham Islands)
      '+12:45': ['Pacific/Chatham'],

      // UTC+13:00 (Tonga, Samoa, Phoenix Islands)
      '+13:00': ['Pacific/Tongatapu', 'Pacific/Apia', 'Pacific/Enderbury', 'Pacific/Fakaofo'],

      // UTC+14:00 (Line Islands - Kiritimati)
      '+14:00': ['Pacific/Kiritimati'],
    };

    // Get possible timezones for this offset
    final List<String>? possibleTimezones = offsetToTimezones[offsetString];

    if (possibleTimezones == null || possibleTimezones.isEmpty) {
      // Handle any edge cases or unknown offsets
      Log.w(TimezoneHelper, 'Unknown offset: $offsetString, using generic UTC offset');
      return _createGenericUtcOffset(offsetString);
    }

    // Return the most appropriate timezone for this offset
    // Priority: Major cities/regions first, then smaller locations
    return possibleTimezones.first;
  }

  /// Creates a generic UTC offset timezone identifier
  static String _createGenericUtcOffset(String offsetString) {
    // Convert +05:00 to Etc/GMT-5 (note the sign flip in Etc/GMT)
    final parts = offsetString.split(':');
    if (parts.length != 2) return 'UTC';

    final sign = offsetString.startsWith('+') ? '-' : '+';
    final hours = int.tryParse(parts[0].replaceAll('+', '').replaceAll('-', '')) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    if (minutes == 0) {
      return 'Etc/GMT$sign$hours';
    } else {
      // For non-hour offsets, use the original format
      return 'UTC$offsetString';
    }
  }

  /// Gets timezone name for display purposes - comprehensive mapping
  static String getTimezoneDisplayName(String timezone) {
    final Map<String, String> timezoneDisplayNames = {
      // Major World Cities & Regions
      'UTC': 'UTC',
      'Europe/London': 'London',
      'Europe/Berlin': 'Berlin',
      'Europe/Paris': 'Paris',
      'Europe/Rome': 'Rome',
      'Europe/Madrid': 'Madrid',
      'Europe/Amsterdam': 'Amsterdam',
      'Europe/Brussels': 'Brussels',
      'Europe/Vienna': 'Vienna',
      'Europe/Prague': 'Prague',
      'Europe/Warsaw': 'Warsaw',
      'Europe/Stockholm': 'Stockholm',
      'Europe/Oslo': 'Oslo',
      'Europe/Copenhagen': 'Copenhagen',
      'Europe/Zurich': 'Zurich',
      'Europe/Athens': 'Athens',
      'Europe/Helsinki': 'Helsinki',
      'Europe/Moscow': 'Moscow',
      'Europe/Istanbul': 'Istanbul',

      // Asia
      'Asia/Dubai': 'Dubai',
      'Asia/Karachi': 'Karachi',
      'Asia/Kolkata': 'Mumbai/Delhi',
      'Asia/Dhaka': 'Dhaka',
      'Asia/Bangkok': 'Bangkok',
      'Asia/Jakarta': 'Jakarta',
      'Asia/Singapore': 'Singapore',
      'Asia/Manila': 'Manila',
      'Asia/Shanghai': 'Beijing/Shanghai',
      'Asia/Hong_Kong': 'Hong Kong',
      'Asia/Taipei': 'Taipei',
      'Asia/Tokyo': 'Tokyo',
      'Asia/Seoul': 'Seoul',
      'Asia/Tehran': 'Tehran',
      'Asia/Jerusalem': 'Jerusalem',
      'Asia/Riyadh': 'Riyadh',
      'Asia/Kuwait': 'Kuwait',
      'Asia/Baghdad': 'Baghdad',
      'Asia/Kabul': 'Kabul',
      'Asia/Tashkent': 'Tashkent',
      'Asia/Almaty': 'Almaty',
      'Asia/Yangon': 'Yangon',
      'Asia/Kathmandu': 'Kathmandu',
      'Asia/Colombo': 'Colombo',
      'Asia/Thimphu': 'Thimphu',

      // Americas
      'America/New_York': 'New York',
      'America/Chicago': 'Chicago',
      'America/Denver': 'Denver',
      'America/Los_Angeles': 'Los Angeles',
      'America/Vancouver': 'Vancouver',
      'America/Toronto': 'Toronto',
      'America/Montreal': 'Montreal',
      'America/Halifax': 'Halifax',
      'America/St_Johns': 'St. Johns',
      'America/Mexico_City': 'Mexico City',
      'America/Guatemala': 'Guatemala City',
      'America/Bogota': 'Bogotá',
      'America/Lima': 'Lima',
      'America/Sao_Paulo': 'São Paulo',
      'America/Argentina/Buenos_Aires': 'Buenos Aires',
      'America/Montevideo': 'Montevideo',
      'America/Santiago': 'Santiago',
      'America/Caracas': 'Caracas',
      'America/La_Paz': 'La Paz',
      'America/Havana': 'Havana',
      'America/Jamaica': 'Kingston',
      'America/Panama': 'Panama City',
      'America/Costa_Rica': 'San José',

      // Africa
      'Africa/Cairo': 'Cairo',
      'Africa/Lagos': 'Lagos',
      'Africa/Johannesburg': 'Johannesburg',
      'Africa/Nairobi': 'Nairobi',
      'Africa/Casablanca': 'Casablanca',
      'Africa/Algiers': 'Algiers',
      'Africa/Tunis': 'Tunis',
      'Africa/Accra': 'Accra',
      'Africa/Addis_Ababa': 'Addis Ababa',
      'Africa/Dar_es_Salaam': 'Dar es Salaam',
      'Africa/Kinshasa': 'Kinshasa',
      'Africa/Luanda': 'Luanda',
      'Africa/Harare': 'Harare',
      'Africa/Maputo': 'Maputo',

      // Australia & Oceania
      'Australia/Sydney': 'Sydney',
      'Australia/Melbourne': 'Melbourne',
      'Australia/Brisbane': 'Brisbane',
      'Australia/Perth': 'Perth',
      'Australia/Adelaide': 'Adelaide',
      'Australia/Darwin': 'Darwin',
      'Australia/Hobart': 'Hobart',
      'Pacific/Auckland': 'Auckland',
      'Pacific/Fiji': 'Suva',
      'Pacific/Honolulu': 'Honolulu',
      'Pacific/Tahiti': 'Tahiti',
      'Pacific/Guam': 'Guam',
      'Pacific/Pago_Pago': 'Pago Pago',
      'Pacific/Tongatapu': 'Nuku\'alofa',
      'Pacific/Apia': 'Apia',
      'Pacific/Noumea': 'Nouméa',
      'Pacific/Port_Moresby': 'Port Moresby',

      // Atlantic
      'Atlantic/Azores': 'Azores',
      'Atlantic/Cape_Verde': 'Cape Verde',
      'Atlantic/Canary': 'Canary Islands',
      'Atlantic/Reykjavik': 'Reykjavik',
      'Atlantic/Bermuda': 'Bermuda',
    };

    return timezoneDisplayNames[timezone] ?? timezone.split('/').last.replaceAll('_', ' ');
  }

  /// Gets the current UTC offset as a string (e.g., "+05:00", "-08:00")
  static String getCurrentUtcOffset() {
    final Duration offset = DateTime.now().timeZoneOffset;
    final int totalMinutes = offset.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final String sign = totalMinutes >= 0 ? '+' : '-';
    final String formattedHours = hours.abs().toString().padLeft(2, '0');
    final String formattedMinutes = minutes.abs().toString().padLeft(2, '0');

    return '$sign$formattedHours:$formattedMinutes';
  }

  /// Checks if the current timezone observes daylight saving time
  /// This is a simple heuristic based on offset changes throughout the year
  static bool isDaylightSavingTime() {
    final DateTime now = DateTime.now();
    final DateTime winter = DateTime(now.year, 1, 15); // Mid January
    final DateTime summer = DateTime(now.year, 7, 15); // Mid July

    return now.timeZoneOffset != winter.timeZoneOffset || now.timeZoneOffset != summer.timeZoneOffset;
  }

  /// Gets all supported timezone offsets
  static List<String> getAllSupportedOffsets() {
    return [
      '-12:00',
      '-11:00',
      '-10:00',
      '-09:30',
      '-09:00',
      '-08:00',
      '-07:00',
      '-06:00',
      '-05:00',
      '-04:00',
      '-03:30',
      '-03:00',
      '-02:00',
      '-01:00',
      '+00:00',
      '+01:00',
      '+02:00',
      '+03:00',
      '+03:30',
      '+04:00',
      '+04:30',
      '+05:00',
      '+05:30',
      '+05:45',
      '+06:00',
      '+06:30',
      '+07:00',
      '+08:00',
      '+08:30',
      '+08:45',
      '+09:00',
      '+09:30',
      '+10:00',
      '+10:30',
      '+11:00',
      '+12:00',
      '+12:45',
      '+13:00',
      '+14:00',
    ];
  }

  /// Gets the fallback timezone (UTC)
  static String get fallbackTimezone => _fallbackTimezone;
}
