class EventModel {
  String? id;
  String nama;
  DateTime tanggal;
  String lokasi;
  String? deskripsi;
  String kategori;
  DateTime? createdAt;

  EventModel({
    this.id,
    required this.nama,
    required this.tanggal,
    required this.lokasi,
    this.deskripsi,
    this.kategori = 'Umum',
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String?,
      nama: json['nama'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      lokasi: json['lokasi'] as String,
      deskripsi: json['deskripsi'] as String?,
      kategori: json['kategori'] as String? ?? 'Umum',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'tanggal': tanggal.toIso8601String(),
      'lokasi': lokasi,
      if (deskripsi != null) 'deskripsi': deskripsi,
      'kategori': kategori,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
