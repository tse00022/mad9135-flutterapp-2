import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: Theme.of(context).textTheme.copyWith(
                bodyLarge: TextStyle(fontSize: 20.0, color: Colors.white),
              )),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = <Widget>[
    const HomePage(),
    const DataPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home), // Wrapped Icons in Icon widget
            label: 'Home', // Changed 'title' to 'label'
          ),
          NavigationDestination(
            icon: Icon(Icons.data_usage), // Wrapped Icons in Icon widget
            label: 'Data', // Changed 'title' to 'label'
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Transform.rotate(
                  angle: 0.15,
                  child: Text(
                    'Hello World',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Product>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  leading: Image.network(snapshot.data![index].thumbnail),
                );
              },
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Future<List<Product>> fetchData() async {
    var response = await http.get(Uri.parse("https://dummyjson.com/products"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> jsonData = responseData['products'];

      return jsonData
          .map((data) => Product(
                id: data['id'],
                title: data['title'],
                description: data['description'],
                thumbnail: data['thumbnail'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
  });
}
