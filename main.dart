import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;          //knihovny, zatím jen základ a http aby fungoval http.post

postData()async{                                  //tady je úplně ZÁKLAD toho celýho, BEZ TOHO TO NEPOSÍLÁ!!!!  
  try {
var response = await http.post(
Uri.parse('https://gstapp.panska.cz/zkouska.php'),
body: {"id":1.toString(), "name":"ahoj"});
print(response.body);
  }
  catch (e) {
    print(e);
  }
}

void main() {                                   //void a jedeme
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});                         //tady se definuje MyApp

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(                  //zde tlačítko co to posílá
          onPressed: () {
            postData();
          },
          child: const Text('Submit Data'),
        ),
      ),
    );
  }
}