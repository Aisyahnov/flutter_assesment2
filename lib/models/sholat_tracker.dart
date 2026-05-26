class SholatTracker {
  final int? id;
  final String tanggal; // YYYY-MM-DD
  final String waktu; // e.g. Subuh, Dzuhur, Ashar, Maghrib, Isya
  final String status; // 'belum', 'selesai'
  final String? catatan;
  final String? createdAt;

  SholatTracker({
    this.id,
    required this.tanggal,
    required this.waktu,
    this.status = 'belum',
    this.catatan,
    this.createdAt,
  });

  SholatTracker copyWith({
    int? id,
    String? tanggal,
    String? waktu,
    String? status,
    String? catatan,
    String? createdAt,
  }) {
    return SholatTracker(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'status': status,
      'catatan': catatan,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory SholatTracker.fromMap(Map<String, dynamic> map) {
    return SholatTracker(
      id: map['id'],
      tanggal: map['tanggal'] ?? '',
      waktu: map['waktu'] ?? '',
      status: map['status'] ?? 'belum',
      catatan: map['catatan'],
      createdAt: map['created_at'],
    );
  }
}
