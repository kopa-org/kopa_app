import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_fine_type_command.dart';
import 'package:kopa/model/create_user_fine_command.dart';
import 'package:kopa/model/create_user_fines_command.dart';
import 'package:kopa/model/deposit_amount_to_fine_box_command.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/services/api_client.dart';

class FinesRepository {
  static final _apiClient = ApiClient.shared;

  static Future<List<FineTypeDetails>> getFineTypes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/types');

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch fine types');
    }

    Iterable json = jsonDecode(response.body)['types'];

    return List<FineTypeDetails>.from(
        json.map((content) => FineTypeDetails.fromJson(content)));
  }

  static Future<FineBoxDetails> getFineBox() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box');

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch fine box');
    }

    var json = jsonDecode(response.body)['fine_box'];

    return FineBoxDetails.fromJson(json);
  }

  static Future<bool> updateMobilePayBoxId(
    String mobilePayBoxId,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box');

    final response = await _apiClient.patch(url, body: {
      'mobilepay_box_id': mobilePayBoxId,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to update MobilePay Box');
    }

    return true;
  }

  static Future<List<int>> addFineForUsers(
      List<CreateUserFineCommand> createUserFineCommands) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/users');

    var createUserFinesCommand = CreateUserFinesCommand(createUserFineCommands);

    final response = await _apiClient.post(
      url,
      body: createUserFinesCommand.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add fine for user');
    }

    Iterable json = jsonDecode(response.body);

    return json.map((content) => content as int).toList();
  }

  static Future<bool> depositAmountToFineBox(
      int fineBoxId, String amountToDeposit, List<int> userFineIds) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/fine_box/deposit');

    var depositAmountToFineBoxCommand = DepositAmountToFineBoxCommand(
        fineBoxId: fineBoxId.toString(),
        amountToDeposit: amountToDeposit,
        userFineIds: userFineIds.map((x) => x.toString()).toList());

    final response = await _apiClient.post(
      url,
      body: depositAmountToFineBoxCommand.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to deposit amount to fine box');
    }

    return true;
  }

  static Future<bool> createFineType(String title, String defaultAmount) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/type');

    var createFineTypeCommmand =
        CreateFineTypeCommand(title: title, defaultAmount: defaultAmount);

    final response = await _apiClient.post(
      url,
      body: createFineTypeCommmand.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create fine type');
    }

    return true;
  }

  static Future<void> deleteFineType(int fineTypeId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fine/type/$fineTypeId');

    final response = await _apiClient.delete(url);

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      throw FineTypeInUseException();
    }

    throw Exception('Failed to delete fine type');
  }
}

class FineTypeInUseException implements Exception {}
