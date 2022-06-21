import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  var cityName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
            child: Container(
              child: TextField(
                controller: TextEditingController(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Search City by Zip & Country code in ISO 3166 seperated by comma",
                ),
                onSubmitted: (value){
                  cityName = value;
                  Navigator.pop(context, cityName);
                },
              ),
            ),
          )
      ),
    );
  }
}
