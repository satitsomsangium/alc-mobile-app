import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/controller/flow_controller.dart';
import 'package:alc_mobile_app/screen/home_page.dart';
import 'package:alc_mobile_app/screen/loader_page.dart';
import 'package:alc_mobile_app/screen/login_page.dart';
import 'package:alc_mobile_app/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    /* AppService.init(permanent: true);
     */
    /* AuthController.init(permanent: true); */
    DbController.init(permanent: true);
    FlowController.init(permanent: true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) => runApp(const AlcMobileApp()));
  } catch (error, stacktrace) {
    debugPrint('$error & $stacktrace');
  }
  WidgetsFlutterBinding.ensureInitialized();
}

class AlcMobileApp extends StatelessWidget {
  const AlcMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 869),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ALC Mobile',
          theme: alcMobileTheme,
          initialRoute: '/loader',
          getPages: [
            GetPage(name: '/loader', page: () => LoaderPage()),
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/home', page: () => HomePage(page: 0)),
          ],
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
        );
      },
    );
  }
}