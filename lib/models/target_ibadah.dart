class TargetIbadah {
  final int? id;
  final String namaTarget;
  final String jenis;
  final int targetHarian;
  final int progress;
  final String satuan;
  final String tanggal; // YYYY-MM-DD
  final int isSelesai;
  final String? createdAt;

  bool get isCompleted => isSelesai == 1;

  TargetIbadah({
    this.id,
    required this.namaTarget,
    required this.jenis,
    required this.targetHarian,
    this.progress = 0,
    required this.satuan,
    required this.tanggal,
    this.isSelesai = 0,
    this.createdAt,
  });

  TargetIbadah copyWith({
    int? id,
    String? namaTarget,
    String? jenis,
    int? targetHarian,
    int? progress,
    String? satuan,
    String? tanggal,
    int? isSelesai,
    String? createdAt,
  }) {
    return TargetIbadah(
      id: id ?? this.id,
      namaTarget: namaTarget ?? this.namaTarget,
      jenis: jenis ?? this.jenis,
      targetHarian: targetHarian ?? this.targetHarian,
      progress: progress ?? this.progress,
      satuan: satuan ?? this.satuan,
      tanggal: tanggal ?? this.tanggal,
      isSelesai: isSelesai ?? this.isSelesai,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_target': namaTarget,
      'jenis': jenis,
      'target_harian': targetHarian,
      'progress': progress,
      'satuan': satuan,
      'tanggal': tanggal,
      'is_selesai': isSelesai,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory TargetIbadah.fromMap(Map<String, dynamic> map) {
    return TargetIbadah(
      id: map['id'],
      namaTarget: map['nama_target'] ?? '',
      jenis: map['jenis'] ?? '',
      targetHarian: map['target_harian'] ?? 1,
      progress: map['progress'] ?? 0,
      satuan: map['satuan'] ?? '',
      tanggal: map['tanggal'] ?? '',
      isSelesai: map['is_selesai'] ?? 0,
      createdAt: map['created_at'],
    );
  }
}
