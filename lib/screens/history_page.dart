import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = fetchHistory();
  }

  Future<List<HistoryItem>> fetchHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase.from('bookings').select('''
      rooms (
        name,
        location
      ),
      available_rooms (
        title
      )
    ''').eq('tenant_id', user.id);

    return (data as List).map((item) {
      final room = item['rooms'];
      final available = item['available_rooms'];

      return HistoryItem(
        hotelName: room['name'] ?? '',
        location: room['location'] ?? '',
        roomType: available['title'] ?? '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return const Center(
            child: Text("No rental history"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  item.hotelName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${item.roomType} • ${item.location}",
                ),
                leading: const Icon(Icons.hotel),
              ),
            );
          },
        );
      },
    );
  }
}