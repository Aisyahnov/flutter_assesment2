import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/sholat_repository.dart';
import '../repositories/target_repository.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String cityLocation;
  final SholatRepository sholatRepository;
  final TargetRepository targetRepository;
  final ValueChanged<int> onNavigate;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.cityLocation,
    required this.sholatRepository,
    required this.targetRepository,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  int _ibadahScore = 0;
  bool _isLoading = true;

  final List<String> _daftarWaktu = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Refreshes when returning to this screen
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. Hitung Ibadah Score Hari Ini
    final targets = await widget.targetRepository.getTargetByTanggal(todayStr);
    if (targets.isEmpty) {
      _ibadahScore = 0;
    } else {
      int totalTarget = targets.length;
      int completedTarget = targets.where((t) => t.isSelesai == 1).length;
      _ibadahScore = ((completedTarget / totalTarget) * 100).round();
    }

    // 2. Hitung Streak
    int currentStreak = 0;
    bool streakBroken = false;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final sholatList = await widget.sholatRepository.getSholatByTanggal(dateStr);
      
      if (sholatList.isNotEmpty) {
        Set<String> sholatLengkap = {};
        for (var s in sholatList) {
          if (_daftarWaktu.contains(s.waktu)) {
            if (s.status == 'tepat_waktu' || s.status == 'terlambat') {
              sholatLengkap.add(s.waktu);
            }
          }
        }
        
        // Logika Streak
        if (!streakBroken) {
          if (sholatLengkap.length == 5) {
            currentStreak++;
          } else if (i > 0) { 
            // Kalau hari ini belum lengkap, jangan putuskan streak jika i=0 (karena hari ini belum berakhir)
            // Tapi jika i>0 (kemarin dst) bolong, maka streak putus.
            streakBroken = true;
          }
        }
      } else {
        if (!streakBroken && i > 0) {
          streakBroken = true;
        }
      }
    }

    if (mounted) {
      setState(() {
        _streak = currentStreak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C6758)))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu Alaikum,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF133630) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: Color(0xFFF5A623), // Gold accent
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Gamification Dashboard Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1C6758), Color(0xFF0E4338)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C6758).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Color(0xFFF5A623), size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.cityLocation,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Gamification Row (Score & Streak)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Ibadah Score
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: CircularProgressIndicator(
                                          value: _ibadahScore / 100,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white24,
                                          color: const Color(0xFFF5A623),
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Text(
                                        '$_ibadahScore',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Ibadah Score',
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                              // Separator
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.white24,
                              ),

                              // Streak
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Color(0xFFF5A623),
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        '$_streak ',
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'Hari Streak',
                                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid Menu
                    Text(
                      'Menu Utama',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMenuCard(
                          title: 'Sholat Tracker',
                          icon: Icons.checklist_rounded,
                          color: const Color(0xFF1C6758),
                          isDark: isDark,
                          onTap: () => widget.onNavigate(1),
                        ),
                        _buildMenuCard(
                          title: 'Target Ibadah',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFFF5A623),
                          isDark: isDark,
                          onTap: () => widget.onNavigate(2),
                        ),
                        _buildMenuCard(
                          title: 'Doa & Dzikir',
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF0E4338),
                          isDark: isDark,
                          onTap: () => widget.onNavigate(3),
                        ),
                        _buildMenuCard(
                          title: 'Jurnal Harian',
                          icon: Icons.edit_note_rounded,
                          color: const Color(0xFF1C4F46),
                          isDark: isDark,
                          onTap: () => widget.onNavigate(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF133630) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF1C4F46) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
