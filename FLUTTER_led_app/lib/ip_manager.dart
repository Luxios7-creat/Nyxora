import 'package:shared_preferences/shared_preferences.dart';

class IpManager {

  static Future<String> getIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('esp32_ip') ?? '192.168.1.63';
  }

  static Future<void> saveIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp32_ip', ip);
  }

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_ips') ?? [];
  }

  static Future<void> saveFavorites(List<String> ips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_ips', ips);
  }
}