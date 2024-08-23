import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/detail_transaction_model.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class Api {
  static const String baseUrl = 'https://rumahraga.com/mitra/';
  static const String gambarUrl = 'http://rumahraga.com/rumah_raga/';

  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static String getImageUrl(String fileName) {
    return '$gambarUrl/data/fields/$fileName';
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset_password.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<void> updateStatusMitra(int mitraId, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_status_mitra.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mitra_id': mitraId, 'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('Status updated successfully');
        } else {
          throw Exception('Failed to update status: ${data['message']}');
        }
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  static Future<double> getPenghasilan(int mitraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_penghasilan.php?mitraId=$mitraId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      double income = double.parse(data['income'].toString());
      return income;
    } else {
      throw Exception('Failed to load income');
    }
  }

  static Future<Map<String, dynamic>> addLapangan(Map<String, dynamic> data,
      {File? image}) async {
    final url = Uri.parse('$baseUrl/add_lapangan.php');

    final request = http.MultipartRequest('POST', url);

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (image != null) {
      final fileName = path.basename(image.path);
      request.files.add(await http.MultipartFile.fromPath('image', image.path,
          filename: fileName));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } else {
      print('Error: ${response.statusCode} - ${responseData}');
      throw Exception('Failed to add field');
    }
  }

  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<dynamic>> fetchCities() async {
    final response = await http.get(Uri.parse('$baseUrl/get_cities.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cities');
    }
  }

  static Future<List<dynamic>> getFieldsByMitraId(String mitraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/fields.php?mitra_id=$mitraId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load fields');
    }
  }

  static Future<Map<String, dynamic>> updateField(
      Map<String, dynamic> updateData, File? imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/update_field.php'));

    updateData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to update field');
    }
  }

  static Future<Map<String, dynamic>> deleteField(int idField) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_field.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'field_id': idField}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete field');
    }
  }

  static Future<Map<String, dynamic>> getFieldById(int fieldId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_field_by_id.php?id=$fieldId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load field data');
    }
  }

  static Future<List<dynamic>> getTransactionsByMitraId(int? idMitra) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mitra_id': idMitra}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<void> updateTransactionStatus({
    required String transaction_code,
    required int new_status,
  }) async {
    final url = Uri.parse('$baseUrl/update_transaction_status.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transaction_code': transaction_code,
        'new_status': new_status,
      }),
    );

    if (response.statusCode == 200) {
      print('Transaction status updated successfully');
    } else {
      throw Exception('Failed to update transaction status');
    }
  }

  static Future<void> insertDetailTransaction(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/insert_detail_transaction.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Detail transaction inserted successfully');
    } else {
      throw Exception('Failed to insert detail transaction');
    }
  }

  static Future<List<DetailTransaction>> getDetailTransactionsByMitraId(
      int mitraId) async {
    final url =
        Uri.parse('$baseUrl/get_detail_transactions.php?mitra_id=$mitraId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => DetailTransaction.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load detail transactions');
    }
  }

  static Future<List<dynamic>> fetchTransactions(int mitraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transaction_details.php?mitra_id=$mitraId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(int mitraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_user_profile.php?mitra_id=$mitraId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  static Future<List<dynamic>> getJamByFieldId(int fieldId, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_booking_times.php?date=$date&field_id=$fieldId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load jams');
    }
  }

  static Future<List<dynamic>> getOrderDateByFieldId(int fieldId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_order_date.php?field_id=$fieldId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order dates');
    }
  }

  static Future<List<dynamic>> getAvailableJams() async {
    final response = await http.get(Uri.parse('$baseUrl/jam.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load jams');
    }
  }
}
