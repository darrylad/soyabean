// import 'dart:io'; // pick this
import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:after_layout/after_layout.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart'; // pick this
// import 'package:camera/camera.dart'; // pick this
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/history_page.dart';
import 'package:soyabean/options_page.dart';
import 'package:soyabean/welcome_page.dart';
// import 'package:go_router/go_router.dart';

// bool showWelcomePage = true;
bool isFirstTime = true;
String androidVersion = "0"; // stores android version. Eg. 9, 12, etc.
bool isDynamicColoringEnabled =
    false; // stores whether material3 is enabled or not
bool isDynamicColorsSupportedBool =
    false; // stores whether dynamic colors are supported or not

void main() async {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isFirstTime = prefs.getBool('isFirstTime') ?? true;
  showWelcomePage = prefs.getBool('showWelcomePage') ?? true;

  if (isFirstTime == true) {
    await getAndroidVersion();
    isDynamicColoringEnabled = isDynamicColorsSupported();
    isDynamicColorsSupportedBool = isDynamicColorsSupported();
    prefs.setBool('isDynamicColorsSupportedBool', isDynamicColorsSupportedBool);
    prefs.setBool('isDynamicColoringEnabled', isDynamicColoringEnabled);
  } else {
    isDynamicColoringEnabled =
        prefs.getBool('isDynamicColoringEnabled') ?? false;
  }

  runApp(ChangeNotifierProvider(
    create: (context) => DynamicThemeProvider(),
    child: const MyApp(),
  ));
  // getAndroidVersion();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// bool isDynamicColorsSupported = false;

class _MyAppState extends State<MyApp> {
  // Future<bool> loadWelcomePageState() async {
  bool showWelcomePage = true;
  // bool isDynamicColoringEnabled = false;

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadWelcomePageState();

    // getAndroidVersion();
  }

  Future<void> loadWelcomePageState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showWelcomePage = prefs.getBool('showWelcomePage') ?? true;
    });
  }

  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDynamicColoringEnabled =
          prefs.getBool('isDynamicColoringEnabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // bool showWelcomePage = getvalue();

    // ThemeData appTheme = isDynamicColoringEnabled
    //     ? ThemeData.from(
    //         colorScheme: const ColorScheme.light(), useMaterial3: true)
    //     : ThemeData(
    //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    //         useMaterial3: true);

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   systemNavigationBarColor: Theme.of(context).primaryColor,
    //   statusBarColor: Theme.of(context).scaffoldBackgroundColor,
    // ));

    // ColorScheme? lightDynamic = ColorScheme.fromSeed(
    //     seedColor: const Color.fromRGBO(0, 104, 81, 1),
    //     brightness: Brightness.light);

    return Consumer<DynamicThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            if (lightDynamic == null && darkDynamic == null) {
              lightDynamic = ColorScheme.fromSeed(seedColor: Colors.green);
              darkDynamic = ColorScheme.fromSeed(
                  seedColor: Colors.green, brightness: Brightness.dark);
            }
            return MaterialApp(
              title: 'Soyabean',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.isDynamicColoringEnabled
                  ? ThemeData(
                      colorScheme: lightDynamic,
                      useMaterial3: true,
                    )
                  : ThemeData(
                      colorScheme:
                          ColorScheme.fromSeed(seedColor: Colors.green),
                      useMaterial3: true,
                    ),
              darkTheme: themeProvider.isDynamicColoringEnabled
                  ? ThemeData.from(
                      colorScheme: darkDynamic!, useMaterial3: true)
                  : ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.green, brightness: Brightness.dark),
                      useMaterial3: true,
                    ),
              themeMode: ThemeMode.system,
              home: const Splash(),
            );
          },
        );
        // MaterialApp(
        //     title: 'Soyabean',
        //     debugShowCheckedModeBanner: false,
        //     theme: themeProvider.theme,
        //     home: const Splash(),
        //   );
      },
      // child: MaterialApp(
      //   title: 'Soyabean',
      //   debugShowCheckedModeBanner: false,
      //   theme: appTheme,
      //   darkTheme: isDynamicColoringEnabled
      //       ? ThemeData.from(
      //           colorScheme: const ColorScheme.dark(), useMaterial3: true)
      //       : ThemeData(
      //           colorScheme: ColorScheme.fromSeed(
      //               seedColor: Colors.green, brightness: Brightness.dark),
      //           useMaterial3: true,
      //         ),
      //   // home: HomePage(showWelcomePage: showWelcomePage),
      //   home: const Splash(),
      //   // home: MaterialApp.router(
      //   //   routerConfig: routes,
      //   // ),
      // ),
    );
  }
}

String tester = "Not called";

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

bool meow = isDynamicColoringEnabled;

class _SplashState extends State<Splash> {
  final splashDelay = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      afterFirstLayout(context);
    });
    loadWelcomePageState();
    setIsFirstTimeAsFalse();
    // _loadWidget();
  }

  void setIsFirstTimeAsFalse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  // _loadWidget() async {
  //   var duration = Duration(seconds: splashDelay);
  //   return Timer(duration, loadWelcomePageState);
  // }

  void saveThemePreference(bool isDynamicColoringEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDynamicColoringEnabled', isDynamicColoringEnabled);
  }

  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDynamicColoringEnabled =
          prefs.getBool('isDynamicColoringEnabled') ?? false;
    });
  }

  Future<void> loadWelcomePageState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   bool showWelcomePage = prefs.getBool('showWelcomePage') ?? true;
    // });
    bool showWelcomePage = prefs.getBool('showWelcomePage') ?? true;

    await Future.delayed(const Duration(milliseconds: 250));
    if (showWelcomePage) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomePage()));
    } else if (showWelcomePage == false) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage(showWelcomePage: false)));
    }
  }

  // @override
  void afterFirstLayout(BuildContext context) {
    loadWelcomePageState();
    if (isFirstTime) {
      setState(() {
        isDynamicColoringEnabled = isDynamicColorsSupported();
        meow = isDynamicColoringEnabled;
      });
      saveThemePreference(isDynamicColoringEnabled);
    }
    setIsFirstTimeAsFalse();
    meow = isDynamicColoringEnabled;
    loadThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceVariant,
        systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarColor:
                colorScheme.surfaceVariant, // Navigation bar
            statusBarColor: colorScheme.surfaceVariant,
            statusBarIconBrightness: Brightness.dark // Status bar
            ),
      ),
      body: Center(
        child: CircularProgressIndicator(
          // color: Color.fromRGBO(0, 104, 81, 1),
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var selectedIndex = 0;

  void changePage(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

// final GoRouter routes = GoRouter(routes: <RouteBase>[
//   GoRoute(
//       path: 'lib/welcome_page.dart',
//       builder: (BuildContext context, GoRouterState state) {
//         return const WelcomePage();
//       }),
//   GoRoute(
//       path: 'lib/main.dart',
//       builder: (BuildContext context, GoRouterState state) {
//         return const HomePage(showWelcomePage: true);
//       }),
// ]);

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.showWelcomePage});
  final bool showWelcomePage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 1;

  // get showWelcomePage => widget.showWelcomePage;
  // bool showWelcomePage = true;

  // @override
  // void initState() {
  //   bool showWelcomePage = widget.showWelcomePage;
  //   super.initState();
  //   // loadWelcomePageState();
  // }

  // Future<void> loadWelcomePageState() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     showWelcomePage = prefs.getBool('showWelcomePage') ?? true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    // var appState = context.watch<MyAppState>();
    // var selectedIndex = appState.selectedIndex;

    // void changePage(int index) {
    //   setState(() {
    //     selectedIndex = index;
    //   });
    // }

    //call back function for the bottom navigation bar
    // void changeSelectedIndex(int index) {
    //   changePage(index);
    // }

    SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: (brightness == Brightness.light)
          ? colorScheme.background
          : colorScheme.surfaceVariant, // Navigation bar
      statusBarColor: colorScheme.surfaceVariant, // Status bar
    );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    Widget page = const WelcomePage(
        // onIndexChanged: changeSelectedIndex,
        ); // a varaible to store the active page displayed
    switch (selectedIndex) {
      case 0:
        // page = WelcomePage(
        //   onIndexChanged: changeSelectedIndex,
        // );
        page = const HistoryPage();
        break;
      case 1:
        page = const ActionsPage();
        break;
      case 2:
        page = const OptionsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return widget.showWelcomePage
        ? const WelcomePage()
        : navigationBar(mainArea, colorScheme, brightness);
  }

  Scaffold navigationBar(
      ColoredBox mainArea, ColorScheme colorScheme, Brightness brightness) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  // bottom: false,
                  top:
                      false, // this was done to remove extra white space appearing on top of the bottom navigation bar on android
                  child: BottomNavigationBar(
                    backgroundColor: (brightness == Brightness.light)
                        ? colorScheme.background
                        : colorScheme.surfaceVariant,
                    elevation: 20,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.history),
                        label: 'History',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.star),
                        label: 'Actions',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: 'Options')
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.history),
                        label: Text('History'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star),
                        label: Text('Actions'),
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.settings), label: Text('Other'))
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}
