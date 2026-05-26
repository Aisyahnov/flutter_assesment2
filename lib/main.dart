import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/database_helper.dart';
import 'repositories/sholat_repository.dart';
import 'repositories/target_repository.dart';
import 'services/preference_service.dart';
import 'screens/sholat_screen.dart';
import 'screens/target_screen.dart';

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
  final GlobalKey<State<SholatScreen>> _sholatScreenKey = GlobalKey();

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Pengguna';
    });
  }

  void _showProfileSettingsDialog() {
    final nameController = TextEditingController(text: _userName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1938) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Pengaturan Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_name', nameController.text.trim());
                  Navigator.pop(context);
                  _loadUserName();
                  // Notify SholatScreen to update user name
                  if (_sholatScreenKey.currentState != null) {
                    // ignore: invalid_use_of_protected_member
                    _sholatScreenKey.currentState!.setState(() {
                      (_sholatScreenKey.currentState as dynamic).refreshUserName();
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E2DE2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0C20) : const Color(0xFFF3F2F7),
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Sholat Tracker' : 'Target Ibadah',
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
          ],
        ),
      ),
    );
  }
}
