import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/tab/profile_tab.dart';

void main() {
  test('sorts squad by player role groups', () {
    final sorted = sortSquadByPlayerRole([
      _user(id: 1, name: 'Wing', position: 'wing'),
      _user(id: 2, name: 'Midtbane', position: 'midfield'),
      _user(id: 3, name: 'Målmand', position: 'goalkeeper'),
      _user(id: 4, name: 'Back', position: 'back_wingback'),
      _user(id: 5, name: 'Angriber', position: 'striker'),
      _user(id: 6, name: 'Offensiv midtbane', position: 'attacking_midfield'),
      _user(id: 7, name: 'Midterforsvar', position: 'centre_back'),
      _user(id: 8, name: 'Ukendt', position: null),
    ]);

    expect(
      sorted.map((player) => player.name),
      [
        'Målmand',
        'Back',
        'Midterforsvar',
        'Midtbane',
        'Offensiv midtbane',
        'Wing',
        'Angriber',
        'Ukendt',
      ],
    );
  });
}

UserDetails _user({
  required int id,
  required String name,
  required String? position,
}) {
  return UserDetails(
    id: id,
    name: name,
    email: '$id@example.com',
    isTeamOwner: false,
    roleId: 2,
    position: position,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    teamDetails: null,
  );
}
