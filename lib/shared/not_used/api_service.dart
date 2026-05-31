// import 'dart:io';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
//
// class ApiService {
//   static String get baseUrl {
//     if (Platform.isAndroid) return 'http://10.0.2.2:8000';
//     return 'http://localhost:8000';
//   }
//
//   static String? loginToken;
//
//   static void setToken(String token) {
//     loginToken = token;
//   }
//
//   static void clearToken() {
//     loginToken = null;
//   }
//
//   static Map<String, String> get headers => {
//     'Content-Type': 'application/json',
//     if (loginToken != null) 'Authorization': 'Bearer $loginToken',
//   };
//
//   static Future<Map<String, dynamic>> get(String endpoint) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//     );
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('GET $endpoint failed: ${response.statusCode}');
//     }
//     return jsonDecode(response.body);
//   }
//
//   static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//       body: jsonEncode(body),
//     );
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('POST $endpoint failed: ${response.statusCode}');
//     }
//     return jsonDecode(response.body);
//   }
//
//   static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
//     final response = await http.patch(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//       body: jsonEncode(body),
//     );
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('PATCH $endpoint failed: ${response.statusCode}');
//     }
//     return jsonDecode(response.body);
//   }
//
//   static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//       body: jsonEncode(body),
//     );
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('PUT $endpoint failed: ${response.statusCode}');
//     }
//     return jsonDecode(response.body);
//   }
//
//   static Future<Map<String, dynamic>> delete(String endpoint) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//     );
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('DELETE $endpoint failed: ${response.statusCode}');
//     }
//     return jsonDecode(response.body);
//   }
//
//   static Future<Map<String, dynamic>> uploadImage(String endpoint, String filePath) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl$endpoint'),
//     );
//
//     if (loginToken != null) {
//       request.headers['Authorization'] = 'Bearer $loginToken';
//     }
//
//     request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
//
//     final streamed = await request.send();
//     final response = await http.Response.fromStream(streamed);
//
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('UPLOAD $endpoint failed: ${response.statusCode}');
//     }
//
//     return jsonDecode(response.body);
//   }
// }