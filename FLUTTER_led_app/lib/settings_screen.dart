import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ipController = TextEditingController();

  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      ipController.text =
          prefs.getString('esp32_ip') ?? '192.168.1.63';

      favorites =
          prefs.getStringList('favorite_ips') ?? [];
    });
  }

  Future<void> saveIp() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'esp32_ip',
      ipController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("IP enregistrée"),
        ),
      );
    }
  }

  Future<void> addFavorite() async {
    final ip = ipController.text.trim();

    if (ip.isEmpty) return;

    if (!favorites.contains(ip)) {
      favorites.add(ip);

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setStringList(
        'favorite_ips',
        favorites,
      );

      setState(() {});
    }
  }

  Future<void> removeFavorite(String ip) async {
    favorites.remove(ip);

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      'favorite_ips',
      favorites,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "ESP32 IP Address",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: ipController,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "192.168.1.63",
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveIp,
                    child: const Text("Save"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: addFavorite,
                    child: const Text("Add Favorite"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Favorite IPs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: favorites.length,

                itemBuilder: (context, index) {
                  final ip = favorites[index];

                  return Card(
                    child: ListTile(
                      title: Text(ip),

                      onTap: () {
                        setState(() {
                          ipController.text = ip;
                        });
                      },

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),

                        onPressed: () {
                          removeFavorite(ip);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}