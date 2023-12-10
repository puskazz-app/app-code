
class CheatsModel {
  final int? id;
  late final String savedCheatTitle;
  final String savedCheatImages;

  CheatsModel({
    this.id,
    required this.savedCheatTitle,
    required this.savedCheatImages,
  });

  factory CheatsModel.fromMap(Map<String, dynamic> map) {
    return CheatsModel(
      id: map['id'],
      savedCheatTitle: map['savedCheatTitle'],
      savedCheatImages: map['savedCheatImages'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'savedCheatTitle': savedCheatTitle,
      'savedCheatImages': savedCheatImages,
    };
  }
}
