# This Text Contains my Schedule and the log of when I added or made changes to features of this app

October 10

- Added loading screen (Splash) to remove abrupt delay that showed welcome screen for a split second before reading the showWelcomeScreen boolean value using Shared Preferences. done

October 11

- Make a collab repo to upload packages. code will not be updated here. done
- Publish the apk as a package to both the repos. learn docker engine for that. pending
- write code for ~~upload~~ Proceed button. a dialog must appear asking for http url. it should save this url and be autofilled when opened next time (in the text box) to make the process quicker. half done
- leading back button in app bar on camera page was made visible (colorScheme.surface).
- added circularProgressIndicator() and disabled shutter button while capturing photo.
- made barrierDismissible false for app showDialog() boxes.
- development of DescriptionPage started.

October 12

- Implement File_picker() for non android and ios platforms. pending.
- changed welcome page continue navigator to pushReplacement.
- implemented dynamic_color() for dynamic theming based on material 3.
- spent hours figuring out how to find android version when the app starts to set material you dynamic colors as default.
- (midnight) major changes to color scheme
- introduced dark mode (auto, based on system theme)

October 13:

- implemented filePicker if platform is not android or iOS.
- made function to check camera availability.

October 14:

- added options to ask for server url everytime and edit server url
- url is saved to shared preferences and read when app runs.
- took the url text input dialog box and put it in its own file in its own class. so both actions page and camera page call the same class.
- options page scrolling was tweaked a lot to match my expections.

October 15:

Todo:

- lock device orientation (done)
- change width of landscape navigation rail
- fix edit server url bug. (done)
- Turn camera flash off

- added demo mode
