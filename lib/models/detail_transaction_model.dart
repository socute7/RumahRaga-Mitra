class DetailTransaction {
  final int detailId;
  final String transactionCode;
  final int fieldId;
  final int jamId;
  final int price;
  final String orderDate;

  DetailTransaction({
    required this.detailId,
    required this.transactionCode,
    required this.fieldId,
    required this.jamId,
    required this.price,
    required this.orderDate,
  });

  factory DetailTransaction.fromJson(Map<String, dynamic> json) {
    return DetailTransaction(
      detailId: json['detail_id'],
      transactionCode: json['transaction_code'],
      fieldId: json['field_id'],
      jamId: json['jam_id'],
      price: json['price'],
      orderDate: json['order_date'],
    );
  }
}
