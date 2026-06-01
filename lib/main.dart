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
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
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
          seedColor: const Color(0xFF1C6758),
          brightness: Brightness.light,
          primary: const Color(0xFF1C6758),
          secondary: const Color(0xFF0E4338),
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
          seedColor: const Color(0xFF1C6758),
          brightness: Brightness.dark,
          primary: const Color(0xFF1C6758),
          secondary: const Color(0xFF0E4338),
          surface: const Color(0xFF133630),
          background: const Color(0xFF09201C),
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
  String _cityLocation = 'Jakarta';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await PreferenceService.getUserName();
    final city = await PreferenceService.getCityLocation();
    setState(() {
      _userName = name;
      _cityLocation = city;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsDialog(
          onSaved: () {
            _loadUserData();
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
      HomeScreen(
        userName: _userName,
        cityLocation: _cityLocation,
        sholatRepository: _sholatRepository,
        targetRepository: _targetRepository,
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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
          return 'IbadahKu';
        case 1:
          return 'Sholat Tracker';
        case 2:
          return 'Target Ibadah';
        case 3:
          return 'Catatan Doa & Dzikir';
        case 4:
          return 'Jurnal Ibadah';
        default:
          return 'IbadahKu';
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09201C) : const Color(0xFFF2F9F7),
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
            onPressed: _showSettingsDialog,
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
          backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
          indicatorColor: const Color(0xFF1C6758).withOpacity(0.2),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.home_rounded,
                color: Color(0xFF1C6758),
              ),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.checklist_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.checklist_rounded,
                color: Color(0xFF1C6758),
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
                color: Color(0xFF1C6758),
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
                color: Color(0xFF1C6758),
              ),
              label: 'Doa',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.edit_note_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF1C6758),
              ),
              label: 'Jurnal',
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const SettingsDialog({super.key, required this.onSaved});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _nameController;
  late String _city;
  bool _notifEnabled = true;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await PreferenceService.getUserName();
    final city = await PreferenceService.getCityLocation();
    final notif = await PreferenceService.getNotifEnabled();
    setState(() {
      _nameController = TextEditingController(text: name);
      _city = city;
      _notifEnabled = notif;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await PreferenceService.saveUserName(_nameController.text.trim());
      await PreferenceService.saveCityLocation(_city);
      await PreferenceService.saveNotifEnabled(_notifEnabled);

      widget.onSaved();
      if (mounted) Navigator.pop(context);
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
      backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Pengaturan Profil & Aplikasi',
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
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.person_rounded, size: 20),
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
                value: _city,
                dropdownColor: isDark ? const Color(0xFF133630) : Colors.white,
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
                      _city = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Aktifkan Notifikasi',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Pengingat waktu sholat dan target ibadah',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                value: _notifEnabled,
                activeColor: const Color(0xFF1C6758),
                onChanged: (val) {
                  setState(() {
                    _notifEnabled = val;
                  });
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
            backgroundColor: const Color(0xFF1C6758),
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
