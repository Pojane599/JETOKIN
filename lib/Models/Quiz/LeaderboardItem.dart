class LeaderboardItem {
  final int userId;
  final String nickname;
  final String profilePicture;
  final int score;
  final int ranking; // Tambahkan properti ranking

  LeaderboardItem({
    required this.userId,
    required this.nickname,
    required this.profilePicture,
    required this.score,
    required this.ranking, // Tambahkan ke konstruktor
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json, String baseUrl) {
    return LeaderboardItem(
      userId: json['user_id'] ?? 0,
      nickname: json['nickname'] ?? "Unknown",
      profilePicture: json['profile_picture'] != null
          ? "$baseUrl/static/uploads/${json['profile_picture']}"
          : "$baseUrl/static/uploads/default.png",
      score: int.tryParse(json['total_score'].toString()) ??
          0, // Pastikan parsing total_score
      ranking: json['ranking'] ?? 0,
    );
  }
}
