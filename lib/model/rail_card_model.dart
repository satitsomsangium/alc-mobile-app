class RailCard {
  String art;
  String dscr;
  int qty;
  String? nickname;
  String? date;
  String? time;

  RailCard({
    required this.art,
    required this.dscr,
    required this.qty,
    this.nickname,
    this.date,
    this.time
  });

  // Convert BayData object to a map
  Map<String, dynamic> toMap() {
    return {
      'art': art,
      'dscr': dscr,
      'qty': qty,
      'nickname': nickname ?? '',
      'date': date ?? '',
      'time': time ?? ''
    };
  }

  // Factory method to create a BayData object from a map
  factory RailCard.fromMap(Map<String, dynamic> map) {
    return RailCard(
      art: map['art'],
      dscr: map['dscr'],
      qty: map['qty'],
      nickname: map['nickname'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? ''
    );
  }
}