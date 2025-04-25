class User {
  final int userId;
  final String fullname;
  final String email;
  final String? nickname;
  final String? profilePicture;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    this.nickname,
    this.profilePicture,
  });

  // Parsing JSON response dari API ke object User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      fullname: json['fullname'],
      email: json['email'],
      nickname: json['nickname'],
      profilePicture: json['profile_picture'],
    );
  }
}
