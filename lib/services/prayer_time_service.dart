class PrayerTimeService {
  static const Map<String, Map<String, String>> _cityPrayerTimes = {
    'Jakarta': {
      'Subuh': '04:35 WIB',
      'Dzuhur': '11:53 WIB',
      'Ashar': '15:15 WIB',
      'Maghrib': '17:48 WIB',
      'Isya': '19:01 WIB',
    },
    'Surabaya': {
      'Subuh': '04:15 WIB',
      'Dzuhur': '11:30 WIB',
      'Ashar': '14:50 WIB',
      'Maghrib': '17:25 WIB',
      'Isya': '18:38 WIB',
    },
    'Bandung': {
      'Subuh': '04:38 WIB',
      'Dzuhur': '11:54 WIB',
      'Ashar': '15:16 WIB',
      'Maghrib': '17:50 WIB',
      'Isya': '19:03 WIB',
    },
    'Yogyakarta': {
      'Subuh': '04:28 WIB',
      'Dzuhur': '11:43 WIB',
      'Ashar': '15:02 WIB',
      'Maghrib': '17:38 WIB',
      'Isya': '18:51 WIB',
    },
    'Medan': {
      'Subuh': '05:00 WIB',
      'Dzuhur': '12:20 WIB',
      'Ashar': '15:45 WIB',
      'Maghrib': '18:35 WIB',
      'Isya': '19:48 WIB',
    },
    'Makassar': {
      'Subuh': '04:45 WITA',
      'Dzuhur': '12:05 WITA',
      'Ashar': '15:25 WITA',
      'Maghrib': '18:00 WITA',
      'Isya': '19:12 WITA',
    },
    'Denpasar': {
      'Subuh': '05:00 WITA',
      'Dzuhur': '12:20 WITA',
      'Ashar': '15:40 WITA',
      'Maghrib': '18:15 WITA',
      'Isya': '19:28 WITA',
    },
    'Samarinda': {
      'Subuh': '04:45 WITA',
      'Dzuhur': '12:10 WITA',
      'Ashar': '15:35 WITA',
      'Maghrib': '18:15 WITA',
      'Isya': '19:25 WITA',
    },
    'Jayapura': {
      'Subuh': '04:10 WIT',
      'Dzuhur': '11:40 WIT',
      'Ashar': '15:00 WIT',
      'Maghrib': '17:40 WIT',
      'Isya': '18:50 WIT',
    },
  };

  static List<String> getAvailableCities() {
    return _cityPrayerTimes.keys.toList();
  }

  static Map<String, String> getPrayerTimes(String city) {
    // Fallback to Jakarta if city not found
    return _cityPrayerTimes[city] ?? _cityPrayerTimes['Jakarta']!;
  }
}
