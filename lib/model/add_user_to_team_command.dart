class AddUserToTeamCommand {
  String name;
  String email;
  bool isTeamOwner;

  AddUserToTeamCommand(this.name, this.email, this.isTeamOwner);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'is_team_owner': isTeamOwner.toString(),
    };
  }
}
