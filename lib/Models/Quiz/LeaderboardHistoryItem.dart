class LeaderboardHistoryItem {
  final int userId;
  final String nickname;
  final String profilePicture;
  final int score;
  final String weekStart;
  final String weekEnd;

  LeaderboardHistoryItem({
    required this.userId,
    required this.nickname,
    required this.profilePicture,
    required this.score,
    required this.weekStart,
    required this.weekEnd,
  });

  factory LeaderboardHistoryItem.fromJson(
      Map<String, dynamic> json, String baseUrl) {
    return LeaderboardHistoryItem(
      userId: json['user_id'],
      nickname: json['nickname'],
      profilePicture:
          json['profile_picture'] != null && json['profile_picture'].isNotEmpty
              ? '$baseUrl/static/uploads/${json['profile_picture']}'
              : '$baseUrl/static/uploads/default.png',
      score: json['score'],
      weekStart: json['week_start'],
      weekEnd: json['week_end'],
    );
  }
}
