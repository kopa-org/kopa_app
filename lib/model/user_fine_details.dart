import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/user_details.dart';

class UserFineDetails {
  final int id;
  final UserDetails userDetails;
  final List<FineDetails> fineDetailsList;

  UserFineDetails({
    required this.id,
    required this.userDetails,
    required this.fineDetailsList,
  });

  factory UserFineDetails.fromJson(Map<String, dynamic> json) {
    return UserFineDetails(
      id: json['id'],
      userDetails: UserDetails.fromJson(json['user_details']),
      fineDetailsList: json['fine_details_list'] != null
          ? List<FineDetails>.from(
              json['fine_details_list'].map((x) => FineDetails.fromJson(x)))
          : [],
    );
  }
}
