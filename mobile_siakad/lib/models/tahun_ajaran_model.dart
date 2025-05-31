// lib/models/tahun_ajaran_model.dart

String? _parseStringSafe(dynamic value) {
  if (value == null) return null;
  if (value is String && value.toLowerCase() == 'null') return null;
  return value.toString();
}

int _parseIntSafe(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) {
    if (value.toLowerCase() == 'null') return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  if (value is double) return value.toInt();
  return defaultValue;
}

class TahunAjaranItem {
  final int idTahunAjaran; // Sesuaikan dengan nama field ID dari API Anda
  final String namaTahunAjaran;

  TahunAjaranItem({
    required this.idTahunAjaran,
    required this.namaTahunAjaran,
  });

  factory TahunAjaranItem.fromJson(Map<String, dynamic> json) {
    return TahunAjaranItem(
      // Sesuaikan 'id_tahun_ajaran' dengan key ID dari API Anda
      idTahunAjaran: _parseIntSafe(json['id_tahun_ajaran'] ?? json['id']), 
      namaTahunAjaran: _parseStringSafe(json['nama_tahun_ajaran']) ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_tahun_ajaran': idTahunAjaran,
        'nama_tahun_ajaran': namaTahunAjaran,
      };

  @override
  String toString() {
    return 'TahunAjaranItem(id: $idTahunAjaran, nama: $namaTahunAjaran)';
  }

  // Override equals and hashCode jika objek ini akan digunakan sebagai value di DropdownButton
  // dan Anda ingin membandingkan objeknya, bukan hanya ID.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TahunAjaranItem &&
          runtimeType == other.runtimeType &&
          idTahunAjaran == other.idTahunAjaran;

  @override
  int get hashCode => idTahunAjaran.hashCode;
}

class ApiTahunAjaranResponse {
  final List<TahunAjaranItem> tahunAjaranList;
  final String message;

  ApiTahunAjaranResponse({
    required this.tahunAjaranList,
    required this.message,
  });

  factory ApiTahunAjaranResponse.fromJson(Map<String, dynamic> json) {
    var list = json['tahun_ajaran'] as List? ?? json['data'] as List? ?? []; // Sesuaikan key 'tahun_ajaran' atau 'data'
    List<TahunAjaranItem> items = list
        .map((i) => TahunAjaranItem.fromJson(i as Map<String, dynamic>))
        .toList();
    return ApiTahunAjaranResponse(
      tahunAjaranList: items,
      message: _parseStringSafe(json['message']) ?? '',
    );
  }
}
