import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LedDevice {

  String name;
  IconData icon;
  Color color;

  bool isOn;
  double brightness;

  LedDevice({
    required this.name,
    required this.icon,
    required this.color,
    this.isOn = false,
    this.brightness = 0.5,
  });
}

class LedService {

  static String baseUrl = "http://192.168.1.63";

  static Future<void> loadIp() async {
    final prefs = await SharedPreferences.getInstance();
final ip = prefs.getString('esp32_ip') ?? '192.168.1.63';
baseUrl = "http://$ip";
}

  static final devices = [

    LedDevice(
      name: "Desk LED",
      icon: Icons.lightbulb,
      color: Colors.purpleAccent,
    ),

    LedDevice(
      name: "Monitor",
      icon: Icons.monitor,
      color: Colors.blueAccent,
    ),
  ];

  static Future systemOn() async {
    await http.get(
      Uri.parse("$baseUrl/system/on"),
    );
  }

  static Future systemOff() async {
    await http.get(
      Uri.parse("$baseUrl/system/off"),
    );
  }

  static Future rainbow() async {
    await http.get(
      Uri.parse("$baseUrl/rainbow"),
    );
  }

  static Future breathing() async {
    await http.get(
      Uri.parse("$baseUrl/breathing"),
    );
  }

  static Future staticMode() async {
    await http.get(
      Uri.parse("$baseUrl/static"),
    );
  }

  static Future motionOn() async {
    await http.get(
      Uri.parse("$baseUrl/condition/motion/on"),
    );
  }

  static Future motionOff() async {
    await http.get(
      Uri.parse("$baseUrl/condition/motion/off"),
    );
  }

  static Future darknessOn() async {
    await http.get(
      Uri.parse("$baseUrl/condition/darkness/on"),
    );
  }

  static Future darknessOff() async {
    await http.get(
      Uri.parse("$baseUrl/condition/darkness/off"),
    );
  }

  static Future fire() async {
  await http.get(
    Uri.parse("$baseUrl/fire"),
  );
}

static Future aurora() async {
  await http.get(
    Uri.parse("$baseUrl/aurora"),
  );
}

static Future deviceOn(int id) async {
  await http.get(
    Uri.parse("$baseUrl/device/$id/on"),
  );
}

static Future deviceOff(int id) async {
  await http.get(
    Uri.parse("$baseUrl/device/$id/off"),
  );
}

static Future<void> setBrightness(double value) async {

  int brightness = (value * 255).toInt();

  await http.get(
    Uri.parse(
      "$baseUrl/brightness?value=$brightness",
    ),
  );
}

static Future<void> setColor(
  int r,
  int g,
  int b,
) async {

  await http.get(
    Uri.parse(
      "$baseUrl/color?r=$r&g=$g&b=$b",
    ),
  );
}

}