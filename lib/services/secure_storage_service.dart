import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/model/user_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  );
  static const _lineupDragHintSeenKey = 'lineupDragHintSeen';
  static const _hasAuthenticatedBeforeKey = 'hasAuthenticatedBefore';

  // ------------------------
  // Token methods
  // ------------------------

  static Future<void> setToken(String token) async {
    await _storage.delete(key: 'token');
    await _storage.write(key: 'token', value: token);
    await setHasAuthenticatedBefore();
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> setPushToken(String token) async {
    await _storage.write(key: 'pushToken', value: token);
  }

  static Future<String?> getPushToken() async {
    return await _storage.read(key: 'pushToken');
  }

  static Future<void> deletePushToken() async {
    await _storage.delete(key: 'pushToken');
  }

  // ------------------------
  // Local app preferences
  // ------------------------

  static Future<bool> hasSeenLineupDragHint() async {
    final value = await _storage.read(key: _lineupDragHintSeenKey);
    return value == 'true';
  }

  static Future<void> setLineupDragHintSeen() async {
    await _storage.write(key: _lineupDragHintSeenKey, value: 'true');
  }

  static Future<bool> hasAuthenticatedBefore() async {
    final value = await _storage.read(key: _hasAuthenticatedBeforeKey);
    return value == 'true';
  }

  static Future<void> setHasAuthenticatedBefore() async {
    await _storage.write(key: _hasAuthenticatedBeforeKey, value: 'true');
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
    if (user.teamDetails != null) {
      await _storage.write(key: 'teamName', value: user.teamDetails!.title);
      await _storage.write(
        key: 'teamPlayerCount',
        value: user.teamDetails!.playerCount.toString(),
      );
      await _storage.write(
        key: 'teamLogoColor',
        value: TeamLogoDesign.colorToHex(user.teamDetails!.logoDesign.color),
      );
      await _storage.write(
        key: 'teamLogoShape',
        value: user.teamDetails!.logoDesign.shape.name,
      );
      await _storage.write(
        key: 'teamLogoPattern',
        value: user.teamDetails!.logoDesign.pattern.name,
      );
    } else {
      await _storage.delete(key: 'teamName');
      await _storage.delete(key: 'teamPlayerCount');
      await _storage.delete(key: 'teamLogoColor');
      await _storage.delete(key: 'teamLogoShape');
      await _storage.delete(key: 'teamLogoPattern');
    }
  }

  static Future<void> clearUserData() async {
    final hadAuthenticatedBefore = await hasAuthenticatedBefore();
    await _storage.deleteAll();
    if (hadAuthenticatedBefore) {
      await setHasAuthenticatedBefore();
    }
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
    final teamPlayerCount = await _storage.read(key: 'teamPlayerCount');
    final teamLogoColor = await _storage.read(key: 'teamLogoColor');
    final teamLogoShape = await _storage.read(key: 'teamLogoShape');
    final teamLogoPattern = await _storage.read(key: 'teamLogoPattern');

    if ([
      idStr,
      name,
      emailStr,
      roleStr,
      isTeamOwnerStr,
      createdAtStr,
      updatedAtStr,
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
        teamDetails: teamName == null
            ? null
            : TeamDetails(
                id: 1,
                title: teamName,
                playerCount: int.tryParse(teamPlayerCount ?? '') ?? 7,
                logoDesign: TeamLogoDesign.fromJson({
                  'logo_color': teamLogoColor,
                  'logo_shape': teamLogoShape,
                  'logo_pattern': teamLogoPattern,
                }),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
      );
    } catch (_) {
      return null;
    }
  }
}
