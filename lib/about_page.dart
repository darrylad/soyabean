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
                    'Welcome to our leaf health companion app! 🌿📷 Imagine having a personal plant doctor in your pocket! Our user-friendly application is designed to empower farmers and plant enthusiasts alike by effortlessly identifying diseases in plant leaves. Whether you\'re in the field or simply strolling through your garden, our app lets you snap a quick photo or choose one from your gallery to get instant insights into the health of your precious green friends. \n \nGone are the days of manual inspections and unnecessary costs. Our AI model, with its expertise in identifying 10 common plant diseases, is your dedicated partner in ensuring the well-being of your plants. Join us on this journey towards sustainable agriculture and let technology lend a helping hand to both seasoned farmers and budding green thumbs. Together, let\'s nurture healthier crops and greener landscapes! 🌱🤖 #PlantHealthRevolution #SmartFarming\n \nApp Developed by: Darryl David \n \nThis project is a part of Vishnu Bhaiya\'s BTP which also includes a matlab code havnig an AI model. \n \n value of meow: $meow \n value of isDynamicColoringEnabled: $isDynamicColoringEnabled \n value of isFirstTime: $isFirstTime \n tester: $tester',
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
                  'Welcome to our leaf health companion app! 🌿📷 Imagine having a personal plant doctor in your pocket! Our user-friendly application is designed to empower farmers and plant enthusiasts alike by effortlessly identifying diseases in plant leaves. Whether you\'re in the field or simply strolling through your garden, our app lets you snap a quick photo or choose one from your gallery to get instant insights into the health of your precious green friends. \n \nGone are the days of manual inspections and unnecessary costs. Our AI model, with its expertise in identifying 10 common plant diseases, is your dedicated partner in ensuring the well-being of your plants. Join us on this journey towards sustainable agriculture and let technology lend a helping hand to both seasoned farmers and budding green thumbs. Together, let\'s nurture healthier crops and greener landscapes! 🌱🤖 #PlantHealthRevolution #SmartFarming \n',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  '\n value of meow: $meow \n value of isDynamicColoringEnabled: $isDynamicColoringEnabled \n value of isFirstTime: $isFirstTime \n tester: $tester',
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
