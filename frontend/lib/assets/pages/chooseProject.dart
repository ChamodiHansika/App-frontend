import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'new.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ListItem());
}

class ListItem extends StatefulWidget {
  const ListItem({Key? key}) : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    getProjects(context);
  }

  Future<String> getTokenFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return token;
  }

  void getProjects(BuildContext context) async {
    String a = await getTokenFromSharedPreferences();
    print('Text was clicked ${a}');
    final response = await http.get(
      Uri.parse('http://192.168.1.9:4000/api/project'),
      headers: {'Authorization': 'Bearer ${a}'},
    );
    final responseData = jsonDecode(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        _items = responseData.map((item) => item['projectname']).toList();
        print(_items);
      });
    } else if (response.statusCode == 401) {
      print('Request is not authorized');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Login()));
    } else {
      print('Request failed with status: ${response.statusCode}.');
      final errorMessage = responseData['error'];
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      body: Column(
        children: [
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Choose \n your project',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(width: 2, color: Colors.black),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyJobs(),
                              ),
                            );
                          },
                          title: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _items[index],
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage(
                                  'https://as2.ftcdn.net/v2/jpg/04/33/76/69/1000_F_433766963_8gZOOwnAHgrsSl1MMEi4t712X1ZD8d66.jpg'),
                            ),
                            subtitle: const Text(
                              'Started July 12',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      },
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

