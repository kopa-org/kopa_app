import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/team_logo_design.dart';

void main() {
  test('serializes the onboarding logo design for the API', () {
    const design = TeamLogoDesign(
      color: Color(0xFFD22B2B),
      shape: TeamLogoShape.shield,
      pattern: TeamLogoPattern.horizontalSplit,
    );

    expect(design.toJson(), {
      'logo_color': '#D22B2B',
      'logo_shape': 'shield',
      'logo_pattern': 'horizontalSplit',
    });
  });

  test('restores a team logo design from team details', () {
    final team = TeamDetails.fromJson({
      'id': 1,
      'title': 'Kopa FC',
      'player_count': 11,
      'logo_color': '#1975F2',
      'logo_shape': 'rounded',
      'logo_pattern': 'gradient',
      'created_at': '2026-08-06T12:00:00Z',
      'updated_at': '2026-08-06T12:00:00Z',
    });

    expect(team.logoDesign.color, const Color(0xFF1975F2));
    expect(team.logoDesign.shape, TeamLogoShape.rounded);
    expect(team.logoDesign.pattern, TeamLogoPattern.gradient);
  });
}
