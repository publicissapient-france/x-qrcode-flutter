class Attendee {
  final String id;
  final String firstName;
  final bool checkIn;
  final String lastName;
  final String email;
  final String placeholder;
  final List<Comment> comments;

  Attendee(this.id, this.firstName, this.lastName, this.email, this.checkIn,
      this.comments)
      : this.placeholder = _generatePlaceholder(firstName, lastName);

  Attendee.fromJson(Map<String, dynamic> json)
      : id = json['attendee_id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        checkIn = json['checkIn'] != null ? true : false,
        placeholder = _generatePlaceholder(json['firstName'], json['lastName']),
        comments = json['comments'] != null
            ? List<Comment>.from(
                json['comments'].map((comment) => Comment.fromNetwork(comment)))
            : [];

  Map<String, dynamic> toJson() => {
        'attendee_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'checkIn': checkIn,
        'comments': comments
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attendee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          checkIn == other.checkIn &&
          lastName == other.lastName &&
          email == other.email;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      checkIn.hashCode ^
      lastName.hashCode ^
      email.hashCode;

  @override
  String toString() {
    return 'Attendee{id: $id, checkIn: $checkIn}';
  }

  Attendee copy({bool check}) {
    return Attendee(
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      check,
      this.comments,
    );
  }

  static _generatePlaceholder(String firstName, String lastName) {
    if (firstName != null) {
      if (lastName != null) {
        return firstName.substring(0, 1) + lastName.substring(0, 1);
      }
      return '?';
    }
  }
}

class Comment {
  final String id;
  final String date;
  final String text;
  final String authorFirstName;

  Comment(this.date, this.authorFirstName, this.text, this.id);

  Comment.fromNetwork(Map<String, dynamic> json)
      : id = json['comment_id'],
        date = json['date'],
        text = json['description'],
        authorFirstName = json['user_firstName'];

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = json['date'],
        text = json['text'],
        authorFirstName = json['authorFirstName'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'text': text,
        'authorFirstName': authorFirstName
      };
}
