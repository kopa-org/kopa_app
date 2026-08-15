import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_fine_type_command.dart';
import 'package:kopa/model/create_user_fine_command.dart';
import 'package:kopa/model/create_user_fines_command.dart';
import 'package:kopa/model/deposit_amount_to_fine_box_command.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_type_details.dart';

class FinesRepository {
  static final _secureStorage = FlutterSecureStorage();
  static Future<List<FineTypeDetails>> getFineTypes() async {
    final token = await _secureStorage.read(key: 'token');

    var url = Uri.parse('${ApiConfig.baseUrl}/fine/types');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch fine types');
    }

    Iterable json = jsonDecode(response.body)['types'];

    return List<FineTypeDetails>.from(
        json.map((content) => FineTypeDetails.fromJson(content)));
  }

  static Future<FineBoxDetails> getFineBox() async {
    final token = await _secureStorage.read(key: 'token');
    var url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch fine box');
    }

    var json = jsonDecode(response.body)['fine_box'];

    return FineBoxDetails.fromJson(json);
  }

  static Future<bool> updateMobilePayBoxId(
    String mobilePayBoxId,
  ) async {
    final token = await _secureStorage.read(key: 'token');
    var url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box');

    var response = await http.patch(url, body: {
      'mobilepay_box_id': mobilePayBoxId,
    }, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to update MobilePay Box');
    }

    return true;
  }

  static Future<List<int>> addFineForUsers(
      List<CreateUserFineCommand> createUserFineCommands) async {
    final token = await _secureStorage.read(key: 'token');

    var url = Uri.parse('${ApiConfig.baseUrl}/fine/users');

    var createUserFinesCommand = CreateUserFinesCommand(createUserFineCommands);

    var response =
        await http.post(url, body: createUserFinesCommand.toJson(), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to add fine for user');
    }

    Iterable json = jsonDecode(response.body);

    return json.map((content) => content as int).toList();
  }

  static Future<bool> depositAmountToFineBox(
      int fineBoxId, String amountToDeposit, List<int> userFineIds) async {
    final token = await _secureStorage.read(key: 'token');
    var url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box/deposit');

    var depositAmountToFineBoxCommand = DepositAmountToFineBoxCommand(
        fineBoxId: fineBoxId.toString(),
        amountToDeposit: amountToDeposit,
        userFineIds: userFineIds.map((x) => x.toString()).toList());

    var response = await http
        .post(url, body: depositAmountToFineBoxCommand.toJson(), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to deposit amount to fine box');
    }

    return true;
  }

  static Future<bool> createFineType(String title, String defaultAmount) async {
    final token = await _secureStorage.read(key: 'token');
    var url = Uri.parse('${ApiConfig.baseUrl}/fine/type');

    var createFineTypeCommmand =
        CreateFineTypeCommand(title: title, defaultAmount: defaultAmount);

    var response =
        await http.post(url, body: createFineTypeCommmand.toJson(), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to create fine type');
    }

    return true;
  }
}
