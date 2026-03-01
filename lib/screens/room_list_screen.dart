import 'package:flutter/material.dart';
import 'detail_page.dart';
class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  int _navIndex = 0;

  final List<RoomItem> rooms = const [
    RoomItem(
      name: "Hotel 1",
      location: "Location",
      pricePerNight: 250,
      rating: 4.65,
      imageUrl:
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80",
      description:
          "Modern rooms with city views. Close to transport, cafés, and shopping.",
      amenities: ["Wi-Fi", "Parking", "Breakfast", "Pool", "Air-con"],
      availableRooms: [
        AvailableRoom(
          title: "Standard Room",
          subtitle: "1 Queen • 2 Guests • 25m²",
          pricePerNight: 250,
          isAvailable: true,
        ),
        AvailableRoom(
          title: "Deluxe Room",
          subtitle: "1 King • 2 Guests • 32m² • City view",
          pricePerNight: 320,
          isAvailable: true,
        ),
        AvailableRoom(
          title: "Family Room",
          subtitle: "2 Beds • 4 Guests • 40m²",
          pricePerNight: 420,
          isAvailable: false,
        ),
      ],
    ),
    RoomItem(
      name: "Hotel 2",
      location: "Location",
      pricePerNight: 250,
      rating: 4.65,
      imageUrl:
          "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&q=80",
      description: "Cozy place with quiet neighborhood and great service.",
      amenities: ["Wi-Fi", "Gym", "Air-con"],
      availableRooms: [
        AvailableRoom(
          title: "Studio",
          subtitle: "1 Bed • 2 Guests • Kitchenette",
          pricePerNight: 260,
          isAvailable: true,
        ),
        AvailableRoom(
          title: "Suite",
          subtitle: "1 King • 2 Guests • Living room",
          pricePerNight: 380,
          isAvailable: true,
        ),
      ],
    ),
    RoomItem(
      name: "Hotel 3",
      location: "Location",
      pricePerNight: 250,
      rating: 4.65,
      imageUrl:
          "https://images.unsplash.com/photo-1505692952047-1a78307da8f2?w=1200&q=80",
      description: "Bright rooms, perfect for short stays and business trips.",
      amenities: ["Wi-Fi", "Breakfast", "Workspace"],
      availableRooms: [
        AvailableRoom(
          title: "Single",
          subtitle: "1 Single • 1 Guest • 18m²",
          pricePerNight: 180,
          isAvailable: true,
        ),
        AvailableRoom(
          title: "Double",
          subtitle: "1 Queen • 2 Guests • 24m²",
          pricePerNight: 240,
          isAvailable: false,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const bg = Color.fromARGB(
      255,
      2,
      103,
      150,
    ); // similar neon-yellow background

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onChanged: (i) => setState(() => _navIndex = i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                hintText: "Search",
                onChanged: (value) {
                  // TODO: hook search/filter logic
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return RoomCard(
                    room: room,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomDetailPage(room: room),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailableRoom {
  final String title; // e.g. "Standard Room"
  final String subtitle; // e.g. "1 Queen • 2 Guests • 25m²"
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

class RoomCard extends StatelessWidget {
  final RoomItem room;
  final VoidCallback? onTap;

  const RoomCard({super.key, required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    room.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFF2F2F2),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF2F2F2),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${room.name}, ${room.location}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\$${room.pricePerNight}/night",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFFFB400),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room.rating.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const _SearchBar({required this.hintText, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x11000000))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
