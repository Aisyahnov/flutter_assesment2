import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sholat_tracker.dart';
import '../repositories/sholat_repository.dart';
import '../services/prayer_time_service.dart';

class SholatScreen extends StatefulWidget {
  final SholatRepository sholatRepository;

  const SholatScreen({
    super.key,
    required this.sholatRepository,
  });

  @override
  State<SholatScreen> createState() => _SholatScreenState();
}

class _SholatScreenState extends State<SholatScreen> {
  DateTime _selectedDate = DateTime.now();
  List<SholatTracker> _currentTrackers = [];
  bool _isLoading = true;
  int _streak = 0;
  String _userName = 'Pengguna';
  String _cityLocation = 'Jakarta';

  final List<String> _daftarWaktu = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLocalPrefs();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final dateStr = _formatDate(_selectedDate);
    var trackers = await widget.sholatRepository.getSholatByTanggal(dateStr);
    
    if (trackers.isEmpty) {
      for (final w in _daftarWaktu) {
        final t = SholatTracker(tanggal: dateStr, waktu: w, status: 'belum');
        await widget.sholatRepository.insertSholat(t);
      }
      trackers = await widget.sholatRepository.getSholatByTanggal(dateStr);
    }

    trackers.sort((a, b) {
      return _daftarWaktu.indexOf(a.waktu).compareTo(_daftarWaktu.indexOf(b.waktu));
    });

    setState(() {
      _currentTrackers = trackers;
      _isLoading = false;
    });
  }

  Future<void> _loadLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final activeIndex = prefs.getInt('active_user_index') ?? 1;
    setState(() {
      _streak = prefs.getInt('user_streak') ?? 0;
      _userName = prefs.getString('user_name_$activeIndex') ?? (activeIndex == 1 ? (prefs.getString('user_name') ?? 'Pengguna 1') : 'Pengguna 2');
      _cityLocation = prefs.getString('city_location_$activeIndex') ?? 'Jakarta';
    });
  }

  Future<void> _updatePrayerStatus(String prayerName, String newStatus) async {
    final index = _currentTrackers.indexWhere((t) => t.waktu == prayerName);
    if (index == -1) return;

    final updated = _currentTrackers[index].copyWith(
      status: newStatus,
    );

    await widget.sholatRepository.updateSholat(updated);
    setState(() {
      _currentTrackers[index] = updated;
    });

    _checkAndUpdateStreak();
  }

  Future<void> _checkAndUpdateStreak() async {
    if (_currentTrackers.length < 5) return;

    final bool completedAllToday = _currentTrackers.every((t) => t.status != 'belum');
    final todayStr = _formatDate(DateTime.now());
    final selectedStr = _formatDate(_selectedDate);

    if (selectedStr == todayStr) {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('last_streak_date') ?? '';
      int currentStreak = prefs.getInt('user_streak') ?? 0;

      if (completedAllToday) {
        if (lastDate != todayStr) {
          final yesterdayStr = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
          if (lastDate == yesterdayStr || lastDate.isEmpty) {
            currentStreak += 1;
          } else {
            currentStreak = 1;
          }
          await prefs.setInt('user_streak', currentStreak);
          await prefs.setString('last_streak_date', todayStr);
          setState(() {
            _streak = currentStreak;
          });
        }
      }
    }
  }

  int _getCompletedCount() {
    return _currentTrackers.where((t) => t.status != 'belum').length;
  }

  double _getCompletionPercentage() {
    if (_currentTrackers.isEmpty) return 0.0;
    return _getCompletedCount() / _currentTrackers.length.toDouble();
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadData();
  }

  Future<void> refreshUserName() async {
    await _loadLocalPrefs();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'tepat_waktu':
        return Colors.green;
      case 'telat':
        return Colors.orange;
      case 'qadha':
        return Colors.red;
      case 'belum':
      default:
        return Colors.grey;
    }
  }

  String _formatStatusLabel(String status) {
    switch (status) {
      case 'tepat_waktu':
        return 'Tepat Waktu';
      case 'telat':
        return 'Telat';
      case 'qadha':
        return 'Qadha';
      case 'belum':
      default:
        return 'Belum';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = _getCompletedCount();
    final percentage = _getCompletionPercentage();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F0C20), const Color(0xFF15102A)]
                : [const Color(0xFFF3F2F7), const Color(0xFFE8E7F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamualaikum,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          _userName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: isDark ? Colors.purpleAccent : const Color(0xFF8E2DE2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _cityLocation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2250)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '🔥 ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '$_streak Hari',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildDateTimeline(theme),

              _buildProgressCard(theme, completedCount, percentage, isDark),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentTrackers.isEmpty
                        ? const Center(child: Text('Gagal memuat data.'))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            physics: const BouncingScrollPhysics(),
                            children: _currentTrackers.map((tracker) {
                              IconData icon;
                              Color accentColor;
                              final prayerTimes = PrayerTimeService.getPrayerTimes(_cityLocation);
                              final String timeStr = prayerTimes[tracker.waktu] ?? '--:--';

                              switch (tracker.waktu) {
                                case 'Subuh':
                                  icon = Icons.wb_twilight;
                                  accentColor = Colors.blueAccent;
                                  break;
                                case 'Dzuhur':
                                  icon = Icons.wb_sunny_rounded;
                                  accentColor = Colors.amber;
                                  break;
                                case 'Ashar':
                                  icon = Icons.wb_cloudy_rounded;
                                  accentColor = Colors.orange;
                                  break;
                                case 'Maghrib':
                                  icon = Icons.wb_twilight_rounded;
                                  accentColor = Colors.deepOrangeAccent;
                                  break;
                                case 'Isya':
                                  icon = Icons.brightness_3_rounded;
                                  accentColor = Colors.indigoAccent;
                                  break;
                                default:
                                  icon = Icons.star_border_rounded;
                                  accentColor = Colors.purple;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: _buildPrayerTile(
                                  theme: theme,
                                  name: tracker.waktu,
                                  time: timeStr,
                                  status: tracker.status,
                                  icon: icon,
                                  accentColor: accentColor,
                                  isDark: isDark,
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeline(ThemeData theme) {
    final today = DateTime.now();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: 15,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 7));
          final isSelected = _formatDate(date) == _formatDate(_selectedDate);
          final dayName = DateFormat('E').format(date).toUpperCase();
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () => _changeDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !isSelected
                    ? (isDark ? const Color(0xFF1E1938) : Colors.white)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? const Color(0xFF2C2450) : Colors.black12),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(
      ThemeData theme, int completedCount, double percentage, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1938), const Color(0xFF251E49)]
              : [Colors.white, const Color(0xFFF9F9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2C2450) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF130E26)
                      : Colors.purple.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8E2DE2),
                  ),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Ibadah',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedCount == 5
                      ? 'Luar biasa! Sholat 5 waktu Anda lengkap hari ini.'
                      : '$completedCount dari 5 sholat fardhu selesai dikerjakan.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPrayerTile({
    required ThemeData theme,
    required String name,
    required String time,
    required String status,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    final bool isCompleted = status != 'belum';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1938) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isCompleted
              ? accentColor.withOpacity(0.4)
              : (isDark ? const Color(0xFF2C2450) : Colors.black.withOpacity(0.05)),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted
                ? accentColor.withOpacity(0.2)
                : (isDark ? const Color(0xFF130E26) : accentColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isCompleted ? accentColor : (isDark ? Colors.white38 : accentColor.withOpacity(0.8)),
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
              ),
              child: Text(
                _formatStatusLabel(status),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white38 : Colors.black45,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.edit_rounded, color: isDark ? Colors.white54 : Colors.black54),
          onSelected: (newStatus) {
            _updatePrayerStatus(name, newStatus);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'tepat_waktu',
              child: Text('Tepat Waktu (Hijau)'),
            ),
            const PopupMenuItem<String>(
              value: 'telat',
              child: Text('Telat (Kuning)'),
            ),
            const PopupMenuItem<String>(
              value: 'qadha',
              child: Text('Qadha (Merah)'),
            ),
            const PopupMenuItem<String>(
              value: 'belum',
              child: Text('Belum (Abu)'),
            ),
          ],
        ),
      ),
    );
  }
}
