import 'package:flutter/material.dart';
import 'package:roomledger/models/room_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAvailableRoomsPage extends StatefulWidget {
  final int roomId;

  const EditAvailableRoomsPage({
    super.key,
    required this.roomId,
  });

  @override
  State<EditAvailableRoomsPage> createState() => _EditAvailableRoomsPageState();
}

class _EditAvailableRoomsPageState extends State<EditAvailableRoomsPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  bool isSaving = false;
  List<AvailableRoom> rooms = [];

  @override
  void initState() {
    super.initState();
    loadAvailableRooms();
  }

  Future<void> loadAvailableRooms() async {
    try {
      setState(() => isLoading = true);

      final data = await supabase
          .from('available_rooms')
          .select('id, title, subtitle, price_per_night, is_available')
          .eq('room_id', widget.roomId)
          .order('id', ascending: true);

      rooms = (data as List)
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Load error: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void addLocalRoom() {
    setState(() {
      rooms.add(
        const AvailableRoom(
          id: null,
          title: '',
          subtitle: '',
          pricePerNight: 0,
          isAvailable: true,
        ),
      );
    });
  }

  void updateLocalRoom(int index, AvailableRoom updatedRoom) {
    setState(() {
      rooms[index] = updatedRoom;
    });
  }

  Future<void> deleteRoom(int index) async {
    final room = rooms[index];

    try {
      if (room.id != null) {
        await supabase.from('available_rooms').delete().eq('id', room.id!);
      }

      setState(() {
        rooms.removeAt(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room type deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete error: $e')));
    }
  }

  Future<void> saveAll() async {
    try {
      setState(() => isSaving = true);

      for (final room in rooms) {
        if (room.title.trim().isEmpty) continue;
        if (room.pricePerNight < 0) continue;

        if (room.id == null) {
          await supabase.from('available_rooms').insert({
            'room_id': widget.roomId,
            'title': room.title.trim(),
            'subtitle': room.subtitle.trim(),
            'price_per_night': room.pricePerNight,
            'is_available': room.isAvailable,
          });
        } else {
          await supabase.from('available_rooms').update({
            'title': room.title.trim(),
            'subtitle': room.subtitle.trim(),
            'price_per_night': room.pricePerNight,
            'is_available': room.isAvailable,
          }).eq('id', room.id!);
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Database error: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Available Rooms'),
        actions: [
          TextButton(
            onPressed: isSaving ? null : saveAll,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isSaving ? null : addLocalRoom,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    'No room types yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return _EditableAvailableRoomCard(
                      key: ValueKey('${rooms[index].id ?? 'new'}-$index'),
                      room: rooms[index],
                      onChanged: (updated) => updateLocalRoom(index, updated),
                      onDelete: () => deleteRoom(index),
                    );
                  },
                ),
    );
  }
}

class _EditableAvailableRoomCard extends StatefulWidget {
  final AvailableRoom room;
  final ValueChanged<AvailableRoom> onChanged;
  final VoidCallback onDelete;

  const _EditableAvailableRoomCard({
    super.key,
    required this.room,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_EditableAvailableRoomCard> createState() =>
      _EditableAvailableRoomCardState();
}

class _EditableAvailableRoomCardState
    extends State<_EditableAvailableRoomCard> {
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  late TextEditingController priceController;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.room.title);
    subtitleController = TextEditingController(text: widget.room.subtitle);
    priceController = TextEditingController(
      text: widget.room.pricePerNight.toString(),
    );
    isAvailable = widget.room.isAvailable;
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void emitChange() {
    widget.onChanged(
      widget.room.copyWith(
        title: titleController.text.trim(),
        subtitle: subtitleController.text.trim(),
        pricePerNight: int.tryParse(priceController.text.trim()) ?? 0,
        isAvailable: isAvailable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Room Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextField(
            controller: titleController,
            onChanged: (_) => emitChange(),
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Standard Room',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: subtitleController,
            onChanged: (_) => emitChange(),
            decoration: InputDecoration(
              labelText: 'Subtitle',
              hintText: 'e.g. 1 Queen - 2 Guests - 25m2',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            onChanged: (_) => emitChange(),
            decoration: InputDecoration(
              labelText: 'Price per night',
              hintText: 'e.g. 250',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isAvailable,
            title: const Text(
              'Available',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onChanged: (value) {
              setState(() {
                isAvailable = value;
              });
              emitChange();
            },
          ),
        ],
      ),
    );
  }
}