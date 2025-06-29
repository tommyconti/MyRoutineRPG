// Rappresenta il profilo e le statistiche di un utente.
class UserStats {
  final int level;
  final int xp; 
  final int totalXP;
  final String title;
  final String nickname;

  UserStats({
    required this.level,
    required this.xp,
    required this.totalXP,
    required this.title,
    required this.nickname,
  });

  // Un "costruttore" statico per creare le statistiche iniziali per un nuovo utente.
  static UserStats get initial => UserStats(
        level: 1,
        xp: 0,
        totalXP: 0,
        title: "Player",
        nickname: "Hunter",
      );

  // Determina il titolo dell'utente in base al suo livello.
  static String getTitleForLevel(int level) {
    if (level >= 20) return "The monarch of shadows";
    if (level >= 15) return "Necromancer";
    if (level >= 10) return "Night lord";
    if (level >= 5) return "Assassin";
    if (level >= 1) return "Player";
    return "Player";
  }

  // Calcola l'XP necessario per raggiungere il prossimo livello.
  static int getXPForLevel(int level) {
    return level * 100;
  }

  // Crea una copia dell'oggetto `UserStats` aggiornando solo i campi specificati.
  UserStats copyWith({
    int? level,
    int? xp,
    int? totalXP,
    String? title,
    String? nickname,
  }) {
    return UserStats(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXP: totalXP ?? this.totalXP,
      title: title ?? this.title,
      nickname: nickname ?? this.nickname,
    );
  }

  // Converte l'oggetto `UserStats` in una mappa (formato JSON).
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'xp': xp,
      'totalXP': totalXP,
      'title': title,
      'nickname': nickname,
    };
  }

  // Crea un oggetto `UserStats` a partire da una mappa (formato JSON).
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      title: json['title'] ?? "Player",
      nickname: json['nickname'] ?? "Player",
    );
  }
}