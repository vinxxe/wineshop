class Producer {
  int producerId;
  String producerName;

  Producer({
    this.producerId = 0,
    required this.producerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'producer_id': producerId,
      'producer_name': producerName,
    };
  }

  factory Producer.fromMap(Map<String, dynamic> map) {
    return Producer(
      producerId: map['producer_id'],
      producerName: map['producer_name'],
    );
  }
}
