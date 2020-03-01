class Attendee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<Comment> comments;

  Attendee(this.id, this.firstName, this.lastName, this.email, this.comments);

  Attendee.fromJson(Map<String, dynamic> json)
      : id = json['attendee_id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        comments = json['comments'] != null
            ? List<Comment>.from(
                json['comments'].map((comment) => Comment.fromNetwork(comment)))
            : [];

  Map<String, dynamic> toJson() => {
        'attendee_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'comments': comments
      };
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
