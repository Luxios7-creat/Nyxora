import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'led_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool systemEnabled = true;

  bool motionCondition = false;
  bool darknessCondition = false;

  double globalBrightness = 0.7;

  Color selectedColor = Colors.purpleAccent;

  int selectedScene = 0;

  final scenes = [
    {"icon": Icons.air, "name": "Breathing"},

    {"icon": Icons.gradient, "name": "Rainbow"},

    {"icon": Icons.blur_on, "name": "Static"},

    {"icon": Icons.local_fire_department, "name": "Fire"},

    {"icon": Icons.auto_awesome, "name": "Aurora"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              selectedColor.withValues(alpha: 0.15),
              const Color(0xFF050816),
              const Color(0xFF02030A),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),

                const SizedBox(height: 30),

                buildHeroCard(),

                if (!systemEnabled)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        "System disabled",
                        style: TextStyle(color: Colors.white38, fontSize: 22),
                      ),
                    ),
                  ),

                if (systemEnabled) ...[
                  const SizedBox(height: 35),

                  buildConditions(),

                  const SizedBox(height: 35),

                  buildLightsTitle(),

                  const SizedBox(height: 20),

                  buildLightControls(),

                  const SizedBox(height: 35),

                  buildScenes(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Welcome back",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),

            SizedBox(height: 8),

            Text(
              "Indie Room",
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Control your lights, your vibe.",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: glowContainer(
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildHeroCard() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1145), Color(0xFF0A0918)],
        ),

        boxShadow: [
          BoxShadow(
            color: selectedColor.withValues(alpha: 0.25),
            blurRadius: 35,
            spreadRadius: 2,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Smart Lighting",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "System Power",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Switch(
                value: systemEnabled,

                activeThumbColor: selectedColor,

                onChanged: (value) async {
                  setState(() {
                    systemEnabled = value;
                  });

                  if (value) {
                    await LedService.systemOn();
                  } else {
                    await LedService.systemOff();
                  }
                },
              ),
            ],
          ),

          const Spacer(),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),

            height: 70,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              color: systemEnabled
                  ? selectedColor.withValues(alpha: 0.15)
                  : Colors.redAccent.withValues(alpha: 0.15),

              border: Border.all(
                color: systemEnabled ? selectedColor : Colors.redAccent,
              ),
            ),

            child: Center(
              child: Text(
                systemEnabled ? "SYSTEM ONLINE" : "SYSTEM OFFLINE",

                style: TextStyle(
                  color: systemEnabled ? selectedColor : Colors.redAccent,

                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Conditions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: conditionCard(
                icon: Icons.directions_run,
                title: "Motion",

                value: motionCondition,

                onChanged: (value) async {
                  setState(() {
                    motionCondition = value;
                  });

                  if (value) {
                    await LedService.motionOn();
                  } else {
                    await LedService.motionOff();
                  }
                },
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: conditionCard(
                icon: Icons.dark_mode,
                title: "Darkness",

                value: darknessCondition,

                onChanged: (value) async {
                  setState(() {
                    darknessCondition = value;
                  });

                  if (value) {
                    await LedService.darknessOn();
                  } else {
                    await LedService.darknessOff();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLightsTitle() {
    return const Text(
      "Lights",
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildLightControls() {
    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Color",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,

                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF111827),

                      title: const Text(
                        "Choose a color",
                        style: TextStyle(color: Colors.white),
                      ),

                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,

                          onColorChanged: (Color color) async {
                            setState(() {
                              selectedColor = color;
                            });

                            await LedService.setColor(
                              color.red,
                              color.green,
                              color.blue,
                            );
                          },
                        ),
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },

              child: Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor,

                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.6),
                      blurRadius: 25,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          const Text(
            "Brightness",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Slider(
            value: globalBrightness,

            activeColor: selectedColor,

            inactiveColor: Colors.white12,

            onChanged: (value) async {
              setState(() {
                globalBrightness = value;
              });

              await LedService.setBrightness(value);
            },
          ),

          Align(
            alignment: Alignment.centerRight,

            child: Text(
              "${(globalBrightness * 100).toInt()}%",

              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScenes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Scenes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 120,

          child: ListView.builder(
            scrollDirection: Axis.horizontal,

            itemCount: scenes.length,

            itemBuilder: (_, index) {
              final selected = selectedScene == index;

              final scene = scenes[index];

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedScene = index;
                  });

                  final sceneName = scene["name"];

                  if (sceneName == "Rainbow") {
                    await LedService.rainbow();
                  }

                  if (sceneName == "Breathing") {
                    await LedService.breathing();
                  }

                  if (sceneName == "Static") {
                    await LedService.staticMode();
                  }

                  if (sceneName == "Fire") {
                    await LedService.fire();
                  }

                  if (sceneName == "Aurora") {
                    await LedService.aurora();
                  }
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  width: 100,

                  margin: const EdgeInsets.only(right: 16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),

                    color: selected
                        ? selectedColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),

                    border: Border.all(
                      color: selected ? selectedColor : Colors.white10,
                    ),

                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: selectedColor.withValues(alpha: 0.5),
                              blurRadius: 25,
                            ),
                          ]
                        : [],
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(
                        scene["icon"] as IconData,

                        size: 34,

                        color: selected ? selectedColor : Colors.white70,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        scene["name"].toString(),

                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget conditionCard({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Icon(icon, color: selectedColor, size: 30),

              Switch(
                value: value,

                activeThumbColor: selectedColor,

                onChanged: onChanged,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value ? "Enabled" : "Disabled",

            style: TextStyle(color: value ? selectedColor : Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),

            color: Colors.white.withValues(alpha: 0.05),

            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),

          child: child,
        ),
      ),
    );
  }

  Widget glowContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: selectedColor.withValues(alpha: 0.12),

        boxShadow: [
          BoxShadow(
            color: selectedColor.withValues(alpha: 0.5),
            blurRadius: 25,
          ),
        ],
      ),

      child: child,
    );
  }
}
