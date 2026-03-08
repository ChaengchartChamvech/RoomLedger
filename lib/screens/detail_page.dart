import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:roomledger/models/room_item.dart';
import 'package:roomledger/screens/edit_available_rooms_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomDetailPage extends StatefulWidget {
  final RoomItem room;
  final bool isRoomOwner;
  const RoomDetailPage({
    super.key,
    required this.room,
    required this.isRoomOwner,
  });

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final supabase = Supabase.instance.client;

  String? roomName = "";
  int roomPrice = 0;
  AvailableRoom? selectedAvailableRoom;
  late Future<List<AvailableRoom>> _availableRoomsFuture;

  @override
  void initState() {
    super.initState();
    _availableRoomsFuture = fetchAvailableRooms();
  }

  Future<List<AvailableRoom>> fetchAvailableRooms() async {
    final data = await supabase
        .from('available_rooms')
        .select('id, title, subtitle, price_per_night, is_available')
        .eq('room_id', widget.room.id)
        .order('id', ascending: true);

    return (data as List)
        .map(
          (r) => AvailableRoom(
            id: r['id'],
            title: r['title'] ?? '',
            subtitle: r['subtitle'] ?? '',
            pricePerNight: r['price_per_night'] ?? 0,
            isAvailable: r['is_available'] ?? false,
          ),
        )
        .toList();
  }

  Future<void> refreshAvailableRooms() async {
    setState(() {
      _availableRoomsFuture = fetchAvailableRooms();
    });
  }

  Future<void> deleteRoom() async {
    if (widget.isRoomOwner) {
      try {
        final roomToDelete = widget.room;

        await supabase
            .from('rooms')
            .delete()
            .eq('id', roomToDelete.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting room: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only room owners can delete rooms')),
      );
    }
  }

  Future<void> bookNow() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    if (selectedAvailableRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room type first')),
      );
      return;
    }

    if (selectedAvailableRoom!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid room type selected')),
      );
      return;
    }

    try {
      await supabase.from('bookings').insert({
        'room_id': widget.room.id,
        'tenant_id': user.id,
        'available_room_id': selectedAvailableRoom!.id,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booked successfully')));
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Database error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.room.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "${widget.room.name}, ${widget.room.location}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: deleteRoom,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        "\$${widget.room.pricePerNight}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "/night",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Text(
                    widget.room.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Amenities",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.room.amenities
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Available Rooms",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (widget.isRoomOwner)
                        OutlinedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAvailableRoomsPage(
                                  roomId: widget.room.id,
                                ),
                              ),
                            );

                            if (updated == true) {
                              refreshAvailableRooms();
                            }
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit Rooms"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0x22000000)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<AvailableRoom>>(
                    future: _availableRoomsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final rooms = snapshot.data ?? [];

                      if (rooms.isEmpty) {
                        return const Text('No available room types.');
                      }

                      return Column(
                        children: rooms
                            .map(
                              (r) => _AvailableRoomTile(
                                room: r,
                                onTap: r.isAvailable
                                    ? () {
                                        setState(() {
                                          selectedAvailableRoom = r;
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Selected: ${r.title}",
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0x11000000))),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selected Room",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${selectedAvailableRoom?.title ?? 'None'} - ${selectedAvailableRoom?.pricePerNight ?? 0}/night",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: () {
                    if (widget.isRoomOwner) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Room owners cannot book their own rooms",
                          ),
                        ),
                      );
                    } else {
                      bookNow();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Book now clicked")),
                      );
                    }
                  },
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _AvailableRoomTile extends StatelessWidget {
  final AvailableRoom room;
  final VoidCallback? onTap;

  const _AvailableRoomTile({required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = !room.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: disabled ? const Color(0xFFF1F1F1) : Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bed_rounded,
                  color: disabled ? Colors.black38 : Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: disabled ? Colors.black38 : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          "\$${room.pricePerNight}/night",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: disabled ? Colors.black38 : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: disabled ? Colors.black26 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: disabled
                              ? const Color(0xFFF3F3F3)
                              : const Color(0xFFEAFBEA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          disabled ? "Not available" : "Available",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: disabled
                                ? Colors.black38
                                : const Color(0xFF1B7F1B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
