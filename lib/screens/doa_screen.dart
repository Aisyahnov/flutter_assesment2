import 'package:flutter/material.dart';
import '../models/koleksi_doa.dart';
import '../repositories/doa_repository.dart';

class DoaScreen extends StatefulWidget {
  final DoaRepository doaRepository;

  const DoaScreen({
    super.key,
    required this.doaRepository,
  });

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<KoleksiDoa> _allDoa = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadDoa();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoa() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await widget.doaRepository.getAllDoa();
      setState(() {
        _allDoa = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(KoleksiDoa doa) async {
    final newFavorit = doa.isFavorite ? 0 : 1;
    await widget.doaRepository.toggleFavorit(doa.id!, newFavorit == 1);
    _loadDoa();
  }

  Future<void> _deleteDoa(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Doa?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin menghapus doa ini secara permanen?'),
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
      await widget.doaRepository.deleteDoa(id);
      _loadDoa();
    }
  }

  void _showAddEditDoaDialog({KoleksiDoa? doa}) {
    final isEdit = doa != null;
    final judulController = TextEditingController(text: doa?.judul ?? '');
    final isiController = TextEditingController(text: doa?.isiDoa ?? '');
    final terjemahanController = TextEditingController(text: doa?.terjemahan ?? '');
    final kategoriController = TextEditingController(text: doa?.kategori ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEdit ? 'Edit Doa/Dzikir' : 'Tambah Doa/Dzikir',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: judulController,
                    decoration: InputDecoration(
                      labelText: 'Judul Doa/Dzikir *',
                      hintText: 'Misal: Doa Sebelum Makan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Judul wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: kategoriController,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      hintText: 'Misal: Harian, Perjalanan, Perlindungan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: isiController,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Isi Doa (Arab/Latin) *',
                      hintText: 'Tulis lafadz doa di sini...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Isi doa wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: terjemahanController,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Terjemahan / Arti',
                      hintText: 'Tulis arti doa di sini...',
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
                  final newDoa = KoleksiDoa(
                    id: doa?.id,
                    judul: judulController.text.trim(),
                    isiDoa: isiController.text.trim(),
                    terjemahan: terjemahanController.text.trim().isEmpty
                        ? null
                        : terjemahanController.text.trim(),
                    kategori: kategoriController.text.trim().isEmpty
                        ? 'Umum'
                        : kategoriController.text.trim(),
                    isFavorit: doa?.isFavorit ?? 0,
                  );

                  if (isEdit) {
                    await widget.doaRepository.updateDoa(newDoa);
                  } else {
                    await widget.doaRepository.insertDoa(newDoa);
                  }
                  Navigator.pop(context);
                  _loadDoa();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C6758),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                isEdit ? 'Simpan Perubahan' : 'Tambah',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<KoleksiDoa> _getFilteredList(bool onlyFavorite) {
    var list = onlyFavorite ? _allDoa.where((d) => d.isFavorite).toList() : _allDoa;
    if (_searchQuery.isNotEmpty) {
      list = list.where((d) {
        final query = _searchQuery.toLowerCase();
        return d.judul.toLowerCase().contains(query) ||
            d.isiDoa.toLowerCase().contains(query) ||
            (d.kategori?.toLowerCase().contains(query) ?? false) ||
            (d.terjemahan?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredAll = _getFilteredList(false);
    final filteredFav = _getFilteredList(true);

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
              // Search and Title Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Doa & Dzikir',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF133630) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                          color: isDark ? const Color(0xFF1C4F46) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Cari doa atau dzikir...',
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black45),
                          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black54),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF133630) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1C4F46) : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C6758), Color(0xFF0E4338)],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Semua Doa'),
                    Tab(text: 'Doa Favorit'),
                  ],
                ),
              ),

              // Tab Bar View
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildDoaList(filteredAll, isDark, theme, false),
                          _buildDoaList(filteredFav, isDark, theme, true),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDoaDialog(),
        backgroundColor: const Color(0xFF1C6758),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDoaList(List<KoleksiDoa> list, bool isDark, ThemeData theme, bool isFavTab) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFavTab ? Icons.favorite_border_rounded : Icons.menu_book_rounded,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 16),
              Text(
                isFavTab
                    ? (_searchQuery.isNotEmpty ? 'Doa favorit tidak ditemukan' : 'Belum ada doa favorit')
                    : (_searchQuery.isNotEmpty ? 'Doa tidak ditemukan' : 'Koleksi doa kosong'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFavTab
                    ? 'Tandai doa dengan ikon hati untuk memasukannya ke daftar favorit.'
                    : 'Tambahkan doa baru dengan menekan tombol "+" di bawah kanan.',
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final doa = list[index];
        return _buildDoaCard(doa, isDark, theme);
      },
    );
  }

  Widget _buildDoaCard(KoleksiDoa doa, bool isDark, ThemeData theme) {
    final bool isFav = doa.isFavorite;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF133630) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF1C4F46) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        key: PageStorageKey<int>(doa.id!),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF1C6758).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF1C6758),
              size: 20,
            ),
          ),
        ),
        title: Text(
          doa.judul,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Wrap(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C6758).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1C6758).withOpacity(0.2)),
                ),
                child: Text(
                  doa.kategori ?? 'Umum',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF1C6758), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : (isDark ? Colors.white38 : Colors.black38),
                size: 24,
              ),
              onPressed: () => _toggleFavorite(doa),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white54 : Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddEditDoaDialog(doa: doa);
                } else if (value == 'delete') {
                  _deleteDoa(doa.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Doa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A221E).withOpacity(0.3) : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 20),
                const SizedBox(height: 8),
                // Arab Text
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    doa.isiDoa,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'NotoSansArabic', // Fallback, uses default system Arabic font
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                    ),
                  ),
                ),
                if (doa.terjemahan != null && doa.terjemahan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Artinya:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doa.terjemahan!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
