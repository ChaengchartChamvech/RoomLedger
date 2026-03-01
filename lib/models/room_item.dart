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
}
