import 'package:flutter/material.dart';
import 'package:alc_mobile_app/controller/firebase_controller.dart';
import 'package:alc_mobile_app/model/app_version_model.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เกี่ยวกับ ALC Mobile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<AppVersion>>(
        future: FirebaseController.getVersionsFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลเวอร์ชัน'));
          } else {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data!.map((version) => 
                    versionLine(
                      version: version.version,
                      date: version.date,
                      content: version.content,
                      showDivider: version != snapshot.data!.last,
                    )
                  ).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget versionLine({
    required String version,
    required String date,
    required List<String> content,
    required bool showDivider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เวอร์ชัน $version',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text('มีอะไรใหม่'),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('• $item'),
          )).toList(),
        ),
        const SizedBox(height: 10),
        if (showDivider) const Divider(),
      ],
    );
  }
}