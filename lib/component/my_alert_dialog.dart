import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAlertDialog {
  static showalertdialog(BuildContext context, String title, String content,
     String okbtTXT, bool cancelbtstate, String cancelbtTXT, VoidCallback okfunction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: cancelbtstate,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(75),
                                    side: const BorderSide(color: Colors.red)))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          cancelbtTXT,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75),
                              side: const BorderSide(color: Colors.red)))),
                  onPressed: okfunction,
                  child: SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        okbtTXT,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  static loadingdialog(BuildContext context, String content) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: 150,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        content,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static checkqtyDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: 180,
                  height: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(title),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(75),
                                      side: const BorderSide(color: Colors.red)))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const SizedBox(
                            width: 60,
                            child: Center(
                              child: Text(
                                'ตกลง',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static showalertdialogWidgetContent(
      BuildContext context,
      String title,
      Widget contentwidget,
      String okbtTXT,
      bool cancelbtstate,
      String cancelbtTXT,
      VoidCallback cancelfunction,
      VoidCallback okfunction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              contentwidget,
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: cancelbtstate,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(75),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: cancelfunction,
                    child: SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          cancelbtTXT,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75),
                              side: const BorderSide(color: Colors.red)))),
                  onPressed: okfunction,
                  child: SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        okbtTXT,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  static showalertdialogWidgetContentNobtn(
    BuildContext context,
    String title,
    Widget contentwidget,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              contentwidget,
            ],
          ),
        );
      },
    );
  }

  static void showDefaultDialog({
    String? title,
    String? content,
    String? textYes,
    String? textNo,
    bool isNoButton = false,
    VoidCallback? onPressYes,
    VoidCallback? onPressNo,
    VoidCallback? onLongPressYes,
  }) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              title ?? 'แจ้งเตือน',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red),
            ),
          ),
          content: Text(
            content ?? 'เกิดข้อผิดพลาด',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: isNoButton ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: isNoButton,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(1)
                      ),
                      onPressed: onPressNo ?? () => Get.back(), 
                      child: Text(textNo ?? 'ยกเลิก')
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(1)
                    ),
                    onLongPress: onLongPressYes ?? () {},
                    onPressed: onPressYes ?? () => Get.back(), 
                    child: Text(textYes ?? 'ตกลง')
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
