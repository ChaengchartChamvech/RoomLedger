import 'package:flutter/material.dart';
import 'package:roomledger/screens/room_list_screen.dart';

void main() {
  runApp(const RoomLedgerApp());
}

class RoomLedgerApp extends StatelessWidget {
  const RoomLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomLedger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const RoomListPage(),
    );
  }
}
