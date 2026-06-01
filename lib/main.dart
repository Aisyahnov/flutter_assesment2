import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/database_helper.dart';
import 'repositories/sholat_repository.dart';
import 'repositories/target_repository.dart';
import 'repositories/doa_repository.dart';
import 'repositories/jurnal_repository.dart';
import 'services/preference_service.dart';
import 'services/prayer_time_service.dart';
import 'screens/sholat_screen.dart';
import 'screens/target_screen.dart';
import 'screens/doa_screen.dart';
import 'screens/jurnal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    final db = await DatabaseHelper.instance.database;
    print('DB berhasil dibuka: ${db.path}');
  } else {
    print('Running on Web: Menggunakan database simulasi (SharedPreferences)');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _themeMode = 'light';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await PreferenceService.getThemeMode();
    setState(() {
      _themeMode = mode;
    });
  }

  void _toggleTheme(bool val) async {
    final mode = val ? 'dark' : 'light';
    await PreferenceService.saveThemeMode(mode);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == 'dark';

    return MaterialApp(
      title: 'Tracker Ibadah',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E2DE2),
          brightness: Brightness.light,
          primary: const Color(0xFF8E2DE2),
          secondary: const Color(0xFF4A00E0),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E2DE2),
          brightness: Brightness.dark,
          primary: const Color(0xFF8E2DE2),
          secondary: const Color(0xFF4A00E0),
          surface: const Color(0xFF1E1938),
          background: const Color(0xFF0F0C20),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: MainScreen(
        isDarkMode: isDark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final SholatRepository _sholatRepository = SholatRepository();
  final TargetRepository _targetRepository = TargetRepository();
  final DoaRepository _doaRepository = DoaRepository();
  final JurnalRepository _jurnalRepository = JurnalRepository();
  final GlobalKey<State<SholatScreen>> _sholatScreenKey = GlobalKey();

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final activeIndex = prefs.getInt('active_user_index') ?? 1;
    setState(() {
      _userName = prefs.getString('user_name_$activeIndex') ?? (activeIndex == 1 ? (prefs.getString('user_name') ?? 'Pengguna 1') : 'Pengguna 2');
    });
  }

  void _showProfileSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ProfileSettingsDialog(
          onSaved: () {
            _loadUserName();
            // Notify SholatScreen to update user name & city info
            if (_sholatScreenKey.currentState != null) {
              // ignore: invalid_use_of_protected_member
              _sholatScreenKey.currentState!.setState(() {
                (_sholatScreenKey.currentState as dynamic).refreshUserName();
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final List<Widget> screens = [
      SholatScreen(
        key: _sholatScreenKey,
        sholatRepository: _sholatRepository,
      ),
      TargetScreen(
        targetRepository: _targetRepository,
      ),
      DoaScreen(
        doaRepository: _doaRepository,
      ),
      JurnalScreen(
        jurnalRepository: _jurnalRepository,
      ),
    ];

    String getAppBarTitle() {
      switch (_currentIndex) {
        case 0:
          return 'Sholat Tracker';
        case 1:
          return 'Target Ibadah';
        case 2:
          return 'Catatan Doa & Dzikir';
        case 3:
          return 'Jurnal Ibadah';
        default:
          return 'Tracker Ibadah';
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0C20) : const Color(0xFFF3F2F7),
      appBar: AppBar(
        title: Text(
          getAppBarTitle(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : Colors.black87,
            ),
            onPressed: () => widget.onThemeChanged(!isDark),
          ),
          IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _showProfileSettingsDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, -8),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF1E1938) : Colors.white,
          indicatorColor: const Color(0xFF8E2DE2).withOpacity(0.2),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.checklist_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.checklist_rounded,
                color: Color(0xFF8E2DE2),
              ),
              label: 'Sholat',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.task_alt_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.task_alt_rounded,
                color: Color(0xFF8E2DE2),
              ),
              label: 'Target',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.menu_book_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF8E2DE2),
              ),
              label: 'Doa/Dzikir',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.edit_note_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF8E2DE2),
              ),
              label: 'Jurnal',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const ProfileSettingsDialog({super.key, required this.onSaved});

  @override
  State<ProfileSettingsDialog> createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  late int _activeIndex;
  late TextEditingController _nameController1;
  late TextEditingController _nameController2;
  late String _city1;
  late String _city2;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeIndex = prefs.getInt('active_user_index') ?? 1;

      final name1 = prefs.getString('user_name_1') ?? (prefs.getString('user_name') ?? 'Pengguna 1');
      _nameController1 = TextEditingController(text: name1);
      _city1 = prefs.getString('city_location_1') ?? 'Jakarta';

      final name2 = prefs.getString('user_name_2') ?? 'Pengguna 2';
      _nameController2 = TextEditingController(text: name2);
      _city2 = prefs.getString('city_location_2') ?? 'Surabaya';

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController1.dispose();
    _nameController2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_user_index', _activeIndex);

      await prefs.setString('user_name_1', _nameController1.text.trim());
      await prefs.setString('city_location_1', _city1);

      await prefs.setString('user_name_2', _nameController2.text.trim());
      await prefs.setString('city_location_2', _city2);

      // default user_name for backwards compatibility
      if (_activeIndex == 1) {
        await prefs.setString('user_name', _nameController1.text.trim());
      } else {
        await prefs.setString('user_name', _nameController2.text.trim());
      }

      widget.onSaved();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cities = PrayerTimeService.getAvailableCities();

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1938) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Pengaturan 2 Profil Pengguna',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Profil Aktif:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Profile selector row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeIndex == 1
                              ? const Color(0xFF8E2DE2).withOpacity(0.15)
                              : (isDark ? const Color(0xFF130E26) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _activeIndex == 1 ? const Color(0xFF8E2DE2) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.person_rounded, color: Color(0xFF8E2DE2)),
                            const SizedBox(height: 4),
                            Text(
                              'Profil 1',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 2;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeIndex == 2
                              ? const Color(0xFF8E2DE2).withOpacity(0.15)
                              : (isDark ? const Color(0xFF130E26) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _activeIndex == 2 ? const Color(0xFF8E2DE2) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.person_outline_rounded, color: Colors.blueAccent),
                            const SizedBox(height: 4),
                            Text(
                              'Profil 2',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Detail Profil $_activeIndex:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _activeIndex == 1 ? const Color(0xFF8E2DE2) : Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _activeIndex == 1 ? _nameController1 : _nameController2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.edit_rounded, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _activeIndex == 1 ? _city1 : _city2,
                dropdownColor: isDark ? const Color(0xFF1E1938) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Lokasi Kota (Info Sholat)',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                ),
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      if (_activeIndex == 1) {
                        _city1 = val;
                      } else {
                        _city2 = val;
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E2DE2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Simpan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
