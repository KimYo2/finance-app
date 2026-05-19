class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
