class UserProfile {
  final String name;
  final String avatarUrl;
  final String status; // online | away | offline
  final List<String> friends;
  final List<String> favorites;

  UserProfile({
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.friends,
    required this.favorites,
  });
}
