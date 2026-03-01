import 'package:roomledger/models/room_item.dart';

const List<RoomItem> mockRoomItems = [
  RoomItem(
    name: 'Hotel 1',
    location: 'Location',
    pricePerNight: 250,
    rating: 4.65,
    imageUrl:
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',
    description:
        'Modern rooms with city views. Close to transport, cafes, and shopping.',
    amenities: ['Wi-Fi', 'Parking', 'Breakfast', 'Pool', 'Air-con'],
    availableRooms: [
      AvailableRoom(
        title: 'Standard Room',
        subtitle: '1 Queen - 2 Guests - 25m2',
        pricePerNight: 250,
        isAvailable: true,
      ),
      AvailableRoom(
        title: 'Deluxe Room',
        subtitle: '1 King - 2 Guests - 32m2 - City view',
        pricePerNight: 320,
        isAvailable: true,
      ),
      AvailableRoom(
        title: 'Family Room',
        subtitle: '2 Beds - 4 Guests - 40m2',
        pricePerNight: 420,
        isAvailable: false,
      ),
    ],
  ),
  RoomItem(
    name: 'Hotel 2',
    location: 'Location',
    pricePerNight: 250,
    rating: 4.65,
    imageUrl:
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&q=80',
    description: 'Cozy place with quiet neighborhood and great service.',
    amenities: ['Wi-Fi', 'Gym', 'Air-con'],
    availableRooms: [
      AvailableRoom(
        title: 'Studio',
        subtitle: '1 Bed - 2 Guests - Kitchenette',
        pricePerNight: 260,
        isAvailable: true,
      ),
      AvailableRoom(
        title: 'Suite',
        subtitle: '1 King - 2 Guests - Living room',
        pricePerNight: 380,
        isAvailable: true,
      ),
    ],
  ),
  RoomItem(
    name: 'Hotel 3',
    location: 'Location',
    pricePerNight: 250,
    rating: 4.65,
    imageUrl:
        'https://images.unsplash.com/photo-1505692952047-1a78307da8f2?w=1200&q=80',
    description: 'Bright rooms, perfect for short stays and business trips.',
    amenities: ['Wi-Fi', 'Breakfast', 'Workspace'],
    availableRooms: [
      AvailableRoom(
        title: 'Single',
        subtitle: '1 Single - 1 Guest - 18m2',
        pricePerNight: 180,
        isAvailable: true,
      ),
      AvailableRoom(
        title: 'Double',
        subtitle: '1 Queen - 2 Guests - 24m2',
        pricePerNight: 240,
        isAvailable: false,
      ),
    ],
  ),
];
