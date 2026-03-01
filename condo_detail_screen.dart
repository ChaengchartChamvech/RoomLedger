import 'package:flutter/material.dart';
import 'package:flutter_application_68test_vscode/condo.dart';

class CondoDetailScreen extends StatelessWidget {
  final Condo condo; // This is the passed data

  const CondoDetailScreen({super.key, required this.condo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(condo.title)),
      body: Column(
        children: [
          Image.network(condo.imageUrl),
          Text("Rating: ${condo.rating} / 5.0"),
          Text("Price: \$${condo.price}"),
          Text("Location: ${condo.location}"),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(condo.desc),
          ),
        ],
      ),
    );
  }
}