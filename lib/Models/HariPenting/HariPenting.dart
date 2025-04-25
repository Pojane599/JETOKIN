class HariPenting {
  final String tanggal;
  final String namaHari;

  HariPenting({required this.tanggal, required this.namaHari});

  factory HariPenting.fromJson(Map<String, dynamic> json) {
    return HariPenting(
      tanggal: json['tanggal'],
      namaHari: json['nama_hari'],
    );
  }
  // Factory method untuk list dari JSON
  static List<HariPenting> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => HariPenting.fromJson(item)).toList();
  }
}