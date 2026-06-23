#include <WiFi.h>
#include <WebServer.h>
#include <FastLED.h>
#include <BH1750.h>

BH1750 lightMeter;
// ===================== WIFI =====================
const char* ssid = "SSID";
const char* password = "PASSWORD";

WebServer server(80);

// ===================== LED =====================
#define LED_PIN 18
#define NUM_LEDS 144
CRGB leds[NUM_LEDS];

// ===================== SENSORS =====================
#define PIR_PIN 32

const int lightThreshold = 2.5;

// ===================== STATE =====================
bool systemEnabled = true;

bool motionEnabled = false;
bool darknessEnabled = false;

bool motionDetected = false;
int lightLevel = 0;

bool conditionOK = true;

unsigned long lastMotionTime = 0;
const unsigned long holdTime = 10000;  // 10 secondes

float fadeBrightness = 1.0;
bool fading = false;

// ===================== LIGHT CONTROL =====================
uint8_t globalBrightness = 150;
CRGB selectedColor = CRGB::Purple;

// ===================== EFFECT STATE =====================
String currentEffect = "off";

// ===================== UTILS =====================
void applyShow() {
  FastLED.setBrightness(globalBrightness * fadeBrightness);
  FastLED.show();
}

CHSV baseHSV() {
  return rgb2hsv_approximate(selectedColor);
}

// ===================== SENSOR LOGIC =====================
void updateConditions() {

  motionDetected = digitalRead(PIR_PIN);
  float lux = lightMeter.readLightLevel();

  // ================= MOTION =================
  bool motionOK = true;

  if (motionEnabled) {
    
    if (motionDetected) {
      lastMotionTime = millis();
      if (motionDetected) {
        fading = false;
      }
    }

    motionOK =
      (millis() - lastMotionTime < holdTime);
  }

  // ================= DARKNESS =================
  bool darknessOK = true;

  if (darknessEnabled) {

    darknessOK = (lux < lightThreshold);
  }

  // ================= FINAL =================
  conditionOK =
    systemEnabled && motionOK && darknessOK;
}

void updateFade() {

  // Si mouvement détecté
  if (motionDetected || !motionEnabled) {

    fading = false;

    fadeBrightness += 0.03;

    if (fadeBrightness > 1.0) {
      fadeBrightness = 1.0;
    }

    return;
  }

  // Lance le fade après holdTime
  if (millis() - lastMotionTime > holdTime) {
    fading = true;
  }

  // Fade OUT
  if (fading) {

    fadeBrightness -= 0.01;

    if (fadeBrightness < 0) {
      fadeBrightness = 0;
    }
  }
}
// ===================== EFFECTS =====================
void effectOff() {
  FastLED.clear();
  applyShow();
}

void effectStatic() {
  fill_solid(leds, NUM_LEDS, selectedColor);
  applyShow();
}

void effectRainbow() {
  static uint8_t hue = 0;

  fill_rainbow(leds, NUM_LEDS, hue++, 7);
  applyShow();

  delay(20);
}

void effectBreathing() {
  static uint16_t t = 0;
  t++;

  uint8_t breath = beatsin8(6, 20, globalBrightness);

  CHSV base = baseHSV();
  uint8_t shift = sin8(t / 3) / 12;

  CHSV c = CHSV(base.hue + shift, base.saturation, breath);

  fill_solid(leds, NUM_LEDS, c);
  applyShow();

  delay(20);
}

void effectFire() {

  CHSV base = baseHSV();
  uint8_t hue = constrain(base.hue, 0, 40);

  for (int i = 0; i < NUM_LEDS; i++) {

    uint8_t flicker = random8(globalBrightness / 2, globalBrightness);

    leds[i] = CHSV(
      hue + random8(10),
      255,
      flicker);
  }

  applyShow();
  delay(40);
}

void effectAurora() {

  static uint8_t wave = 0;
  wave += 2;

  CHSV base = baseHSV();

  for (int i = 0; i < NUM_LEDS; i++) {

    uint8_t noise = sin8(i * 10 + wave);

    leds[i] = CHSV(
      base.hue + noise / 10,
      base.saturation,
      globalBrightness);
  }

  applyShow();
  delay(25);
}

// ===================== ROUTER =====================
void handleEffect() {

  if (currentEffect == "static") effectStatic();
  else if (currentEffect == "rainbow") effectRainbow();
  else if (currentEffect == "breathing") effectBreathing();
  else if (currentEffect == "fire") effectFire();
  else if (currentEffect == "aurora") effectAurora();
  else effectOff();
}

// ===================== SETUP =====================
void setup() {

  Serial.begin(115200);

  Wire.begin(21, 22);

  lightMeter.begin();

  pinMode(PIR_PIN, INPUT);

  FastLED.addLeds<WS2812, LED_PIN, GRB>(leds, NUM_LEDS);
  FastLED.clear();
  FastLED.show();

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi OK");
  Serial.println(WiFi.localIP());

  // ================= SYSTEM =================
  server.on("/system/on", []() {
    systemEnabled = true;
    server.send(200, "text/plain", "ON");
  });

  server.on("/system/off", []() {
    systemEnabled = false;
    effectOff();
    server.send(200, "text/plain", "OFF");
  });

  // ================= EFFECTS =================
  server.on("/static", []() {
    currentEffect = "static";
    server.send(200, "text/plain", "static");
  });

  server.on("/rainbow", []() {
    currentEffect = "rainbow";
    server.send(200, "text/plain", "rainbow");
  });

  server.on("/breathing", []() {
    currentEffect = "breathing";
    server.send(200, "text/plain", "breathing");
  });

  server.on("/fire", []() {
    currentEffect = "fire";
    server.send(200, "text/plain", "fire");
  });

  server.on("/aurora", []() {
    currentEffect = "aurora";
    server.send(200, "text/plain", "aurora");
  });

  // ================= COLOR =================
  server.on("/color", []() {
    if (server.hasArg("r") && server.hasArg("g") && server.hasArg("b")) {

      selectedColor = CRGB(
        server.arg("r").toInt(),
        server.arg("g").toInt(),
        server.arg("b").toInt());

      server.send(200, "text/plain", "color OK");
    } else {
      server.send(400, "text/plain", "missing RGB");
    }
  });

  // ================= BRIGHTNESS =================
  server.on("/brightness", []() {
    if (server.hasArg("value")) {

      globalBrightness = server.arg("value").toInt();

      server.send(200, "text/plain", "brightness OK");
    } else {
      server.send(400, "text/plain", "missing value");
    }
  });

  // ================= CONDITIONS =================
  server.on("/condition/motion/on", []() {
    motionEnabled = true;
    server.send(200, "text/plain", "motion ON");
  });

  server.on("/condition/motion/off", []() {
    motionEnabled = false;
    server.send(200, "text/plain", "motion OFF");
  });

  server.on("/condition/darkness/on", []() {
    darknessEnabled = true;
    server.send(200, "text/plain", "darkness ON");
  });

  server.on("/condition/darkness/off", []() {
    darknessEnabled = false;
    server.send(200, "text/plain", "darkness OFF");
  });

  server.begin();
}

// ===================== LOOP =====================
void loop() {

  server.handleClient();

  updateConditions();

  updateFade();

  // SYSTEM OFF
  if (!systemEnabled) {
    effectOff();
    return;
  }

  // Conditions non remplies
  if (!conditionOK && fadeBrightness <= 0) {
    effectOff();
    return;
  }

  // Conditions OK
  if (conditionOK) {
    handleEffect();
  }
}
