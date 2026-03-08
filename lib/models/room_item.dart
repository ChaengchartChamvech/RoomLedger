class AvailableRoom {
  final int? id;
  final String title;
  final String subtitle;
  final int pricePerNight;
  final bool isAvailable;

  const AvailableRoom({
    this.id,
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
  AvailableRoom copyWith({
    int? id,
    String? title,
    String? subtitle,
    int? pricePerNight,
    bool? isAvailable,
  }) {
    return AvailableRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

}

class RoomItem {
  final int id;
  final String name;
  final String location;
  final int pricePerNight;
  final String imageUrl;
  final String description;
  final List<String> amenities;
  final List<AvailableRoom> availableRooms;

  const RoomItem({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerNight,
    required this.imageUrl,
    required this.description,
    required this.amenities,
    required this.availableRooms,
  });

  factory RoomItem.fromJson(Map<String, dynamic> json) {
    return RoomItem(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      pricePerNight: json['pricePerNight'] as int,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      amenities: (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      availableRooms: (json['availableRooms'] as List<dynamic>)
          .map((e) => AvailableRoom.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
