import 'package:flutter/material.dart';
import 'package:roomledger/models/room_item.dart';

class EditAvailableRoomsPage extends StatefulWidget {
  final List<AvailableRoom> availableRooms;

  const EditAvailableRoomsPage({
    super.key,
    required this.availableRooms,
  });

  @override
  State<EditAvailableRoomsPage> createState() => _EditAvailableRoomsPageState();
}

class _EditAvailableRoomsPageState extends State<EditAvailableRoomsPage> {
  late List<AvailableRoom> rooms;

  @override
  void initState() {
    super.initState();
    rooms = List<AvailableRoom>.from(widget.availableRooms);
  }

  void _addRoom() {
    setState(() {
      rooms.add(
        const AvailableRoom(
          title: '',
          subtitle: '',
          pricePerNight: 0,
          isAvailable: true,
        ),
      );
    });
  }

  void _removeRoom(int index) {
    setState(() {
      rooms.removeAt(index);
    });
  }

  void _saveAndBack() {
    Navigator.pop(context, rooms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Available Rooms'),
        actions: [
          TextButton(
            onPressed: _saveAndBack,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        child: const Icon(Icons.add),
      ),
      body: rooms.isEmpty
          ? const Center(
              child: Text(
                'No available rooms yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return _EditableRoomCard(
                  key: ValueKey(index),
                  room: rooms[index],
                  onChanged: (updatedRoom) {
                    setState(() {
                      rooms[index] = updatedRoom;
                    });
                  },
                  onDelete: () => _removeRoom(index),
                );
              },
            ),
    );
  }
}

class _EditableRoomCard extends StatefulWidget {
  final AvailableRoom room;
  final ValueChanged<AvailableRoom> onChanged;
  final VoidCallback onDelete;

  const _EditableRoomCard({
    super.key,
    required this.room,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_EditableRoomCard> createState() => _EditableRoomCardState();
}

class _EditableRoomCardState extends State<_EditableRoomCard> {
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

  void _emitChange() {
    widget.onChanged(
      AvailableRoom(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
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
            onChanged: (_) => _emitChange(),
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
            onChanged: (_) => _emitChange(),
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
            onChanged: (_) => _emitChange(),
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
            value: isAvailable,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Available',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onChanged: (value) {
              setState(() {
                isAvailable = value;
              });
              _emitChange();
            },
          ),
        ],
      ),
    );
  }
}