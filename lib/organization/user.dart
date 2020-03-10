import 'company.dart';

class User {
  final String firstName;
  final String lastName;
  final String tenant;
  final Company company;
  final List<String> roles;

  User(this.firstName, this.lastName, this.tenant, this.company, this.roles);

  User.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'],
        lastName = json['lastName'],
        tenant = json['tenant'],
        company = Company.fromJson(json['company']),
        roles = List<String>.from(json['roles']);

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'tenant': tenant,
        'roles': roles,
        'company': company.toJson(),
      };
}
