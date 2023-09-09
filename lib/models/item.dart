import 'dart:typed_data';

enum ItemType { none, redWine, whiteWine, roseWine, sparklingWine }

extension ItemExt on ItemType {
  int get id {
    switch (this) {
      case ItemType.none:
        return 0;
      case ItemType.redWine:
        return 1;
      case ItemType.whiteWine:
        return 2;
      case ItemType.roseWine:
        return 3;
      case ItemType.sparklingWine:
        return 4;
    }
  }

  static ItemType getItemType(int id) {
    for (ItemType itemType in ItemType.values) {
      if (itemType.id == id) {
        return itemType;
      }
    }
    return ItemType.none;
  }
}

enum Country { none, italia, francia, slovenia, portogallo }

extension CountryExt on Country {
  int get id {
    switch (this) {
      case Country.none:
        return 0;
      case Country.italia:
        return 1;
      case Country.francia:
        return 2;
      case Country.slovenia:
        return 3;
      case Country.portogallo:
        return 4;
    }
  }

  static Country getCountry(int id) {
    for (Country country in Country.values) {
      if (country.id == id) {
        return country;
      }
    }
    return Country.none;
  }
}

enum Region {
  none,
  abruzzo,
  altoAdige,
  basilicata,
  calabria,
  campania,
  emiliaRomagna,
  friuli,
  lazio,
  liguria,
  lombardia,
  marche,
  molise,
  piemonte,
  puglia,
  toscana,
  trentino,
  sardegna,
  sicilia,
  umbria,
  valDaosta,
  veneto,
}

class RegionId {
  final int id;
  const RegionId(this.id);
}

extension RegionExt on Region {
  int get id {
    switch (this) {
      case Region.none:
        return 0;
      case Region.abruzzo:
        return 1;
      case Region.altoAdige:
        return 2;
      case Region.basilicata:
        return 3;
      case Region.calabria:
        return 4;
      case Region.campania:
        return 5;
      case Region.emiliaRomagna:
        return 6;
      case Region.friuli:
        return 7;
      case Region.lazio:
        return 8;
      case Region.liguria:
        return 9;
      case Region.lombardia:
        return 10;
      case Region.marche:
        return 11;
      case Region.molise:
        return 12;
      case Region.piemonte:
        return 13;
      case Region.puglia:
        return 14;
      case Region.toscana:
        return 15;
      case Region.trentino:
        return 16;
      case Region.sardegna:
        return 17;
      case Region.sicilia:
        return 18;
      case Region.umbria:
        return 19;
      case Region.valDaosta:
        return 20;
      case Region.veneto:
        return 21;
    }
  }

  static Region getRegion(int id) {
    for (Region region in Region.values) {
      if (region.id == id) {
        return region;
      }
    }
    return Region.none; // Return null if no matching identifier is found
  }
}

class Item {
  int id;
  String name;
  double price;
  Uint8List? image;
  ItemType type;
  Country country;
  Region region;
  int vintage;
  int stock;
  int sold;
  int producer;

  Item(
      {this.id = 0,
      required this.name,
      required this.price,
      this.image,
      this.type = ItemType.none,
      this.country = Country.none,
      this.region = Region.none,
      this.vintage = 0,
      this.stock = 0,
      this.sold = 0,
      this.producer = 0});

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        id: map['item_id'],
        name: map['name'],
        price: map['price'],
        image: map['image'],
        type: ItemExt.getItemType(map['type']),
        country: CountryExt.getCountry(map['country']),
        region: RegionExt.getRegion(map['region']),
        vintage: map['vintage'],
        stock: map['stock'],
        sold: map['sold'],
        producer: map['producer']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'type': type.id,
      'country': country.id,
      'region': region.id,
      'vintage': vintage,
      'stock': stock,
      'sold': sold,
      'producer': producer
    };
  }

  @override
  String toString() {
    return '$name - \$${price.toStringAsFixed(2)}';
  }
}
