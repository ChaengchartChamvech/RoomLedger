import 'package:flutter/material.dart';
//import 'package:flutter_application_68test_vscode/home.dart';
import 'room_list_screen.dart';
import 'package:http/http.dart' as http;

class introPage extends StatefulWidget {
  const introPage({super.key});

  @override
  State<introPage> createState() => _IntroPageState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

Future<void> registerUser() async {
  // 10.0.2.2 points to your computer's "localhost" from the emulator
  var url = Uri.parse('http://localhost/register.php'); 
  
  try {
    var response = await http.post(url, body: {
      "email": emailController.text,
      "password": passwordController.text,
    });

    if (response.statusCode == 200) {
      print("Server Response: ${response.body}");
      // You can show a SnackBar here to tell the user it worked!
    }
  } catch (e) {
    print("Connection Error: $e");
  }
}




class _IntroPageState extends State<introPage> {

  Future<void> loginUser() async {
  var url = Uri.parse('http://localhost/login.php');

  try {
    var response = await http.post(url, body: {
      "email": emailController.text,
      "password": passwordController.text,
    });

    if (response.statusCode == 200) {
      if (response.body.trim() == "success") {
        // SUCCESS! Navigate to the Home screen
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RoomListPage()),
        );
      }
    }
  } catch (e) {
    print("Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RoomLedger',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Please sign into your account',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                'Enter your email and password to sign in!',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email@domain.com',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: loginUser,
                child: const Text('Sign In'),
              ),
              SizedBox(height: 20),
              Text('Don\'t have an account? Sign Up!'),
              ElevatedButton(onPressed: registerUser, child: Text('Sign Up!')),
            ],
          ),
        ),
      ),
    );
  }
}
