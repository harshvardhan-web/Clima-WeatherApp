import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clima_weather_app/search_screen.dart';
import 'package:clima_weather_app/permission.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Clima-The Weather App",
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Clima(),
        ),
      ),
    );
  }
}


class Clima extends StatefulWidget {
  const Clima({Key? key}) : super(key: key);

  @override
  State<Clima> createState() => _ClimaState();
}

class _ClimaState extends State<Clima> {

  var lat, long, tz, temp, desc, er, ic, url,location, img = "images/default.jpg";
  String weatherIcon = "";

  @override void initState() {
    super.initState();
    getLocation();
  }

  void getCityWeather() async {
    if(location!=null){
      var url2 = Uri.https("api.openweathermap.org","/geo/1.0/direct",{'q': "$location", 'limit': '1' ,'appid' : "9b1680d0abb39afacbb3b2347e8595e3"});
      var response = await http.get(url2);
      if(response.statusCode == 200){
        setState((){
          var res = jsonDecode(response.body);
          lat = res[0]["lat"];
          long = res[0]["lon"];
          print("Lat: $lat, Long: $long");
          getResults();
        });
      }else{
        print("An error occurred: ${response.statusCode}");
      }
    }else{
      print("Please enter a valid location");
    }
  }

  void getLocation() async {
    Position pos = await determinePosition();

    lat = pos.latitude;
    long = pos.longitude;
    print("Lat is: $lat");
    print("Long is: $long");

    getResults();
  }

  void getResults() async {
    var url = Uri.https("api.openweathermap.org","/data/2.5/onecall", {'lat': '$lat', 'lon' : '$long', 'exclude': 'hourly,daily', 'units' : 'metric' , 'appid' : "9b1680d0abb39afacbb3b2347e8595e3"});
    var response = await http.get(url);
    if(response.statusCode == 200){
      setState((){
        var res = jsonDecode(response.body);
        temp = res["current"]["temp"];
        desc = res["current"]["weather"][0]["description"];
        print(desc);
        var cond = res["current"]["weather"][0]["main"];
        if(cond == "Clear"){
          img = "images/sunny.gif";
          weatherIcon = "☀️";
        }else if(cond == "Thunderstorm"){
          img = "images/thunderstorm.gif";
          weatherIcon = "⛈";
        }else if(cond == "Drizzle" || cond == "Rain"){
          img = "images/rain.gif";
          weatherIcon = "☔️";
        }else if(cond == "Snow"){
          img = "images/snow.gif";
          weatherIcon = "❄️";
        }else if(cond == "Clouds"){
          img = "images/scattered_clouds.gif";
          weatherIcon = "☁️";
        }else{
          img = "images/foggy-fog.gif";
          weatherIcon = "ð";
        }
      });
    }else{
      var er = "Response Failed with status code: ${response.statusCode}.";
    }
    print(img);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(img),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: (){
                      location = null;
                      getLocation();
                    },
                    child: Icon(Icons.navigation, color: Colors.white, size: 60,)
                ),
                TextButton(
                    onPressed: () async {
                      location = await Navigator.push(context, MaterialPageRoute(builder: (context){
                        return Search();
                      }));
                      print(location);
                      getCityWeather();
                    },
                    child: Icon(Icons.keyboard_alt_outlined, color: Colors.white, size: 60,)
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (location==null)? " $temp°C Outside $weatherIcon.":"$temp°C $location $weatherIcon.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 40,
                      backgroundColor: Colors.black45,
                    ),
                  ),
                  Text(
                    "Best way to explain it is \"$desc\".",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        backgroundColor: Colors.black45
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
