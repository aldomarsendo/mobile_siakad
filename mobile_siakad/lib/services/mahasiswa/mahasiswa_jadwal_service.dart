import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart';
import 'package:mobile_siakad/services/api_client.dart';

class MahasiswaJadwalService {
  final ApiClient _apiClient;

  MahasiswaJadwalService(this._apiClient);

  Future<List<MahasiswaJadwalItem>> getJadwalLengkap({String? semester}) async {
    try {
      print('=== SERVICE (MahasiswaJadwalService - getJadwalLengkap): Mengambil data ===');
      String endpoint = 'mahasiswa/jadwal';
      
      if (semester != null && semester.isNotEmpty) {
        endpoint += '?semester=${Uri.encodeQueryComponent(semester)}';
      }
      print('SERVICE: Endpoint getJadwalLengkap: $endpoint');

      // The _apiClient.get() can return Map, List, or null.
      final dynamic responseData = await _apiClient.get(endpoint);

      if (responseData == null) {
        print('SERVICE (getJadwalLengkap): Response API kosong');
        return [];
      }

      print('SERVICE (getJadwalLengkap): Raw response: $responseData');
      List<MahasiswaJadwalItem> allJadwal = [];
      
      // Define possible day keys for later check if response is a direct map of days
      const possibleDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

      // Case 1: Response is a Map
      if (responseData is Map) {
        // Ensure it's Map<String, dynamic> for easier handling
        final Map<String, dynamic> dataMap = Map<String, dynamic>.from(responseData);

        // Subcase 1.1: Structure is {"jadwal": {"Senin": [...], "Selasa": [...]}}
        if (dataMap.containsKey('jadwal') && dataMap['jadwal'] is Map) {
          final Map<String, dynamic> jadwalHariMap = Map<String, dynamic>.from(dataMap['jadwal'] as Map);
          jadwalHariMap.forEach((hari, jadwalListJson) {
            if (jadwalListJson is List) {
              for (var itemJson in jadwalListJson) {
                try {
                  // Ensure itemJson is a Map before parsing
                  if (itemJson is Map) {
                     final jadwalItem = MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(itemJson));
                     allJadwal.add(jadwalItem);
                  } else {
                     print('SERVICE: Skipping non-map item in jadwal list (type 1.1): $itemJson');
                  }
                } catch (e) {
                  print('SERVICE: Error parsing jadwal item (type 1.1): $itemJson, error: $e');
                }
              }
            }
          });
        }
        // Subcase 1.2: Structure is {"jadwal": [...]} (array directly under "jadwal" key)
        else if (dataMap.containsKey('jadwal') && dataMap['jadwal'] is List) {
          final List jadwalList = dataMap['jadwal'] as List;
          for (var itemJson in jadwalList) {
            try {
              if (itemJson is Map) {
                final jadwalItem = MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(itemJson));
                allJadwal.add(jadwalItem);
              } else {
                print('SERVICE: Skipping non-map item in jadwal list (type 1.2): $itemJson');
              }
            } catch (e) {
              print('SERVICE: Error parsing jadwal item (type 1.2): $itemJson, error: $e');
            }
          }
        }
        // Subcase 1.3: Structure is a direct map of days {"Senin": [...]} OR a single schedule item as a map
        else {
            // Check if the keys of dataMap are day names
            bool isDirectDayMap = dataMap.keys.any((key) => possibleDays.contains(key.toString()));

            if (isDirectDayMap) { // e.g. {"Senin": [...], "Selasa": [...]}
                 dataMap.forEach((hari, jadwalListJson) {
                    if (jadwalListJson is List) {
                        for (var itemJson in jadwalListJson) {
                            try {
                                if (itemJson is Map) {
                                    final jadwalItem = MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(itemJson));
                                    allJadwal.add(jadwalItem);
                                } else {
                                    print('SERVICE: Skipping non-map item in direct day map (type 1.3a): $itemJson');
                                }
                            } catch (e) {
                                print('SERVICE: Error parsing jadwal item (type 1.3a): $itemJson, error: $e');
                            }
                        }
                    }
                 });
            } else { // Assume dataMap itself is a single jadwal item if no 'jadwal' key and not a day map
                try {
                    final jadwalItem = MahasiswaJadwalItem.fromJson(dataMap);
                    allJadwal.add(jadwalItem);
                } catch (e) {
                    print('SERVICE: Error parsing single jadwal item from map (type 1.3b): $dataMap, error: $e');
                }
            }
        }
      }
      // Case 2: Response is a List (e.g. API returns [...] directly)
      else if (responseData is List) {
        for (var itemJson in responseData) {
          try {
            if (itemJson is Map) {
                final jadwalItem = MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(itemJson));
                allJadwal.add(jadwalItem);
            } else {
                print('SERVICE: Skipping non-map item in root list (type 2): $itemJson');
            }
          } catch (e) {
            print('SERVICE: Error parsing jadwal item from root list (type 2): $itemJson, error: $e');
          }
        }
      }
      // Case 3: Response format is not recognized
      else {
        print('SERVICE (getJadwalLengkap): Response API tidak dikenal formatnya: ${responseData.runtimeType}');
      }

      print('SERVICE (getJadwalLengkap): Total jadwal berhasil di-parse: ${allJadwal.length}');
      return allJadwal;

    } catch (e) {
      print('SERVICE (getJadwalLengkap): Terjadi kesalahan umum: ${e.toString()}');
      throw Exception('Gagal mengambil data jadwal lengkap: ${e.toString()}');
    }
  }

  Future<List<MahasiswaJadwalItem>> getJadwalHariIni() async {
    try {
      print('=== SERVICE (MahasiswaJadwalService - getJadwalHariIni): Mengambil data ===');
      const String endpoint = 'mahasiswa/dashboard/jadwal-hari-ini';
      print('SERVICE: Endpoint getJadwalHariIni: $endpoint');

      // Assuming _apiClient.get() can return Map or null
      final dynamic responseData = await _apiClient.get(endpoint);

      if (responseData == null || responseData is! Map) {
        print('SERVICE (getJadwalHariIni): Response API kosong atau tidak valid (expected Map)');
        return [];
      }
      
      // Ensure responseData is treated as Map<String, dynamic>
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(responseData);

      List<MahasiswaJadwalItem> jadwalHariIni = [];

      if (dataMap['jadwal_hari_ini'] != null && dataMap['jadwal_hari_ini'] is List) {
        final List jadwalJsonList = dataMap['jadwal_hari_ini'] as List;
        
        for (var jadwalJson in jadwalJsonList) {
          try {
            // Ensure jadwalJson is a Map before parsing
            if (jadwalJson is Map) {
              final jadwalItem = MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(jadwalJson));
              jadwalHariIni.add(jadwalItem);
            } else {
              print('SERVICE (getJadwalHariIni): Skipping non-map item in jadwal_hari_ini list: $jadwalJson');
            }
          } catch(e) {
            print('SERVICE (getJadwalHariIni): Error parsing item jadwal hari ini: $jadwalJson, error: $e');
          }
        }
      } else {
         print('SERVICE (getJadwalHariIni): "jadwal_hari_ini" key not found or not a list.');
      }

      print('SERVICE (getJadwalHariIni): Total jadwal hari ini setelah parsing: ${jadwalHariIni.length}');
      return jadwalHariIni;

    } catch (e) {
      print('SERVICE (getJadwalHariIni): Terjadi kesalahan: ${e.toString()}');
      throw Exception('Gagal mengambil jadwal hari ini: ${e.toString()}');
    }
  }
}
