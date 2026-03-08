import 'package:flutter/material.dart';
import 'room_list_screen.dart';
import 'profile_page.dart';
import 'history_page.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _backgroundColor = Color.fromARGB(255, 2, 103, 150);
  int _navIndex = 0;
  final List<AppBar> _appBar = [
    AppBar(title: Center(child: Text('Home')), backgroundColor: _backgroundColor,),
    AppBar(title: Center(child: Text('History')), backgroundColor: _backgroundColor,),
    AppBar(title: Center(child: Text('Profile')), backgroundColor: _backgroundColor,),
  ];
  final List<Widget> _pages = [
    RoomListPage(),
    HistoryPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar[_navIndex], 
      body: _pages[_navIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _navIndex,
        onTap: (i) => setState(() {
          _navIndex = i;
        }),
      ),
    );
  }
}
