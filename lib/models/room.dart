class Room {
  const Room({
    required this.id,
    required this.title,
    required this.location,
    required this.monthlyPrice,
    required this.isAvailable,
  });

  final int id;
  final String title;
  final String location;
  final int monthlyPrice;
  final bool isAvailable;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location'] as String,
      monthlyPrice: (json['monthly_price'] as num).toInt(),
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
    );
  }
}
