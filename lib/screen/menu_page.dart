import 'package:alc_mobile_app/controller/auth_controller.dart';
import 'package:alc_mobile_app/screen/service_request/service_request_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/link.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    animation = Tween(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn),
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = authController.user.value;
    return SafeArea(
      child: FadeTransition(
        opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Spacer(),
                    iconHome(
                      context,
                      icon: Icons.list_alt_outlined,
                      title: 'ขอเรียลการ์ด',
                      index: 1,
                      color1: const Color(0xFFFF416C),
                      color2: const Color(0xFF8A52E9),
                    ),
                    const Spacer(),
                    iconHome(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: 'นับสต๊อกออฟไลน์',
                      index: 2,
                      color1: const Color(0xFFFFA72F),
                      color2: const Color(0xFFFF641A),
                    ),
                    const Spacer(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Spacer(),
                    iconHome(
                      context,
                      icon: Icons.price_change_outlined,
                      title: 'เช็คราคาสินค้า',
                      index: 3,
                      color1: const Color(0xFFFF7765),
                      color2: const Color(0xFFF7A23C),
                    ),
                    const Spacer(),
                    iconHome(
                      context,
                      icon: Icons.account_box_outlined,
                      title: 'จัดการบัญชี',
                      index: 4,
                      color1: const Color(0xFF21E8AC),
                      color2: const Color(0xFF376DF6),
                    ),
                    const Spacer(),
                  ],
                ), */
                if (firebaseUser != null &&
                    firebaseUser.email != null &&
                    firebaseUser.email!.contains('alc'))
                  const Divider(),
                if (firebaseUser != null &&
                    firebaseUser.email != null &&
                    firebaseUser.email!.contains('alc'))
                  Row(
                    children: [
                      const Spacer(),
                      iconHomeHor(
                        context,
                        icon: Icons.construction,
                        title: 'ALC Service Request',
                        index: 1,
                        color1: const Color(0xFFFF416C),
                        color2: Colors.red,
                      ),
                      const Spacer(),
                    ],
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Spacer(),
                    Link(
                      uri: Uri.parse('https://lmsrv.siammakro.co.th/'),
                      target: LinkTarget.blank,
                      builder: (ctx, openLink) {
                        return iconHomeMakro(
                          context,
                          images: Image.asset('assets/images/mlearning1.png'),
                          title: 'M Learning',
                          onPress: openLink!,
                        );
                      },
                    ),
                    const Spacer(),
                    Link(
                      uri: Uri.parse('https://ss.siammakro.co.th/'),
                      target: LinkTarget.blank,
                      builder: (ctx, openLink) {
                        return iconHomeMakro(
                          context,
                          images: Image.asset('assets/images/Hris1.png'),
                          title: 'HR Self Services',
                          onPress: openLink!,
                        );
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Spacer(),
                    Link(
                      uri: Uri.parse('https://board.talentmind.ai/siam-makro'),
                      target: LinkTarget.blank,
                      builder: (ctx, openLink) {
                        return iconHomeMakro(
                          context,
                          images: Image.asset('assets/images/job.png'),
                          title: 'สมัครงานภายใน',
                          onPress: openLink!,
                        );
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 50 / 100) - 20,
                    ),
                    const Spacer(),
                  ],
                ), */
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconHome(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required Color color1,
    required Color color2,
  }) {
    double screenWidth(double width) {
      return MediaQuery.of(context).size.width * width / 100;
    }

    return InkWell(
      onTap: () {
        
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        width: screenWidth(50) - 20,
        height: screenWidth(50) - 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(screenWidth(3)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.8, 0.0),
                  colors: <Color>[color1.withOpacity(.5), color2.withOpacity(.8)],
                ),
                borderRadius: BorderRadius.circular(75),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth(15.8),
                  minHeight: screenWidth(15.8),
                  maxWidth: screenWidth(18),
                  maxHeight: screenWidth(18),
                ),
                child: ClipRRect(
                  child: Icon(
                    icon,
                    size: screenWidth(12),
                    color: const Color(0xFFFCFCFC),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth(4)),
              child: Text(
                title,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconHomeHor(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required Color color1,
    required Color color2,
  }) {
    double screenWidth(double width) {
      return MediaQuery.of(context).size.width * width / 100;
    }

    return InkWell(
      onTap: () {
        Get.to(() => const ServiceRequestPage());
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        width: screenWidth(100) - 26.6,
        height: screenWidth(50) - 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(screenWidth(3)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.8, 0.0),
                  colors: <Color>[color1.withOpacity(.5), color2.withOpacity(.8)],
                ),
                borderRadius: BorderRadius.circular(75),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth(15.8),
                  minHeight: screenWidth(15.8),
                  maxWidth: screenWidth(18),
                  maxHeight: screenWidth(18),
                ),
                child: ClipRRect(
                  child: Icon(
                    icon,
                    size: screenWidth(12),
                                        color: const Color(0xFFFCFCFC),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth(4)),
              child: Text(
                title,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconHomeMakro(
    BuildContext context, {
    required Image images,
    required String title,
    required Function() onPress,
  }) {
    double screenWidth(double width) {
      return MediaQuery.of(context).size.width * width / 100;
    }

    return InkWell(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        width: screenWidth(50) - 20,
        height: screenWidth(50) - 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(screenWidth(3)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.01),
                borderRadius: BorderRadius.circular(75),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth(15.8),
                  minHeight: screenWidth(15.8),
                  maxWidth: screenWidth(30),
                  maxHeight: screenWidth(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: images,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth(4)),
              child: Text(
                title,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}