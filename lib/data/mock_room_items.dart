import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:roomledger/models/room_item.dart';

Future<List<RoomItem>> loadMockRooms() async {
  final String response = await rootBundle.loadString('assets/data/mock_room_items.json');
  final data = json.decode(response) as List<dynamic>;
  return data.map((e) => RoomItem.fromJson(e as Map<String, dynamic>)).toList();
}
