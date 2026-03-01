import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:roomledger/models/room.dart';

class RoomApiService {
  RoomApiService({http.Client? client}) : _client = client;

  static const bool useMockMode = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  // For Android emulator use http://10.0.2.2:3000
  // For iOS simulator use http://localhost:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final http.Client? _client;
  final List<Room> _mockRooms = <Room>[
    const Room(
      id: 1,
      title: 'Studio Near MRT',
      location: 'Bangkok - Huai Khwang',
      monthlyPrice: 8500,
      isAvailable: true,
    ),
    const Room(
      id: 2,
      title: 'One Bedroom Condo',
      location: 'Bangkok - On Nut',
      monthlyPrice: 12000,
      isAvailable: true,
    ),
    const Room(
      id: 3,
      title: 'Budget Shared Room',
      location: 'Bangkok - Chatuchak',
      monthlyPrice: 4500,
      isAvailable: false,
    ),
  ];

  Future<List<Room>> fetchRooms() async {
    if (useMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return List<Room>.from(_mockRooms);
    }

    final uri = Uri.parse('$baseUrl/api/rooms');
    final response = await (_client ?? http.Client()).get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load rooms (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => Room.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRoom({
    required String title,
    required String location,
    required int monthlyPrice,
  }) async {
    if (useMockMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final nextId = _mockRooms.isEmpty
          ? 1
          : _mockRooms.map((room) => room.id).reduce((a, b) => a > b ? a : b) +
                1;
      _mockRooms.insert(
        0,
        Room(
          id: nextId,
          title: title,
          location: location,
          monthlyPrice: monthlyPrice,
          isAvailable: true,
        ),
      );
      return;
    }

    final uri = Uri.parse('$baseUrl/api/rooms');
    final payload = {
      'title': title,
      'location': location,
      'monthly_price': monthlyPrice,
    };

    final response = await (_client ?? http.Client()).post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create room (${response.statusCode})');
    }
  }
}
