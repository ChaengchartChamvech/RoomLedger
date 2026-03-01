import 'package:flutter/material.dart';
import 'package:flutter_application_68test_vscode/Condo_list.dart';
import 'package:flutter_application_68test_vscode/condo_detail_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              itemCount: CondoList.items.length,
              itemBuilder: (context, index) {
                final product = CondoList.items[index];
                return ListTile(
                  leading: Image.network(product.imageUrl, width: 50),
                  title: Text(product.title),
                  subtitle: Text("${product.location} - \$${product.price}"),
                  onTap: () {
                    // NAVIGATE to Detail Screen and PASS the product object
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CondoDetailScreen(condo: product),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: null),
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: null),
            IconButton(icon: Icon(Icons.person), onPressed: null),
          ],
        ),
      ),
    );
  }
}
