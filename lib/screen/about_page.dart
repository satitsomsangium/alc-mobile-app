import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
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
            children: [
              versionLine(
                version: '4.0.0',
                date: '3-AUG-2024',
                content:
                    '- อัปเดต sdk \n- อัปเดต Libary \n- แก้ไข ui เล็กน้อย \n- เปลี่ยนระบบ login ให้สามารถจำเครื่อง และชื่อเล่นที่เคยตั้งไว้ได้ \n- ลบการเช็คอัปเดตแอป',
                showDivider: true,
              ),
              versionLine(
                version: '3.1.0',
                date: '25-NOV-2021',
                content:
                    '- เพิ่มลิงก์เข้า M-Learning, HR Self Services, สมัครงานภายใน \n- เพิ่มระบบแจ้งซ่อมของแผนก ALC',
                showDivider: true,
              ),
              versionLine(
                version: '3.0.1',
                date: '16-OCT-2021',
                content: '- แก้ไขการอ่านข้อมูลบาร์โค้ด 13 หลัก ในโหมดออฟไลน์',
                showDivider: true,
              ),
              versionLine(
                version: '3.0.0',
                date: '9-SEP-2021',
                content:
                    '- เพิ่มฟังชันนับสต๊อกสินค้าแบบออฟไลน์ เพื่อแก้ไขปัญหา hht ไม่มีสัญญานในห้องแช่แข็ง \n- ตัดฟังชันขอป้าย Makro Sinage ออก \n- เพิ่มการระบุจำนวนป้าย Railcard เมื่อมีการยิงซ้ำ \n- พัฒนาแอปด้วย Flutter',
                showDivider: true,
              ),
              versionLine(
                version: '2.0.0',
                date: '2-APR-2021',
                content:
                    '- เพิ่มประสิทธิภาพการทำงานของแอป \n- เปลี่ยนระบบล็อกอินให้สามารถเข้าใช้งานได้เร็วขึ้น \n- เพิ่มความเร็วในการรับ-ส่งข้อมูล ระบบขอ railcard และระบบขอ makro signage \n- ปรับแต่ง UI ของแอปให้สวยงาม ใช้งานได้ง่ายขึ้น \n- เพิ่มระบบอัปเดตราคาอัตโนมัติทุก ๆ 10 นาที \n- ปิดระบบรับข้อมูลของ alc ในแอป และเปลี่ยนไปใช้การรับข้อมูลในคอมพิวเตอร์',
                showDivider: true,
              ),
              versionLine(
                version: '1.4.0',
                date: '10-OCT-2020',
                content:
                    '- เพิ่มการขอป้ายราคา makro signage \n- เพิ่มการกดปุ่มกลับ 2 ครั้งเพื่อออกจากแอป \n- เพิ่มหน้าแจ้งปัญหาการใช้งานและการแนะนำ \n- เพิ่มการใส่ชื่อคนขอป้ายเพื่อกรองผู้ใช้ได้มากขึ้น \n- แก้ข้อความในแอปให้เป็นภาษาไทย',
                showDivider: true,
              ),
              versionLine(
                version: '1.3.2',
                date: '10-OCT-2020',
                content:
                    '- เพิ่มการอ่านบาร์โค้ดที่ปริ้นออกมาจากเครื่องชั่ง\n- แก้ไขขนาดฟ้อนต์ให้เหมาะสมกับอุปกรณ์',
                showDivider: true,
              ),
              versionLine(
                version: '1.3.1',
                date: '10-OCT-2020',
                content:
                    '- แก้ไขการอ่านบาร์โค้ด 8 หลัก \n- เพิ่มการเก็บ Error log และ รหัสสินค้าที่ไม่แสดงผล เพื่อนำไปปรับปรุงระบบ',
                showDivider: true,
              ),
              versionLine(
                version: '1.3.0',
                date: '10-OCT-2020',
                content:
                    '- เพิ่มการเช็คราคาสินค้า \n- อัพเดทหน้าจัดการข้อมูลของ ALC',
                showDivider: true,
              ),
              versionLine(
                version: '1.2.0',
                date: '10-OCT-2020',
                content:
                    '- แก้ไขแหล่งเก็บข้อมูล \n- เพิ่มฟังชั่นการแจ้งเตือนเมื่อมีการอัพเดทเวอร์ชั่นแอป',
                showDivider: true,
              ),
              versionLine(
                version: '1.0.0',
                date: '10-OCT-2020',
                content: '- เปิดตัวแอปขอเรียลการ์ด',
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget versionLine({
    required String version,
    required String date,
    required String content,
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
        Text(content),
        const SizedBox(height: 10),
        if (showDivider) const Divider(),
      ],
    );
  }
}