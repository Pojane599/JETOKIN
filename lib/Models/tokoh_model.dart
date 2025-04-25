class Tokoh {
  final int id;
  final String name;
  final String? ascencionDocumentNumber;
  final String? ascencionDocumentDate;
  final int? ascencionYear;
  final String? zamanPerjuangan;
  final String? bidangPerjuangan;
  final String? photoUrl;
  final String? birthDate;
  final String? birthPlace;
  final String? deathDate;
  final String? deathPlace;
  final String? burialPlace;
  final String? description;

  Tokoh({
    required this.id,
    required this.name,
    this.ascencionDocumentNumber,
    this.ascencionDocumentDate,
    this.ascencionYear,
    this.zamanPerjuangan,
    this.bidangPerjuangan,
    this.photoUrl,
    this.birthDate,
    this.birthPlace,
    this.deathDate,
    this.deathPlace,
    this.burialPlace,
    this.description,
  });

  // Factory untuk parsing JSON ke model Tokoh
  factory Tokoh.fromJson(Map<String, dynamic> json) {
    return Tokoh(
      id: json['id'],
      name: json['name'],
      ascencionDocumentNumber: json['ascencion_document_number'],
      ascencionDocumentDate: json['ascencion_document_date'],
      ascencionYear: json['ascencion_year'],
      zamanPerjuangan: json['zaman_perjuangan'],
      bidangPerjuangan: json['bidang_perjuangan'],
      photoUrl: json['photo_url'],
      birthDate: json['birth_date'],
      birthPlace: json['birth_place'],
      deathDate: json['death_date'],
      deathPlace: json['death_place'],
      burialPlace: json['burial_place'],
      description: json['description'],
    );
  }

  // Method untuk mengonversi model ke Map (jika diperlukan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ascencion_document_number': ascencionDocumentNumber,
      'ascencion_document_date': ascencionDocumentDate,
      'ascencion_year': ascencionYear,
      'zaman_perjuangan': zamanPerjuangan,
      'bidang_perjuangan': bidangPerjuangan,
      'photo_url': photoUrl,
      'birth_date': birthDate,
      'birth_place': birthPlace,
      'death_date': deathDate,
      'death_place': deathPlace,
      'burial_place': burialPlace,
      'description': description,
    };
  }
}
