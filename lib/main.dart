import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ipas_mobile/model/profile.dart';
import 'package:ipas_mobile/splash.dart';
import 'package:ipas_mobile/ui/home_page.dart';
import 'package:ipas_mobile/ui/list_cuti.dart';
import 'package:ipas_mobile/ui/list_reimburse.dart';
import 'package:ipas_mobile/ui/login.dart';
import 'package:ipas_mobile/widgets/color_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras;
int _selectedNavbar = 0;
int _selectedPages = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  cameras = await availableCameras();
  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1500)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withOpacity(0.6)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..boxShadow = <BoxShadow>[];
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'IPAS Mobile',
            theme: ThemeData(
                primarySwatch:
                    ColorPalette.temaColor), //ColorPalette.purpleColor
            home: SplashPage(),
            builder: EasyLoading.init(),
          );
        });
  }
}

class MainNavBar extends StatefulWidget {
  @override
  _MainNavBarState createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  signOut() async {
    EasyLoading.showInfo("sign out");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove('username');
      preferences.setInt("value", null);
      // ignore: deprecated_member_use
      preferences.commit();
      //_loginStatus = LoginStatus.notSignIn;
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => HomeLogin()));
    });
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_selectedPages) {
      case 0:
        //return SplashPage();
        break;
      case 1:
        return Scaffold(
          body: callPages(),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Reimburse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_available),
                label: 'Cuti',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_box),
                label: 'Akun',
              ),
            ],
            currentIndex: _selectedNavbar,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _changeSelectedNavBar,
          ),
        );
        break;
    }
  }

  // ignore: missing_return
  Widget callPages() {
    switch (_selectedNavbar) {
      case 0:
        return HomePage(signOut);
        break;
      case 1:
        return ListReimb();
        break;
      case 2:
        return ListCuti();
        break;
      case 3:
        return ProfilePage();
        break;
    }
  }
}
