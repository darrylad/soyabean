// import 'dart:io'; // pick this
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart'; // pick this
// import 'package:camera/camera.dart'; // pick this
import 'package:soyabean/actions_page.dart';
import 'package:soyabean/history_page.dart';
import 'package:soyabean/options_page.dart';
import 'package:soyabean/welcome_page.dart';
// import 'package:go_router/go_router.dart';

// bool showWelcomePage = true;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Future<bool> loadWelcomePageState() async {
  bool showWelcomePage = true;

  @override
  void initState() {
    super.initState();
    loadWelcomePageState();
  }

  Future<void> loadWelcomePageState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showWelcomePage = prefs.getBool('showWelcomePage') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // bool showWelcomePage = getvalue();
    return MaterialApp(
      title: 'Soyabean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomePage(showWelcomePage: showWelcomePage),
      // home: MaterialApp.router(
      //   routerConfig: routes,
      // ),
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
        : navigationBar(mainArea);
  }

  Scaffold navigationBar(ColoredBox mainArea) {
    return Scaffold(
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
