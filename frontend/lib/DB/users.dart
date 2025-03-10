class Users {
  List<String> words;

  Users({
    required this.words,
  });

  Users.fromJson(Map<String, Object?> json)
      : this(
          words: (json['words'] as List<String>),
        );

  Users copyWith({
    List<String>? words,
  }) {
    return Users(words: words ?? this.words);
  }

  Map<String, Object?> toJson() {
    return {
      'words': words,
    };
  }
}
