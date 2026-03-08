class AvailableRoom {
  final String title;
  final String subtitle;
  final int pricePerNight;
  final bool isAvailable;

  const AvailableRoom({
    required this.title,
    required this.subtitle,
    required this.pricePerNight,
    required this.isAvailable,
  });

  factory AvailableRoom.fromJson(Map<String, dynamic> json) {
    return AvailableRoom(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      pricePerNight: json['pricePerNight'] as int,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}

class RoomItem {
  final String name;
  final String location;
  final int pricePerNight;
  final double rating;
  final String imageUrl;
  final String description;
  final List<String> amenities;
  final List<AvailableRoom> availableRooms;

  const RoomItem({
    required this.name,
    required this.location,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.amenities,
    required this.availableRooms,
  });

  factory RoomItem.fromJson(Map<String, dynamic> json) {
    return RoomItem(
      name: json['name'] as String,
      location: json['location'] as String,
      pricePerNight: json['pricePerNight'] as int,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      amenities: (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      availableRooms: (json['availableRooms'] as List<dynamic>)
          .map((e) => AvailableRoom.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
