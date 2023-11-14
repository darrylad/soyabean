import 'dart:io' show Platform;
// import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soyabean/about_page.dart';
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/description_page.dart';
import 'package:soyabean/main.dart';
import 'package:soyabean/url_text_input_dialog.dart';
import 'package:soyabean/welcome_page.dart';

String uploadText = (isDemoModeOn) ? 'Next' : 'Upload';

bool isServerFeatureAvailable = false;

class DynamicThemeProvider with ChangeNotifier {
  // bool _isDynamicColoringEnabled =
  //     isFirstTime ? isDynamicColorsSupported() : isDynamicColoringEnabled;

  bool _isDynamicColoringEnabled = meow;
  bool get isDynamicColoringEnabled => _isDynamicColoringEnabled;

  bool _isLightModeForced = isLightModeForced;
  bool get isLightModeForcedVar => _isLightModeForced;

  void toggleLightMode(bool isLightModeForcedVar) {
    _isLightModeForced = isLightModeForcedVar;
    notifyListeners();
  }

  void toggleTheme(bool isDynamicColoringEnabled) {
    _isDynamicColoringEnabled = isDynamicColoringEnabled;
    notifyListeners();
  }
}

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
  if (Platform.isMacOS) {
    saveThemePreference(true);
    return true;
  }
  if (Platform.isWindows) {
    saveThemePreference(true);
    return true;
  }
  return false;
}

Future<String> getPlatformOS() async {
  void savePlatformOS(String platformOS) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('platformOS', platformOS);
  }

  // final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    // final deviceInfo = DeviceInfoPlugin();
    // AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    platformOS = 'Android';
    savePlatformOS(platformOS);
    return 'Android';
  } else if (Platform.isIOS) {
    // IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    // return iosInfo.systemVersion;
    platformOS = 'iOS';
    savePlatformOS(platformOS);
    return "iOS";
  } else if (Platform.isMacOS) {
    // MacOsDeviceInfo macosInfo = await deviceInfoPlugin.macOsInfo;
    // return macosInfo.majorVersion;
    platformOS = 'macOS';
    savePlatformOS(platformOS);
    return 'macOS';
  } else if (Platform.isWindows) {
    // WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;
    // return windowsInfo.computerName;
    platformOS = 'Windows';
    savePlatformOS(platformOS);
    return 'Windows';
  } else if (Platform.isLinux) {
    // LinuxDeviceInfo linuxInfo = await deviceInfoPlugin.linuxInfo;
    platformOS = 'Linux';
    savePlatformOS(platformOS);
    return 'Linux';
  }
  return "Unknown";
}

Future<String> getAndroidVersion() async {
  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    androidVersion = androidInfo.version.release;
    return androidVersion;
  }
  return "0";
  // return "Not Android";
}

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

// bool showWelcomePage = true;
bool useNestedScrollView = false;

class _OptionsPageState extends State<OptionsPage> {
  bool isDynamicColoringEnabled = false;

  @override
  void initState() {
    super.initState();
    readIsDynamicColorsSupportedBool();
    // loadWelcomePageState();
    // loadThemePreference();
  }

  void saveIsLightModeForcedBoolValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightModeForced', value);
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
      // tester =
      //     'valueVar: - , isDynamicColoringEnabled: $isDynamicColoringEnabled';
    });
  }

  void saveThemePreference(bool isDynamicColoringEnabledVar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'isDynamicColoringEnabled', isDynamicColoringEnabledVar);
  }

  void saveAskForUrlEverytime(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('askForUrlEverytime', value);
  }

  void saveIsDemoModeOn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDemoModeOn', value);
  }

  void saveSingleThreadedMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('singleThreadedMode', value);
  }

  void saveImageCropping(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('imageCropping', value);
  }

  void saveImageCropFactor(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('croppMultiplyingFactor', value);
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
        // return originalScaffold(
        //     brightness, colorScheme, isDynamicColoringSupported, themeProvider);

        // return scaffoldUsingNestedScrollView(
        //     brightness, colorScheme, isDynamicColoringSupported, themeProvider);

        // return scaffoldUsingSliverChildListDelegate(
        //     brightness, colorScheme, isDynamicColoringSupported, themeProvider);

        //options
        return useNestedScrollView
            ? scaffoldUsingNestedScrollView(brightness, colorScheme,
                isDynamicColoringSupported, themeProvider)
            : scaffoldUsingSliverChildListDelegate(brightness, colorScheme,
                isDynamicColoringSupported, themeProvider);
      },
    );
  }

  Scaffold scaffoldUsingSliverChildListDelegate(
      Brightness brightness,
      ColorScheme colorScheme,
      bool isDynamicColoringSupported,
      DynamicThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.background,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          leading: null,
          leadingWidth: null,
          automaticallyImplyLeading: false,
          // titlePadding: EdgeInsets.only(left: 24),
          backgroundColor: (brightness == Brightness.light)
              ? colorScheme.surfaceVariant
              : colorScheme.background,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: (brightness == Brightness.light)
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: (brightness == Brightness.light)
                ? colorScheme.background
                : colorScheme.surfaceVariant, // Navigation bar
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: (brightness == Brightness.light)
                ? Brightness.dark
                : Brightness.light, // Status bar
          ),
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            // titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
            title: Text(
              'Options',
              style: TextStyle(
                  color: (brightness == Brightness.light)
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onBackground,
                  fontWeight: FontWeight.w500),
            ),

            centerTitle: true,
          ),
        ),

        // sliverListHavingSliverChildDelegate(
        //     isDynamicColoringSupported, themeProvider),

        sliverListUsingSwitchCases(isDynamicColoringSupported, themeProvider),

        // const SliverFillRemaining(
        //     //     child: SizedBox(
        //     //   height: 20,
        //     // )
        //     ),

        // SliverToBoxAdapter(
        //   child: listOfOptions(isDynamicColoringSupported, themeProvider),
        // ),
      ]),
    );
  }

  SliverList sliverListUsingSwitchCases(
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          ColorScheme colorScheme = Theme.of(context).colorScheme;
          switch (index) {
            case 0:
              return IgnorePointer(
                ignoring: !isDynamicColoringSupported,
                child: Opacity(
                  opacity: isDynamicColoringSupported ? 1.0 : 0.5,
                  child: SwitchListTile(
                    title: const Text('Use system colors'),
                    subtitle: isDynamicColoringSupported
                        ? const Text('Use Material3\'s dynamic colors')
                        : const Text('Not supported'),
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
              );
            case 1:
              return SwitchListTile(
                title: const Text('Show welcome page'),
                subtitle: const Text('When app is opened'),
                value: showWelcomePage, // You can set the initial value here
                onChanged: (bool value) {
                  // Handle toggle switch state changes
                  setState(() {
                    showWelcomePage = value;
                    saveWelcomePageState(value);
                  });
                },
              );
            case 2:
              return SwitchListTile(
                title: const Text('Force light mode'),
                // subtitle: const Text('When app is opened'),
                value: isLightModeForced, // You can set the initial value here
                onChanged: (bool value) {
                  // Handle toggle switch state changes
                  setState(() {
                    isLightModeForced = value;
                    themeProvider.toggleLightMode(value);
                    saveIsLightModeForcedBoolValue(value);
                  });
                },
              );
            case 3:
              return SwitchListTile(
                  title: const Text('Single threaded mode'),
                  subtitle: const Text(
                      'This may cause the app to stutter when processing images. Turn on if processing fails in the defalut mode.'),
                  value: singleThreadedMode,
                  onChanged: (value) {
                    setState(() {
                      singleThreadedMode = value;
                      saveSingleThreadedMode(value);
                    });
                  });
            case 4:
              return SwitchListTile(
                  title: const Text('Image cropping'),
                  subtitle: const Text(
                      'Automatically center crops the image to a square in an attempt to only keep the leaf surface in the image.'),
                  value: imageCropping,
                  onChanged: (value) {
                    setState(() {
                      imageCropping = value;
                      saveImageCropping(value);
                    });
                  });
            case 5:
              return IgnorePointer(
                ignoring: !imageCropping,
                child: Opacity(
                  opacity: imageCropping ? 1.0 : 0.5,
                  child: ListTile(
                    title: const Text('Image crop factor'),
                    subtitle: const Text(
                        'Choose how much the image should be cropped'),
                    // trailing: const Icon(Icons.arrow_forward),
                    trailing: DropdownButton<double>(
                      value: croppMultiplyingFactor,
                      dropdownColor: colorScheme.surfaceVariant,
                      items: const [
                        DropdownMenuItem<double>(
                          value: 0.4,
                          child: Text('0.4'),
                        ),
                        DropdownMenuItem<double>(
                          value: 0.5,
                          child: Text('0.5'),
                        ),
                        DropdownMenuItem<double>(
                          value: 0.6,
                          child: Text('0.6'),
                        ),
                        DropdownMenuItem<double>(
                          value: 0.7,
                          child: Text('0.7'),
                        ),
                        DropdownMenuItem<double>(
                          value: 0.8,
                          child: Text('0.8'),
                        ),
                        DropdownMenuItem<double>(
                          value: 0.9,
                          child: Text('0.9'),
                        ),
                        DropdownMenuItem<double>(
                          value: 1.0,
                          child: Text('No Zoom (1.0)'),
                        ),
                      ],
                      onChanged: (double? newValue) {
                        if (newValue != null) {
                          setState(() {
                            croppMultiplyingFactor = newValue;
                            saveImageCropFactor(newValue);
                          });
                        }
                      },
                    ),
                    // onTap: () {},
                  ),
                ),
              );

            case 6:
              return IgnorePointer(
                ignoring: !isServerFeatureAvailable,
                child: Opacity(
                  opacity: isServerFeatureAvailable ? 1.0 : 0.5,
                  child: SwitchListTile(
                    title: const Text('Ask for server URL everytime'),
                    value: askForUrlEverytime,
                    onChanged: (value) {
                      setState(() {
                        askForUrlEverytime = value;
                        saveAskForUrlEverytime(value);
                      });
                    },
                  ),
                ),
              );
            case 7:
              return IgnorePointer(
                ignoring: !isServerFeatureAvailable,
                child: Opacity(
                  opacity: isServerFeatureAvailable ? 1.0 : 0.5,
                  child: ListTile(
                    title: const Text('Edit server URL'),
                    subtitle: Text(urlText),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SaveUrlDialog();
                      }));
                      setState(() {});
                    },
                  ),
                ),
              );
            case 8:
              return SwitchListTile(
                  title: const Text('Demo mode'),
                  subtitle: const Text('Turns off processing'),
                  value: isDemoModeOn,
                  onChanged: (value) {
                    setState(() {
                      isDemoModeOn = value;
                      uploadText = (isDemoModeOn) ? 'Next' : 'Upload';
                    });
                    saveIsDemoModeOn(value);
                  });
            case 9:
              return ListTile(
                title: const Text('About'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AboutPage();
                  }));
                },
              );
            case 10:
              return SwitchListTile(
                  title: const Text('Use Nested Scroll View'),
                  value: useNestedScrollView,
                  onChanged: ((value) {
                    setState(() {
                      useNestedScrollView = value;
                    });
                  }));
            case 11:
              return ListTile(
                title: Text(tester),
                trailing: const Icon(Icons.question_mark),
                onTap: () {
                  tester = 'tester $tester';
                  loadThemePreference();
                  // Navigate to a detailed notification settings page
                },
              );
            default:
              return const ListTile(
                title: Text('empty list'),
              );
          }
          // return ListTile(
          //   title: Text('Setting $index'),
          //   // Add your settings widgets here
          // );
        },
        childCount: 11, // Adjust this count as needed
      ),
    );
  }

  Scaffold scaffoldUsingNestedScrollView(
      Brightness brightness,
      ColorScheme colorScheme,
      bool isDynamicColoringSupported,
      DynamicThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.background,
      // body: oldCustomScrollView(isDynamicColoringSupported, themeProvider),
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarIconBrightness:
                  (brightness == Brightness.light)
                      ? Brightness.dark
                      : Brightness.light,
              systemNavigationBarColor: (brightness == Brightness.light)
                  ? colorScheme.background
                  : colorScheme.surfaceVariant, // Navigation bar
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: (brightness == Brightness.light)
                  ? Brightness.dark
                  : Brightness.light, // Status bar
            ),
            backgroundColor: (brightness == Brightness.light)
                ? colorScheme.surfaceVariant
                : colorScheme.background,
            // primary: true,
            expandedHeight: 200.0, // Height when expanded
            floating: false, // The title won't float when scrolled down
            pinned: true, // The title stays at the top when scrolled up
            flexibleSpace: FlexibleSpaceBar(
              // titlePadding: const EdgeInsets.fromLTRB(24, 0, 0, 16),
              centerTitle: true,
              title: Text(
                'Options',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: (brightness == Brightness.light)
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onBackground,
                    fontWeight: FontWeight.w500),
              ), // Title
              // titlePadding: EdgeInsets.fromLTRB(24, 0, 0, 0),
              // Background image
            ),
          ),
        ],

        // body: listOfOptions(isDynamicColoringSupported, themeProvider),

        // body: singleChildScrollViewHavingListOfOptions(
        //     isDynamicColoringSupported, themeProvider)

        body: CustomScrollView(
          slivers: [
            sliverListUsingSwitchCases(
                isDynamicColoringSupported, themeProvider),

            // listOfOptions(isDynamicColoringSupported, themeProvider)

            // SliverFillRemaining(
            //   child: listOfOptions(isDynamicColoringSupported, themeProvider),
            // ),

            // SliverFillRemaining(
            //   child: sliverListUsingSwitchCases(
            //       isDynamicColoringSupported, themeProvider),
            // ),

            // SliverFillRemaining(child: Container())
          ],
        ),

        // body: sliverListUsingSwitchCases(
        //     isDynamicColoringSupported, themeProvider),
      ),
    );
  }

  SingleChildScrollView singleChildScrollViewHavingListOfOptions(
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          IgnorePointer(
            ignoring: !isDynamicColoringSupported,
            child: Opacity(
              opacity: isDynamicColoringSupported ? 1.0 : 0.5,
              child: SwitchListTile(
                title: const Text('Use System colors'),
                subtitle: isDynamicColoringSupported
                    ? const Text('Use Material3\'s dynamic colors')
                    : const Text('Not Supported'),
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
          SwitchListTile(
            title: const Text('Force Light Mode'),
            // subtitle: const Text('When app is opened'),
            value: isLightModeForced, // You can set the initial value here
            onChanged: (bool value) {
              // Handle toggle switch state changes
              setState(() {
                isLightModeForced = value;
                themeProvider.toggleLightMode(value);
                saveIsLightModeForcedBoolValue(value);
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
  }

  SliverList sliverListHavingSliverChildDelegate(
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return SliverList(
        delegate: SliverChildListDelegate([
      IgnorePointer(
        ignoring: !isDynamicColoringSupported,
        child: Opacity(
          opacity: isDynamicColoringSupported ? 1.0 : 0.5,
          child: SwitchListTile(
            title: const Text('Use System colors'),
            subtitle: isDynamicColoringSupported
                ? const Text('Use Material3\'s dynamic colors')
                : const Text('Not Supported'),
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
      SwitchListTile(
        title: const Text('Force Light Mode'),
        // subtitle: const Text('When app is opened'),
        value: isLightModeForced, // You can set the initial value here
        onChanged: (bool value) {
          // Handle toggle switch state changes
          setState(() {
            isLightModeForced = value;
            themeProvider.toggleLightMode(value);
            saveIsLightModeForcedBoolValue(value);
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
    ]));
  }

  ListView listOfOptions(
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        IgnorePointer(
          ignoring: !isDynamicColoringSupported,
          child: Opacity(
            opacity: isDynamicColoringSupported ? 1.0 : 0.5,
            child: SwitchListTile(
              title: const Text('Use System colors'),
              subtitle: isDynamicColoringSupported
                  ? const Text('Use Material3\'s dynamic colors')
                  : const Text('Not Supported'),
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
        SwitchListTile(
          title: const Text('Force Light Mode'),
          // subtitle: const Text('When app is opened'),
          value: isLightModeForced, // You can set the initial value here
          onChanged: (bool value) {
            // Handle toggle switch state changes
            setState(() {
              isLightModeForced = value;
              themeProvider.toggleLightMode(value);
              saveIsLightModeForcedBoolValue(value);
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
        ListTile(
          title: Text(tester),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            tester = 'tester $tester';
            loadThemePreference();
            // Navigate to a detailed notification settings page
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
    );
  }

  CustomScrollView oldCustomScrollView(
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          automaticallyImplyLeading: false,
          primary: true,
          expandedHeight: 200.0, // Height when expanded
          floating: false, // The title won't float when scrolled down
          pinned: true, // The title stays at the top when scrolled up
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Options'), // Title
            // Background image
          ),
        ),

        // sliverListUsingSwitchCases(isDynamicColoringSupported, themeProvider),
        SliverFillRemaining(
          child: listOfOptions(isDynamicColoringSupported, themeProvider),
        )
      ],
    );
  }

  Scaffold originalScaffold(Brightness brightness, ColorScheme colorScheme,
      bool isDynamicColoringSupported, DynamicThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: (brightness == Brightness.light)
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor:
                colorScheme.surfaceVariant, // Navigation bar
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark // Status bar
            ),
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
                subtitle: isDynamicColoringSupported
                    ? const Text('Use Material3\'s dynamic colors')
                    : const Text('Not Supported'),
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
          SwitchListTile(
            title: const Text('Force Light Mode'),
            // subtitle: const Text('When app is opened'),
            value: isLightModeForced, // You can set the initial value here
            onChanged: (bool value) {
              // Handle toggle switch state changes
              setState(() {
                isLightModeForced = value;
                themeProvider.toggleLightMode(value);
                saveIsLightModeForcedBoolValue(value);
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
  }
}
