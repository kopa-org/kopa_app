import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  );

  // ------------------------
  // Token methods
  // ------------------------

  static Future<void> setToken(String token) async {
    await _storage.delete(key: 'token');
    await _storage.write(key: 'token', value: token);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // ------------------------
  // User info methods
  // ------------------------

  static Future<void> setUserInfo(UserDetails user) async {
    await _storage.write(key: 'id', value: user.id.toString());
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'email', value: user.email);
    await _storage.write(key: 'roleId', value: user.roleId.toString());
    await _storage.write(
        key: 'isTeamOwner', value: user.isTeamOwner.toString());
    await _storage.write(
        key: 'createdAt', value: user.createdAt.toIso8601String());
    await _storage.write(
        key: 'updatedAt', value: user.updatedAt.toIso8601String());
    await _storage.write(key: 'teamName', value: user.teamDetails.title);
  }

  static Future<void> clearUserData() async {
    await _storage.deleteAll();
    await deleteToken();
  }

  // ------------------------
  // Get User Details from current user
  // ------------------------
  static Future<UserDetails?> getUserInfo() async {
    final idStr = await _storage.read(key: 'id');
    final name = await _storage.read(key: 'name');
    final roleStr = await _storage.read(key: 'roleId');
    final emailStr = await _storage.read(key: 'email');
    final isTeamOwnerStr = await _storage.read(key: 'isTeamOwner');
    final createdAtStr = await _storage.read(key: 'createdAt');
    final updatedAtStr = await _storage.read(key: 'updatedAt');
    final teamName = await _storage.read(key: 'teamName');

    if ([
      idStr,
      name,
      emailStr,
      roleStr,
      isTeamOwnerStr,
      createdAtStr,
      updatedAtStr,
      teamName
    ].contains(null)) {
      return null;
    }

    try {
      final bool isTeamOwner = isTeamOwnerStr!.toLowerCase() == 'true';

      return UserDetails(
        id: int.parse(idStr!),
        name: name!,
        roleId: int.parse(roleStr!),
        email: emailStr!,
        isTeamOwner: isTeamOwner,
        createdAt: DateTime.parse(createdAtStr!),
        updatedAt: DateTime.parse(updatedAtStr!),
        teamDetails: TeamDetails(
          id: 1,
          title: teamName!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
