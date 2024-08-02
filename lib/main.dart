import 'package:alc_mobile_app/controller/api_controller.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/controller/flow_controller.dart';
import 'package:alc_mobile_app/screen/home_page.dart';
import 'package:alc_mobile_app/screen/loader_page.dart';
import 'package:alc_mobile_app/screen/login_page.dart';
import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:alc_mobile_app/ui/theme.dart';
import 'package:alc_mobile_app/utils/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    ApiController.init(permanent: true);
    ApiController.init(permanent: true);
    FirebaseController.init(permanent: true);
    DbController.init(permanent: true);
    FlowController.init(permanent: true);
    BarcodeService.init(permanent: true);
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
        return GlobalLoaderOverlay(
          useDefaultLoading: false,
          disableBackButton: false,
          closeOnBackButton: true,
          overlayColor: Colors.black.withOpacity(0.8),
          overlayWidgetBuilder: (_) => const Center(child: LoadingAnimation()),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ALC Mobile',
            theme: alcMobileTheme,
            initialRoute: '/loader',
            getPages: [
              GetPage(name: '/loader', page: () => const LoaderPage()),
              GetPage(name: '/login', page: () => const LoginPage()),
              GetPage(name: '/home', page: () => HomePage(page: 0)),
            ],
            initialBinding: BindingsBuilder(() {
              Get.put(AuthController());
            }),
          ),
        );
      },
    );
  }
}