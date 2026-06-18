import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/jurnal_harian.dart';
import '../repositories/jurnal_repository.dart';
import '../widgets/jurnal_card_widget.dart';

class JurnalScreen extends StatefulWidget {
  final JurnalRepository jurnalRepository;

  const JurnalScreen({
    super.key,
    required this.jurnalRepository,
  });

  @override
  State<JurnalScreen> createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen> {
  DateTime _selectedDate = DateTime.now();
  List<JurnalHarian> _jurnalEntries = [];
  bool _isLoading = true;

  final Map<String, String> _moodMap = {
    '😇': 'Damai',
    '😊': 'Senang',
    '😐': 'Biasa',
    '😔': 'Sedih',
    '😢': 'Lelah',
    '😰': 'Cemas',
  };

  @override
  void initState() {
    super.initState();
    _loadJurnal();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadJurnal() async {
    setState(() {
      _isLoading = true;
    });
    final dateStr = _formatDate(_selectedDate);
    try {
      final entries = await widget.jurnalRepository.getJurnalByTanggal(dateStr);
      setState(() {
        _jurnalEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadJurnal();
  }

  Future<void> _deleteJurnal(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Jurnal?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin menghapus catatan jurnal ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await widget.jurnalRepository.deleteJurnal(id);
      _loadJurnal();
    }
  }

  void _showAddEditJurnalDialog({JurnalHarian? jurnal}) {
    final isEdit = jurnal != null;
    final catatanController = TextEditingController(text: jurnal?.catatan ?? '');
    final syukurController = TextEditingController(text: jurnal?.syukur ?? '');
    final evaluasiController = TextEditingController(text: jurnal?.evaluasi ?? '');
    String selectedMood = jurnal?.mood ?? '😇';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEdit ? 'Edit Jurnal Ibadah' : 'Tulis Jurnal Ibadah',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bagaimana suasana hatimu hari ini?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mood selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _moodMap.keys.map((emoji) {
                          final isSelected = selectedMood == emoji;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedMood = emoji;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1C6758).withOpacity(0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1C6758) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          _moodMap[selectedMood] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C6758),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: catatanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Catatan Harian Ibadah *',
                          hintText: 'Tuliskan ibadah apa saja yang telah dilakukan hari ini...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Catatan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: syukurController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Hal yang Disyukuri',
                          hintText: 'Hal baik apa yang kamu syukuri hari ini...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: evaluasiController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Evaluasi Diri',
                          hintText: 'Apa hal yang perlu diperbaiki besok...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newJurnal = JurnalHarian(
                        id: jurnal?.id,
                        tanggal: _formatDate(_selectedDate),
                        mood: selectedMood,
                        catatan: catatanController.text.trim(),
                        syukur: syukurController.text.trim().isEmpty ? null : syukurController.text.trim(),
                        evaluasi: evaluasiController.text.trim().isEmpty ? null : evaluasiController.text.trim(),
                      );

                      if (isEdit) {
                        await widget.jurnalRepository.updateJurnal(newJurnal);
                      } else {
                        await widget.jurnalRepository.insertJurnal(newJurnal);
                      }
                      Navigator.pop(context);
                      _loadJurnal();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C6758),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    isEdit ? 'Simpan' : 'Tulis Jurnal',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF09201C), const Color(0xFF0B2B26)]
                : [const Color(0xFFF2F9F7), const Color(0xFFE2F0EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jurnal Ibadah',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Text(
                      'Catatan Harian',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Date Timeline Selector
              _buildDateTimeline(theme),

              // Jurnal Body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _jurnalEntries.isEmpty
                        ? _buildEmptyState(theme, isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _jurnalEntries.length,
                            itemBuilder: (context, index) {
                              return JurnalCardWidget(
                                theme: theme,
                                jurnal: _jurnalEntries[index],
                                isDark: isDark,
                                onEdit: () => _showAddEditJurnalDialog(jurnal: _jurnalEntries[index]),
                                onDelete: () => _deleteJurnal(_jurnalEntries[index].id!),
                                moodMap: _moodMap,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _jurnalEntries.isEmpty && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditJurnalDialog(),
              backgroundColor: const Color(0xFF1C6758),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
              label: const Text('Tulis Jurnal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
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
                        colors: [Color(0xFF1C6758), Color(0xFF0E4338)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !isSelected
                    ? (isDark ? const Color(0xFF133630) : Colors.white)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0E4338).withOpacity(0.4),
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
                      : (isDark ? const Color(0xFF1C4F46) : Colors.black12),
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

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    final formatedTextDate = DateFormat('dd MMMM yyyy').format(_selectedDate);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.draw_rounded,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'Jurnal Kosong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu belum menulis jurnal ibadah untuk tanggal $formatedTextDate.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
