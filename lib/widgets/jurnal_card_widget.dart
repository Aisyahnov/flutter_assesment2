import 'package:flutter/material.dart';
import '../models/jurnal_harian.dart';

class JurnalCardWidget extends StatelessWidget {
  final ThemeData theme;
  final JurnalHarian jurnal;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, String> moodMap;

  const JurnalCardWidget({
    Key? key,
    required this.theme,
    required this.jurnal,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.moodMap,
  }) : super(key: key);

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF133630) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF1C6758)),
                title: Text(
                  'Edit Jurnal',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text(
                  'Hapus Jurnal',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Long press gesture to reveal action menu
        _showActionMenu(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF133630) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF1C4F46) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header of card (Mood & Instruction)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C6758).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          jurnal.mood ?? '😇',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          moodMap[jurnal.mood] ?? 'Damai',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tahan Lama untuk Aksi',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const Divider(height: 1),

            // Catatan Ibadah
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJurnalSection(
                    title: 'Catatan Ibadah',
                    content: jurnal.catatan,
                    icon: Icons.book_rounded,
                    iconColor: Colors.purpleAccent,
                    isDark: isDark,
                    theme: theme,
                  ),
                  if (jurnal.syukur != null && jurnal.syukur!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildJurnalSection(
                      title: 'Hal yang Disyukuri',
                      content: jurnal.syukur!,
                      icon: Icons.favorite_rounded,
                      iconColor: Colors.redAccent,
                      isDark: isDark,
                      theme: theme,
                    ),
                  ],
                  if (jurnal.evaluasi != null && jurnal.evaluasi!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildJurnalSection(
                      title: 'Evaluasi & Target Esok',
                      content: jurnal.evaluasi!,
                      icon: Icons.insights_rounded,
                      iconColor: Colors.blueAccent,
                      isDark: isDark,
                      theme: theme,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJurnalSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
