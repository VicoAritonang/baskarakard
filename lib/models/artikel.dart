class Artikel {
  final int id;
  final String judul;
  final String isi;
  final String gambar;

  Artikel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.gambar,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] as int,
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      gambar: json['gambar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'gambar': gambar,
    };
  }
}
