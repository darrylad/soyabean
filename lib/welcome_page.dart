import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:soyabean/actions_page.dart';
import 'package:soyabean/main.dart';

bool showWelcomePage = true;

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // final Function(int) onIndexChanged;
  // bool showWelcomePage = true;

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

  void saveWelcomePageState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomePage', value);
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.onPrimary,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: (brightness == Brightness.light)
              ? Brightness.dark
              : Brightness.light,
          statusBarIconBrightness: (brightness == Brightness.light)
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: (brightness == Brightness.light)
              ? colorScheme.surfaceVariant
              : colorScheme.onPrimary, // Navigation bar
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: (brightness == Brightness.light)
            ? colorScheme.surfaceVariant
            : colorScheme.onPrimary,
        title: (isDemoModeOn)
            ? Text('Soyabean Demo',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600))
            : Text('Soyabean',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          // enables scrolling in column
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Hello there!',
                  style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  // 'Nostrud excepteur ea eu elit dolore amet consectetur Ut Lorem fugiat sunt nulla reprehenderit commodo duis nisi reprehenderit esse amet. Ea dolor labore consectetur commodo non deserunt voluptate sunt. Officia consequat et cupidatat amet. \n \nVoluptate sint eiusmod ex dolore aliquip adipisicing nostrud ea sit. Consectetur dolore dolor id ad aliqua do non dolore aliqua. Anim quis pariatur ut aute pariatur consequat laborum ea mollit cillum. \n value of meow: $meow \n value of isDynamicColoringEnabled: $isDynamicColoringEnabled \n value of isFirstTime: $isFirstTime \n tester: $tester',
                  'Welcome to our AI-powered plant identifier app! Easily classify plant types by uploading images from your gallery or capturing them with your camera. Our powerful AI server analyzes the images for quick and accurate identification, making plant discovery a breeze.\n \nTurn your smartphone into a portable plant encyclopedia with our innovative software. Whether you\'re a seasoned botanist or a nature enthusiast, our app allows you to effortlessly identify and learn about various plant species while exploring the outdoors or tending to your garden. Experience the convenience of on-the-go plant identification with our cutting-edge AI mode. Uncover the mysteries of the botanical world and explore the beauty of the natural realm like never before \n',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 15),
                ),
              ),
              // const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const SizedBox(width: 10),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(colorScheme.primary),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          colorScheme.onPrimary),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    onPressed: () {
                      // onIndexChanged(1);
                      // bool showWelcomePage = false;
                      Navigator.pushReplacement(
                          context,
                          // MaterialPageRoute(
                          //     builder: (context) => const HomePage(
                          //           showWelcomePage: false,
                          //         ))
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const HomePage(
                                showWelcomePage: false,
                              );
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              var curve = Curves.easeOut;
                              var curveTween = CurveTween(curve: curve);
                              final tween = Tween(begin: begin, end: end)
                                  .animate(curveTween.animate(animation));
                              var offsetAnimation = tween;
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ));
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // const Spacer(flex: 2),       removing this made the content come to the center
              const SizedBox(height: 35),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                      side: BorderSide(
                          width: 1.2, color: colorScheme.onSurfaceVariant),
                      value: !(showWelcomePage),
                      onChanged: (value) {
                        setState(() {
                          showWelcomePage = !(value!);
                        });
                        saveWelcomePageState(showWelcomePage);
                        debugPrint('showWelcomePage: $showWelcomePage');
                      }),
                  // const SizedBox(width: 10),
                  Text(
                    'Don\'t show this screen again',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
