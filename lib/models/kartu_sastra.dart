class KartuSastra {
  final int id;
  final String nama;
  final String pelafalan;
  final String voiceNote;
  final String gambar;
  final String keterangan;

  KartuSastra({
    required this.id,
    required this.nama,
    required this.pelafalan,
    required this.voiceNote,
    required this.gambar,
    required this.keterangan,
  });

  factory KartuSastra.fromJson(Map<String, dynamic> json) {
    return KartuSastra(
      id: json['id'] as int,
      nama: json['nama'] as String,
      pelafalan: json['pelafalan'] as String,
      voiceNote: json['voiceNote'] as String,
      gambar: json['gambar'] as String,
      keterangan: json['keterangan'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'pelafalan': pelafalan,
      'voiceNote': voiceNote,
      'gambar': gambar,
      'keterangan': keterangan,
    };
  }
} 