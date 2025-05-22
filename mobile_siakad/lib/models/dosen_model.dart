class Dosen {
  final int idDosen;
  final int userId;
  final String nidn;
  final bool isDosenWali;
  final String createdAt;
  final String updatedAt;

  Dosen({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.isDosenWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      idDosen: json['id_dosen'],
      userId: json['user_id'],
      nidn: json['nidn'],
      isDosenWali: json['is_dosen_wali'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
