import 'company.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String tenant;
  final Company company;
  final List<String> roles;

  User(this.firstName, this.lastName, this.email, this.tenant, this.company, this.roles);

  User.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        tenant = json['tenant'],
        company = Company.fromJson(json['company']),
        roles = List<String>.from(json['roles']);

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'tenant': tenant,
        'roles': roles,
        'company': company.toJson(),
      };
}
