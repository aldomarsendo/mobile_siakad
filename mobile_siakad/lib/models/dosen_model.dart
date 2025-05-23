class Dosen {
  final int idDosen;
  final int userId;
  final String nidn;
  final String name;
  final String email;
  final bool isDosenWali;
  final String createdAt;
  final String updatedAt;

  Dosen({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.name,
    required this.email,
    required this.isDosenWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      idDosen: json['id_dosen'] ?? 0,
      userId: json['user_id'] ?? 0,
      nidn: json['nidn']?.toString() ?? '',
      name: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isDosenWali: (json['is_dosen_wali'] == 1 || json['is_dosen_wali'] == true),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'user_id': userId,
      'nidn': nidn,
      'name': name,
      'email': email,
      'is_dosen_wali': isDosenWali,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  } 
}
