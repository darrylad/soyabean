import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soyabean/main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var brightness = Theme.of(context).brightness;
    // return originalScaffold(brightness, colorScheme);
    return Scaffold(
      backgroundColor: (brightness == Brightness.light)
          ? colorScheme.surfaceVariant
          : colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarIconBrightness:
                  (brightness == Brightness.light)
                      ? Brightness.dark
                      : Brightness.light,
              statusBarIconBrightness: (brightness == Brightness.light)
                  ? Brightness.dark
                  : Brightness.light,
              systemNavigationBarColor: (brightness == Brightness.light)
                  ? colorScheme.surfaceVariant
                  : colorScheme.background, // Navigation bar
              statusBarColor: Colors.transparent,
            ),
            backgroundColor: (brightness == Brightness.light)
                ? colorScheme.surfaceVariant
                : colorScheme.background,
            // title: AnimatedOpacity(
            //   opacity: innerBoxIsScrolled ? 1.0 : 0.0,
            //   duration: const Duration(milliseconds: 250),
            //   child: Text('Soyabean',
            //       style: TextStyle(
            //           color: colorScheme.onSurfaceVariant,
            //           fontWeight: FontWeight.w600)),
            // ),
            centerTitle: true,
            // expandedHeight: 200,
            pinned: true,
            snap: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: (isDemoModeOn)
                    ? Text('Soyabean Demo',
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600))
                    : Text('Soyabean',
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
              ),
              centerTitle: true,
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Soyabean',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'Introducing our cutting-edge plant identification software with AI mode! This remarkable app allows you to effortlessly classify plant types from images in your gallery or ones freshly captured with your camera. With a simple tap, your photos are sent to our powerful AI server, where the magic happens. Our AI model swiftly analyzes the visual characteristics of the plants, providing you with accurate and instant plant type classification. Explore the natural world like never before and discover the fascinating flora around you with our AI-powered plant identifier. \n \nWith this app, you can turn your smartphone into a portable plant encyclopedia, whether you\'re a seasoned botanist or just someone with a passion for nature. Easily identify and learn about different plant species as you explore the great outdoors or your own garden. The convenience of on-the-go plant identification is now at your fingertips, all thanks to the remarkable capabilities of our AI mode. Embrace the future of plant identification and unlock the mysteries of the botanical world with our innovative software.\n \nApp Developed by: Darryl David \n \nThis project is a part of Vishnu Bhaiya\'s BTP which also includes a matlab code havnig an AI model. \n \n value of meow: $meow \n value of isDynamicColoringEnabled: $isDynamicColoringEnabled \n value of isFirstTime: $isFirstTime \n tester: $tester',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Scaffold originalScaffold(Brightness brightness, ColorScheme colorScheme) {
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
        // title: Text('Soyabean',
        //     style: TextStyle(
        //         color: colorScheme.onSurfaceVariant,
        //         fontWeight: FontWeight.w600)),
        // centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          // enables scrolling in column
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Soyabean',
                  style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  'Introducing our cutting-edge plant identification software with AI mode! This remarkable app allows you to effortlessly classify plant types from images in your gallery or ones freshly captured with your camera. With a simple tap, your photos are sent to our powerful AI server, where the magic happens. Our AI model swiftly analyzes the visual characteristics of the plants, providing you with accurate and instant plant type classification. Explore the natural world like never before and discover the fascinating flora around you with our AI-powered plant identifier. \n \nWith this app, you can turn your smartphone into a portable plant encyclopedia, whether you\'re a seasoned botanist or just someone with a passion for nature. Easily identify and learn about different plant species as you explore the great outdoors or your own garden. The convenience of on-the-go plant identification is now at your fingertips, all thanks to the remarkable capabilities of our AI mode. Embrace the future of plant identification and unlock the mysteries of the botanical world with our innovative software.\n \n value of meow: $meow \n value of isDynamicColoringEnabled: $isDynamicColoringEnabled \n value of isFirstTime: $isFirstTime \n tester: $tester',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 15),
                ),
              ),
              // const SizedBox(height: 25),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     const SizedBox(width: 10),
              //     FilledButton(
              //       style: ButtonStyle(
              //         backgroundColor:
              //             MaterialStateProperty.all<Color>(colorScheme.primary),
              //         foregroundColor: MaterialStateProperty.all<Color>(
              //             colorScheme.onPrimary),
              //         elevation: MaterialStateProperty.all<double>(4),
              //       ),
              //       onPressed: () {
              //         // onIndexChanged(1);
              //         // bool showWelcomePage = false;
              //         Navigator.pushReplacement(
              //             context,
              //             // MaterialPageRoute(
              //             //     builder: (context) => const HomePage(
              //             //           showWelcomePage: false,
              //             //         ))
              //             PageRouteBuilder(
              //               pageBuilder:
              //                   (context, animation, secondaryAnimation) {
              //                 return const HomePage(
              //                   showWelcomePage: false,
              //                 );
              //               },
              //               transitionsBuilder: (context, animation,
              //                   secondaryAnimation, child) {
              //                 const begin = Offset(0.0, 1.0);
              //                 const end = Offset.zero;
              //                 var curve = Curves.easeOut;
              //                 var curveTween = CurveTween(curve: curve);
              //                 final tween = Tween(begin: begin, end: end)
              //                     .animate(curveTween.animate(animation));
              //                 var offsetAnimation = tween;
              //                 return SlideTransition(
              //                   position: offsetAnimation,
              //                   child: child,
              //                 );
              //               },
              //             ));
              //       },
              //       child: const Text(
              //         'Continue',
              //         style: TextStyle(
              //           fontSize: 15,
              //           letterSpacing: 0.9,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const Spacer(flex: 2),       removing this made the content come to the center
              // const SizedBox(height: 35),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Checkbox(
              //         value: !(showWelcomePage),
              //         onChanged: (value) {
              //           setState(() {
              //             showWelcomePage = !(value!);
              //           });
              //           saveWelcomePageState(showWelcomePage);
              //           debugPrint('showWelcomePage: $showWelcomePage');
              //         }),
              //     // const SizedBox(width: 10),
              //     Text(
              //       'Don\'t show this screen again',
              //       style: TextStyle(
              //           color: colorScheme.onSurfaceVariant,
              //           fontWeight: FontWeight.w600),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
