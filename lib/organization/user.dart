import 'company.dart';

class User {
  final String firstName;
  final String lastName;
  final String tenant;
  final Company company;

  User(this.firstName, this.lastName, this.tenant, this.company);

  User.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'],
        lastName= json['lastName'],
        tenant=json['tenant'],
        company=Company.fromJson(json['company']);

  Map<String, dynamic> toJson() =>
      {
        'firstName': firstName,
        'lastName': lastName,
        'tenant': tenant,
        'company': company.toJson(),
      };
}