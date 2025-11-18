class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'income' or 'expense'
  final String? note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'note': note,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      type: json['type'] as String,
      note: json['note'] as String?,
    );
  }

  String getIconName() {
    switch (category.toLowerCase()) {
      case 'gaji':
      case 'salary':
        return 'money';
      case 'belanja':
      case 'shopping':
        return 'shopping';
      case 'makan':
      case 'food':
        return 'food';
      case 'online shopping':
        return 'package';
      default:
        return type == 'income' ? 'money' : 'shopping';
    }
  }
}
