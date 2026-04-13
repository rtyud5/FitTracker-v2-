class Food {
  final String id;
  final String name;
  final int calories;
  final String imageUrl;
  final String description;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.description,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      calories: map['calories'] is int
          ? map['calories'] as int
          : int.tryParse(map['calories'].toString()) ?? 0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      protein: map['protein'] is double
          ? map['protein'] as double
          : double.tryParse(map['protein'].toString()) ?? 0.0,
      fat: map['fat'] is double
          ? map['fat'] as double
          : double.tryParse(map['fat'].toString()) ?? 0.0,
      carb: map['carb'] is double
          ? map['carb'] as double
          : double.tryParse(map['carb'].toString()) ?? 0.0,
      fiber: map['fiber'] is double
          ? map['fiber'] as double
          : double.tryParse(map['fiber'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'imageUrl': imageUrl,
      'description': description,
      'protein': protein,
      'fat': fat,
      'carb': carb,
      'fiber': fiber,
    };
  }

  Food copyWith({
    String? id,
    String? name,
    int? calories,
    String? imageUrl,
    String? description,
    double? protein,
    double? fat,
    double? carb,
    double? fiber,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carb: carb ?? this.carb,
      fiber: fiber ?? this.fiber,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Food && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
