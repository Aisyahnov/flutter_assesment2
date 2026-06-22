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
        child: Stack(
          children: [
            // Background Decoration (Drawing / CustomPaint)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: JurnalDecorationPainter(isDark: isDark),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header of card (Mood & Instruction)
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 12, 12),
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
              padding: const EdgeInsets.fromLTRB(36, 20, 20, 20),
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
        ), // end Column
          ],
        ), // end Stack
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

// Tambahan fitur Drawing (CustomPaint) untuk dipresentasikan!
class JurnalDecorationPainter extends CustomPainter {
  final bool isDark;

  JurnalDecorationPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Menggambar ring binder (buku spiral) di pinggir kiri jurnal

    // Warna lubang kertas (menyamakan dengan warna background scaffold)
    final holePaint = Paint()
      ..color = isDark ? const Color(0xFF09201C) : const Color(0xFFF2F9F7)
      ..style = PaintingStyle.fill;
      
    // Warna besi spiral
    final ringPaint = Paint()
      ..color = isDark ? Colors.grey[700]! : Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final ringHighlight = Paint()
      ..color = isDark ? Colors.grey[500]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    int numberOfRings = 5;
    double startY = 30.0;
    double endY = size.height - 30.0;
    double spacing = (endY - startY) / (numberOfRings - 1);

    for (int i = 0; i < numberOfRings; i++) {
      double y = startY + (i * spacing);
      
      // 1. Gambar lubang kertas
      canvas.drawCircle(Offset(16, y), 5.5, holePaint);
      
      // 2. Gambar besi spiral yang melengkung masuk ke lubang
      Path ringPath = Path();
      ringPath.moveTo(0, y - 4);
      ringPath.quadraticBezierTo(16, y - 8, 16, y);
      ringPath.quadraticBezierTo(16, y + 8, 0, y + 4);
      
      canvas.drawPath(ringPath, ringPaint);
      canvas.drawPath(ringPath, ringHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
