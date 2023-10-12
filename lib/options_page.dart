// import 'package:dynamic_color/dynamic_color.dart';
import 'dart:io' show Platform;
// import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soyabean/main.dart';
import 'package:soyabean/welcome_page.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// void loadThemePreference() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   isDynamicColoringEnabled = prefs.getBool('isDynamicColoringEnabled') ?? false;
// }

// bool _isDynamicColoringEnabled = isDynamicColoringEnabled;

class DynamicThemeProvider with ChangeNotifier {
  // bool _isDynamicColoringEnabled =
  //     isFirstTime ? isDynamicColorsSupported() : isDynamicColoringEnabled;
  bool _isDynamicColoringEnabled = meow;

  bool get isDynamicColoringEnabled => _isDynamicColoringEnabled;

  void toggleTheme(bool isDynamicColoringEnabled) {
    _isDynamicColoringEnabled = isDynamicColoringEnabled;
    notifyListeners();
  }
}

// String androidVersion = "0";

// Future<void> checkDynamicColorsSupport() async {
//   if (Platform.isAndroid) {
//     final androidVersion = await getAndroidVersion();
//     if (int.parse(androidVersion) >= 12) {
//       bool isDynamicColorsSupportedBool = true;
//     } else if (int.parse(androidVersion) < 12) {
//       bool isDynamicColorsSupportedBool = false;
//     }
//   }
// }

bool isDynamicColorsSupported() {
  void saveThemePreference(bool isDynamicColoringEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDynamicColoringEnabled', isDynamicColoringEnabled);
  }

  if (Platform.isAndroid) {
    getAndroidVersion();
    // Material You (dynamic system colors) is available on Android 12 (API level 31) and later.
    if (int.parse(androidVersion) >= 12) {
      // Fluttertoast.showToast(
      //   msg: "Android version is $androidVersion",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.CENTER,
      // );
      saveThemePreference(true);
      return true;
    } else if (int.parse(androidVersion) < 12) {
      // Fluttertoast.showToast(
      //   msg: "Android version is $androidVersion",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.CENTER,
      // );
      return false;
    }
  }
  return false;
}

Future<String> getAndroidVersion() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    // final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    androidVersion = androidInfo.version.release;
    return androidVersion;
  }
  return "1";
  // return "Not Android";
}

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

// bool showWelcomePage = true;

class _OptionsPageState extends State<OptionsPage> {
  bool isDynamicColoringEnabled = false;

  @override
  void initState() {
    super.initState();
    readIsDynamicColorsSupportedBool();
    // loadWelcomePageState();
    // loadThemePreference();
  }

  void saveWelcomePageState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomePage', value);
  }

  void loadWelcomePageState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showWelcomePage = prefs.getBool('showWelcomePage') ?? true;
    });
  }

  void readIsDynamicColorsSupportedBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDynamicColorsSupportedBool =
          prefs.getBool('isDynamicColorsSupportedBool') ?? false;
    });
  }

  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDynamicColoringEnabled =
          prefs.getBool('isDynamicColoringEnabled') ?? false;
      tester =
          'valueVar: - , isDynamicColoringEnabled: $isDynamicColoringEnabled';
    });
  }

  void saveThemePreference(bool isDynamicColoringEnabledVar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'isDynamicColoringEnabled', isDynamicColoringEnabledVar);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    // bool isDynamicColoringSupported = isDynamicColorsSupported();
    bool isDynamicColoringSupported = isDynamicColorsSupportedBool;
    // return originalScaffold(colorScheme);
    return Consumer<DynamicThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: (brightness == Brightness.light)
              ? colorScheme.surfaceVariant
              : colorScheme.background,
          appBar: AppBar(
            backgroundColor: (brightness == Brightness.light)
                ? colorScheme.surfaceVariant
                : colorScheme.background,
            title: const Text('Options'),
            centerTitle: true,
          ),
          body: ListView(
            children: <Widget>[
              IgnorePointer(
                ignoring: !isDynamicColoringSupported,
                child: Opacity(
                  opacity: isDynamicColoringSupported ? 1.0 : 0.5,
                  child: SwitchListTile(
                    title: const Text('Use System colors'),
                    subtitle: const Text('Use Material3\'s dynamic colors'),
                    value: themeProvider
                        .isDynamicColoringEnabled, // You can set the initial value here
                    onChanged: (bool value) {
                      // Handle toggle switch state changes
                      setState(() {
                        isDynamicColoringEnabled = value;
                        themeProvider.toggleTheme(value);
                        saveThemePreference(value);
                      });
                    },
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Show Welcome Page'),
                subtitle: const Text('When app is opened'),
                value: showWelcomePage, // You can set the initial value here
                onChanged: (bool value) {
                  // Handle toggle switch state changes
                  setState(() {
                    showWelcomePage = value;
                    saveWelcomePageState(value);
                  });
                },
              ),
              ListTile(
                title: Text(tester),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  tester = 'tester $tester';
                  loadThemePreference();
                  // Navigate to a detailed notification settings page
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Scaffold originalScaffold(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Options'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Use Material 3 theming'),
            value:
                isDynamicColoringEnabled, // You can set the initial value here
            onChanged: (bool value) {
              // Handle toggle switch state changes
              setState(() {
                isDynamicColoringEnabled = value;
                saveThemePreference(value);
              });
            },
          ),
          ListTile(
            title: const Text('dummy setting'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to a detailed notification settings page
            },
          ),
        ],
      ),
    );
  }
}
