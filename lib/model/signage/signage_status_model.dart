/* enum SignageStatus {
  pending,    // รอส่ง
  sent,       // ส่งแล้ว
  printed,    // ปริ้นแล้ว
  deleted     // ลบแล้ว
}

class Signage {
  final String id;
  final String name;
  SignageStatus status;

  Signage({
    required this.id,
    required this.name,
    this.status = SignageStatus.pending,
  });

  // แปลง enum เป็น String
  String get statusString {
    switch (status) {
      case SignageStatus.pending:
        return 'รอส่ง';
      case SignageStatus.sent:
        return 'ส่งแล้ว';
      case SignageStatus.printed:
        return 'ปริ้นแล้ว';
      case SignageStatus.deleted:
        return 'ลบแล้ว';
    }
  }

  // สร้าง Signage จาก Map (เช่น จาก JSON)
  factory Signage.fromMap(Map<String, dynamic> map) {
    return Signage(
      id: map['id'],
      name: map['name'],
      status: SignageStatus.values.firstWhere(
        (e) => e.toString() == 'SignageStatus.${map['status']}',
        orElse: () => SignageStatus.pending,
      ),
    );
  }

  // แปลง Signage เป็น Map (เช่น เพื่อเก็บใน JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
    };
  }
} */