class JurnalHarian {
  final int? id;
  final String tanggal; // YYYY-MM-DD
  final String? mood; // e.g. 😀, 😐, 😔, 😡
  final String catatan;
  final String? syukur;
  final String? evaluasi;
  final String? createdAt;

  JurnalHarian({
    this.id,
    required this.tanggal,
    this.mood,
    required this.catatan,
    this.syukur,
    this.evaluasi,
    this.createdAt,
  });

  JurnalHarian copyWith({
    int? id,
    String? tanggal,
    String? mood,
    String? catatan,
    String? syukur,
    String? evaluasi,
    String? createdAt,
  }) {
    return JurnalHarian(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      mood: mood ?? this.mood,
      catatan: catatan ?? this.catatan,
      syukur: syukur ?? this.syukur,
      evaluasi: evaluasi ?? this.evaluasi,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tanggal': tanggal,
      'mood': mood,
      'catatan': catatan,
      'syukur': syukur,
      'evaluasi': evaluasi,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory JurnalHarian.fromMap(Map<String, dynamic> map) {
    return JurnalHarian(
      id: map['id'],
      tanggal: map['tanggal'] ?? '',
      mood: map['mood'],
      catatan: map['catatan'] ?? '',
      syukur: map['syukur'],
      evaluasi: map['evaluasi'],
      createdAt: map['created_at'],
    );
  }
}
