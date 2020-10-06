class Attendee {
  final String id;
  final String firstName;
  final bool checkIn;
  final String lastName;
  final String email;
  final String jobTitle;
  final String company;
  final String placeholder;
  final List<Comment> comments;
  final String barcode;

  Attendee(this.id, this.firstName, this.lastName, this.email, this.checkIn,
      this.jobTitle, this.company, this.comments, this.barcode)
      : this.placeholder = _generatePlaceholder(firstName, lastName);

  Attendee.fromJson(Map<String, dynamic> json)
      : id = json['attendee_id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        checkIn = json['checkIn'] != null ? true : false,
        jobTitle = json['jobTitle'],
        company = json['company'],
        placeholder = _generatePlaceholder(json['firstName'], json['lastName']),
        comments = json['comments'] != null
            ? List<Comment>.from(
                json['comments'].map((comment) => Comment.fromNetwork(comment)))
            : [],
        barcode = json['barcode'];

  Map<String, dynamic> toJson() => {
        'attendee_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'checkIn': checkIn,
        'jobTitle': jobTitle,
        'company': company,
        'comments': comments,
        'barcode': barcode
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
          jobTitle == other.jobTitle &&
          company == other.company &&
          email == other.email &&
          barcode == other.barcode;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      checkIn.hashCode ^
      lastName.hashCode ^
      jobTitle.hashCode ^
      company.hashCode ^
      email.hashCode ^
      barcode.hashCode;

  @override
  String toString() {
    return 'Attendee{id: $id, barcode: $barcode, checkIn: $checkIn}';
  }

  Attendee copy({bool check}) {
    return Attendee(this.id, this.firstName, this.lastName, this.email, check,
        this.jobTitle, this.company, this.comments, this.barcode);
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
