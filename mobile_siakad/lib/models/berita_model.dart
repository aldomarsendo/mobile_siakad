class Berita {
  final int id;
  final int userId;
  final String judul;
  final String slug;
  final String isi;
  final String? gambarUrl;
  final String targetRole;
  final String status;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Berita({
    required this.id,
    required this.userId,
    required this.judul,
    required this.slug,
    required this.isi,
    this.gambarUrl,
    required this.targetRole,
    required this.status,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      judul: json['judul'] ?? '',
      slug: json['slug'] ?? '',
      isi: json['isi'] ?? '',
      gambarUrl: json['gambar_url'],
      targetRole: json['target_role'] ?? '',
      status: json['status'] ?? '',
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'slug': slug,
      'isi': isi,
      'gambar_url': gambarUrl,
      'target_role': targetRole,
      'status': status,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BeritaResponse {
  final List<Berita> data;
  final int currentPage;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;
  final String message;

  BeritaResponse({
    required this.data,
    required this.currentPage,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
    required this.message,
  });

  factory BeritaResponse.fromJson(Map<String, dynamic> json) {
    final beritaData = json['berita'] ?? {};
    
    return BeritaResponse(
      data: (beritaData['data'] as List<dynamic>?)
          ?.map((item) => Berita.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currentPage: beritaData['current_page'] ?? 1,
      firstPageUrl: beritaData['first_page_url'] ?? '',
      from: beritaData['from'] ?? 0,
      lastPage: beritaData['last_page'] ?? 1,
      lastPageUrl: beritaData['last_page_url'] ?? '',
      nextPageUrl: beritaData['next_page_url'],
      path: beritaData['path'] ?? '',
      perPage: beritaData['per_page'] ?? 10,
      prevPageUrl: beritaData['prev_page_url'],
      to: beritaData['to'] ?? 0,
      total: beritaData['total'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}