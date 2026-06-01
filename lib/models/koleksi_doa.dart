class KoleksiDoa {
  final int? id;
  final String judul;
  final String isiDoa;
  final String? terjemahan;
  final String? kategori;
  final int isFavorit; // 0 = false, 1 = true
  final String? createdAt;

  bool get isFavorite => isFavorit == 1;

  KoleksiDoa({
    this.id,
    required this.judul,
    required this.isiDoa,
    this.terjemahan,
    this.kategori,
    this.isFavorit = 0,
    this.createdAt,
  });

  KoleksiDoa copyWith({
    int? id,
    String? judul,
    String? isiDoa,
    String? terjemahan,
    String? kategori,
    int? isFavorit,
    String? createdAt,
  }) {
    return KoleksiDoa(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isiDoa: isiDoa ?? this.isiDoa,
      terjemahan: terjemahan ?? this.terjemahan,
      kategori: kategori ?? this.kategori,
      isFavorit: isFavorit ?? this.isFavorit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'isi_doa': isiDoa,
      'terjemahan': terjemahan,
      'kategori': kategori,
      'is_favorit': isFavorit,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory KoleksiDoa.fromMap(Map<String, dynamic> map) {
    return KoleksiDoa(
      id: map['id'],
      judul: map['judul'] ?? '',
      isiDoa: map['isi_doa'] ?? '',
      terjemahan: map['terjemahan'],
      kategori: map['kategori'],
      isFavorit: map['is_favorit'] ?? 0,
      createdAt: map['created_at'],
    );
  }
}
