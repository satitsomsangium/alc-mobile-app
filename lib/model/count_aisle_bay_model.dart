class CountAisleBay {
  final int fvBay;
  final int fvAisle;
  final int buBay;
  final int buAisle;
  final int fiBay;
  final int fiAisle;
  final int bkBay;
  final int bkAisle;
  final int fzBay;
  final int fzAisle;

  CountAisleBay({
    required this.fvBay,
    required this.fvAisle,
    required this.buBay,
    required this.buAisle,
    required this.fiBay,
    required this.fiAisle,
    required this.bkBay,
    required this.bkAisle,
    required this.fzBay,
    required this.fzAisle,
  });

  factory CountAisleBay.fromMap(Map<String, int> map) {
    return CountAisleBay(
      fvBay: map['fvBay'] ?? 0,
      fvAisle: map['fvAisle'] ?? 0,
      buBay: map['buBay'] ?? 0,
      buAisle: map['buAisle'] ?? 0,
      fiBay: map['fiBay'] ?? 0,
      fiAisle: map['fiAisle'] ?? 0,
      bkBay: map['bkBay'] ?? 0,
      bkAisle: map['bkAisle'] ?? 0,
      fzBay: map['fzBay'] ?? 0,
      fzAisle: map['fzAisle'] ?? 0,
    );
  }

  Map<String, int> toMap() {
    return {
      'fvBay': fvBay,
      'fvAisle': fvAisle,
      'buBay': buBay,
      'buAisle': buAisle,
      'fiBay': fiBay,
      'fiAisle': fiAisle,
      'bkBay': bkBay,
      'bkAisle': bkAisle,
      'fzBay': fzBay,
      'fzAisle': fzAisle,
    };
  }
}