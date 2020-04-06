class Company {
  final String id;
  final String privacyPolicyUrl;
  final String logo;
  final String name;

  Company.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        privacyPolicyUrl = json['privacyPolicyUrl'],
        logo = json['logo'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'privacyPolicyUrl': privacyPolicyUrl,
    'logo': logo,
    'name': name
  };
}