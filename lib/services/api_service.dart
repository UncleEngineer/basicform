import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visitor_entry.dart';

class ApiService {
  // เปลี่ยน URL นี้ให้ตรงกับ IP ของเครื่อง Server
  static const String baseUrl = 'http://192.168.0.86:5000/api';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // สร้างรายการใหม่
  static Future<ApiResponse> createEntry({
    required String licensePlate,
    required String houseNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: headers,
        body: json.encode({
          'license_plate': licensePlate,
          'house_number': houseNumber,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(error: data['error'] ?? 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      return ApiResponse(error: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  // ดึงรายการทั้งหมด
  static Future<ApiResponse> getEntries({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entries?page=$page&per_page=$perPage'),
        headers: headers,
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(error: data['error'] ?? 'ไม่สามารถดึงข้อมูลได้');
      }
    } catch (e) {
      return ApiResponse(error: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  // ค้นหารายการ
  static Future<ApiResponse> searchEntries({
    String? licensePlate,
    String? houseNumber,
  }) async {
    try {
      String queryParams = '';
      List<String> params = [];

      if (licensePlate != null && licensePlate.isNotEmpty) {
        params.add('license_plate=$licensePlate');
      }
      if (houseNumber != null && houseNumber.isNotEmpty) {
        params.add('house_number=$houseNumber');
      }

      if (params.isNotEmpty) {
        queryParams = '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/search$queryParams'),
        headers: headers,
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(error: data['error'] ?? 'ไม่สามารถค้นหาได้');
      }
    } catch (e) {
      return ApiResponse(error: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  // ลบรายการ
  static Future<ApiResponse> deleteEntry(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/entries/$id'),
        headers: headers,
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(error: data['error'] ?? 'ไม่สามารถลบได้');
      }
    } catch (e) {
      return ApiResponse(error: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  // ตรวจสอบสถานะ API
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
