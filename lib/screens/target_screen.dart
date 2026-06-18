import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/target_ibadah.dart';
import '../repositories/target_repository.dart';
import '../widgets/target_card_widget.dart';

class TargetScreen extends StatefulWidget {
  final TargetRepository targetRepository;

  const TargetScreen({
    super.key,
    required this.targetRepository,
  });

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  DateTime _selectedDate = DateTime.now();
  List<TargetIbadah> _targets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadTargets() async {
    setState(() {
      _isLoading = true;
    });
    final dateStr = _formatDate(_selectedDate);
    final targets = await widget.targetRepository.getTargetByTanggal(dateStr);
    setState(() {
      _targets = targets;
      _isLoading = false;
    });
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadTargets();
  }

  Future<void> _incrementProgress(TargetIbadah target) async {
    if (target.progress >= target.targetHarian) return;

    final newProgress = target.progress + 1;
    await widget.targetRepository.updateProgress(target.id!, newProgress);
    _loadTargets();
  }

  Future<void> _decrementProgress(TargetIbadah target) async {
    if (target.progress <= 0) return;

    final newProgress = target.progress - 1;
    await widget.targetRepository.updateProgress(target.id!, newProgress);
    _loadTargets();
  }

  Future<void> _deleteTarget(int id) async {
    await widget.targetRepository.deleteTarget(id);
    _loadTargets();
  }

  void _showAddEditTargetDialog({TargetIbadah? target}) {
    final isEdit = target != null;
    final nameController = TextEditingController(text: target?.namaTarget ?? '');
    final jenisController = TextEditingController(text: target?.jenis ?? 'Harian');
    final targetHarianController = TextEditingController(text: target?.targetHarian.toString() ?? '1');
    final satuanController = TextEditingController(text: target?.satuan ?? 'Kali');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isEdit ? 'Edit Target Ibadah' : 'Tambah Target Baru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Target Ibadah',
                      hintText: 'Misal: Tilawah Al-Qur\'an',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama target tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jenisController,
                    decoration: InputDecoration(
                      labelText: 'Jenis Ibadah',
                      hintText: 'Misal: Wajib, Sunnah, Harian',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Jenis ibadah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: targetHarianController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Target Jumlah',
                            hintText: 'Misal: 10',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            final n = int.tryParse(val);
                            if (n == null || n <= 0) {
                              return 'Harus > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: satuanController,
                          decoration: InputDecoration(
                            labelText: 'Satuan',
                            hintText: 'Halaman/Kali',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
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
                  final newTarget = TargetIbadah(
                    id: target?.id,
                    namaTarget: nameController.text.trim(),
                    jenis: jenisController.text.trim(),
                    targetHarian: int.parse(targetHarianController.text.trim()),
                    progress: isEdit ? target.progress : 0,
                    satuan: satuanController.text.trim(),
                    tanggal: isEdit ? target.tanggal : _formatDate(_selectedDate),
                  );

                  if (isEdit) {
                    await widget.targetRepository.updateTarget(newTarget);
                  } else {
                    await widget.targetRepository.insertTarget(newTarget);
                  }
                  
                  Navigator.pop(context);
                  _loadTargets();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C6758),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                isEdit ? 'Simpan' : 'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Harian',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          'Ibadah Kustom',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Counter target selesai
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C4F46) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1C6758).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: isDark ? Colors.purpleAccent : const Color(0xFF1C6758),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_targets.where((t) => t.isCompleted).length}/${_targets.length} Selesai',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.purpleAccent : const Color(0xFF1C6758),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Date Timeline Selector
              _buildDateTimeline(theme),

              // Target Items List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _targets.isEmpty
                        ? _buildEmptyState(theme, isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _targets.length,
                            itemBuilder: (context, index) {
                              return TargetCardWidget(
                                theme: theme,
                                target: _targets[index],
                                isDark: isDark,
                                onEdit: () => _showAddEditTargetDialog(target: _targets[index]),
                                onDelete: () => _deleteTarget(_targets[index].id!),
                                onIncrement: () => _incrementProgress(_targets[index]),
                                onDecrement: () => _decrementProgress(_targets[index]),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTargetDialog(),
        backgroundColor: const Color(0xFF1C6758),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada Target Ibadah',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Klik tombol "+" di kanan bawah untuk membuat target ibadah khusus Anda hari ini.',
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
