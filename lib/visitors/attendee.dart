class Attendee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Attendee(this.id, this.firstName, this.lastName, this.email);

  Attendee.fromJson(Map<String, dynamic> json)
      : id = json['attendee_id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'attendee_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email
      };
}
