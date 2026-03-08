import 'package:flutter/material.dart';
import 'package:roomledger/models/room_item.dart';
import 'package:roomledger/screens/detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_room_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  static const _backgroundColor = Color.fromARGB(255, 2, 103, 150);
  final supabase = Supabase.instance.client;

  bool isOwner = false;
  bool isLoadingRole = true;

  late Future<List<RoomItem>> _roomsFuture;
  List<RoomItem> _allRooms = [];
  List<RoomItem> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    checkUserRole();
    _roomsFuture = fetchRooms().then((rooms) {
      _allRooms = rooms;
      _filteredRooms = rooms;
      return rooms;
    });
  }

  Future<void> checkUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isOwner = false;
        isLoadingRole = false;
      });
      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      setState(() {
        isOwner = data['role'] == 'owner';
        isLoadingRole = false;
      });
    } catch (e) {
      setState(() {
        isOwner = false;
        isLoadingRole = false;
      });
    }
  }

  Future<List<RoomItem>> fetchRooms() async {
    final data = await supabase
        .from('rooms')
        .select('''
      id,
      name,
      location,
      price_per_night,
      image_url,
      description,
      room_amenities (
        amenity
      ),
      available_rooms (
      id,
        title,
        subtitle,
        price_per_night,
        is_available
      )
    ''')
        .order('id', ascending: false);

    return (data as List)
        .map(
          (roomMap) => RoomItem(
            id: roomMap['id'] as int,
            name: roomMap['name'] ?? '',
            location: roomMap['location'] ?? '',
            pricePerNight: roomMap['price_per_night'] ?? 0,
            imageUrl:
                roomMap['image_url'] ??
                'https://via.placeholder.com/400x250?text=No+Image',
            description: roomMap['description'] ?? '',
            amenities: ((roomMap['room_amenities'] ?? []) as List)
                .map((a) => a['amenity'] as String)
                .toList(),
            availableRooms: ((roomMap['available_rooms'] ?? []) as List)
                .map(
                  (r) => AvailableRoom(
                    title: r['title'] ?? '',
                    subtitle: r['subtitle'] ?? '',
                    pricePerNight: r['price_per_night'] ?? 0,
                    isAvailable: r['is_available'] ?? false,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Future<void> refreshRooms() async {
    setState(() {
      _roomsFuture = fetchRooms().then((rooms) {
        _allRooms = rooms;
        _filteredRooms = rooms;
        return rooms;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                hintText: 'Search',
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      _filteredRooms = _allRooms;
                    } else {
                      _filteredRooms = _allRooms
                          .where((room) => room.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<RoomItem>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (_filteredRooms.isEmpty) {
                    return const Center(
                      child: Text(
                        'No rooms found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: refreshRooms,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filteredRooms.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final room = _filteredRooms[index];
                        return RoomCard(
                          room: room,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomDetailPage(
                                  room: room,
                                  isOwner: isOwner,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isLoadingRole && isOwner
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddRoomPage()),
                );

                if (created == true) {
                  refreshRooms();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
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
                    errorBuilder: (context, error, stackTrace) => Container(
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
                          '${room.name}, ${room.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${room.pricePerNight}/night',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
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
