import 'package:alc_mobile_app/component/bottom_navigation.dart';
import 'package:alc_mobile_app/controller/api_controller.dart';
import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/controller/db_controller.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/controller/flow_controller.dart';
import 'package:alc_mobile_app/controller/signage_controller.dart';
import 'package:alc_mobile_app/screen/login_page.dart';
import 'package:alc_mobile_app/service/app_service.dart';
import 'package:alc_mobile_app/service/barcode_service.dart';
import 'package:alc_mobile_app/service/firebase_cloud_messaging_service.dart';
import 'package:alc_mobile_app/ui/theme.dart';
import 'package:alc_mobile_app/utils/loading_animation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alc_mobile_app/screen/set_nickname_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);
  await Firebase.initializeApp();
  await GetStorage.init();
  await setupFCM();
  AuthController.init(permanent: true);
  AppService.init(permanent: true);
  ApiController.init(permanent: true);
  SignageController.init(permanent: true);
  FirebaseController.init(permanent: true);
  DbController.init(permanent: true);
  FlowController.init(permanent: true);
  BarcodeService.init(permanent: true);
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) => runApp(const AlcMobileApp()));
}

// เพิ่มฟังก์ชันนี้
Future<void> setupFCM() async {
  final fcmService = FCMService();
  await fcmService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Got a message whilst in the foreground!");
    print("Message data: ${message.data}");

    if (message.notification != null) {
      print("Message also contained a notification: ${message.notification}");
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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
            title: 'ALC Mobile App',
            theme: alcMobileTheme,
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const InitialPage()),
              GetPage(name: '/login', page: () => const LoginPage()),
              GetPage(name: '/set_nickname', page: () => SetNicknamePage()),
              GetPage(name: '/home', page: () => const Bottomnavigation(0)),
            ],
            // เพิ่มส่วนนี้
            /* builder: (context, child) {
              return Scaffold(
                body: child,
                floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
                floatingActionButton: Obx(() {
                  final pendingCount = SignageController.pendingPrintCount.value;
                  return pendingCount > 0
                      ? FloatingActionButton(
                          child: Badge(
                            label: Text('$pendingCount'),
                            child: Icon(Icons.print),
                          ),
                          onPressed: () {
                            // เปิดหน้ารายการที่รอพิมพ์
                          },
                        )
                      : SizedBox.shrink();
                }),
              );
            }, */
          ),
        );
      },
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.find<AuthController>().isLoggedIn.value) {
        return const Bottomnavigation(0);
      } else {
        return const LoginPage();
      }
    });
  }
}