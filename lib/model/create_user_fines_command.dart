import 'dart:convert';

import 'package:kopa/model/create_user_fine_command.dart';

class CreateUserFinesCommand {
  final List<CreateUserFineCommand> createUserFinesCommand;

  CreateUserFinesCommand(this.createUserFinesCommand);

  Map<String, dynamic> toJson() {
    return {
      'create_user_fines_command':
          jsonEncode(createUserFinesCommand.map((e) => e.toJson()).toList())
    };
  }
}
