import 'package:flutter/material.dart';
import 'package:ea8_doce/screens/city_screen.dart';
import 'package:ea8_doce/services/networking.dart';
import 'package:ea8_doce/utilities/constants.dart';
import 'package:ea8_doce/services/weather.dart';
import 'dart:convert';
// ignore: must_be_immutable

class LocationScreen extends StatefulWidget {
  LocationScreen(this.data, {super.key});
  String data;


  @override
  State<LocationScreen> createState() => _LocationScreenState();
}


class _LocationScreenState extends State<LocationScreen> {
  double temp = 0;
  int id = 0;
  String city = '', info = '', weathericon = '', weathermsg = '', update = '';
  bool error = false;

  @override
  void initState() {
    super.initState();
    info = widget.data;
    updateUI();
  }

  void updateUI() {
    setState(() {
      city = jsonDecode(info)['name'];
      temp = jsonDecode(info)['main']['temp'];
      id = jsonDecode(info)['weather'][0]['id'];
      error = false;
      print(city);
      print(temp);
      print(id);
      print(info);

      WeatherModel weatherModel = new WeatherModel();
      weathericon = weatherModel.getWeatherIcon(id);
      weathermsg = weatherModel.getMessage(temp.toInt());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      Networking netting = new Networking();
                      update = await netting.getData();
                      setState(() {
                        info = update;
                        updateUI();
                        error = false;
                      });
                    },
                    child: const Icon(
                      Icons.near_me, //eto yung default location btn
                      size: 50.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      String newcity;
                      newcity = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const CityScreen();
                      }));
                      Networking netted = new Networking();

                      try {
                        update = await netted.getCity(newcity);

                        setState(() {
                          info = update;
                          updateUI();
                          error = false;
                        });
                      } catch (e) {
                        setState(() {
                          weathermsg = e.toString();
                          city = "";
                          error = true;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.location_city,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    if (!error)
                      Text(
                        temp.toStringAsFixed(0) + '°', //eto yung temp ng city
                        style: kTempTextStyle,
                      ),
                    Text(
                      error ? 'Error' : weathericon,
                      style: kConditionTextStyle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(
                  error
                      ? weathermsg
                      : "$weathermsg in $city", //eto yung text message
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
