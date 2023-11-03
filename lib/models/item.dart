import 'dart:typed_data';

enum ItemType { none, redWine, whiteWine, roseWine, sparklingWine }

extension ItemExt on ItemType {
  int get id {
    switch (this) {
      case ItemType.none:
        return 100;
      case ItemType.redWine:
        return 101;
      case ItemType.whiteWine:
        return 102;
      case ItemType.roseWine:
        return 103;
      case ItemType.sparklingWine:
        return 104;
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
        return 100;
      case Country.italia:
        return 101;
      case Country.francia:
        return 102;
      case Country.slovenia:
        return 103;
      case Country.portogallo:
        return 104;
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
        return 100;
      case Region.abruzzo:
        return 101;
      case Region.altoAdige:
        return 102;
      case Region.basilicata:
        return 103;
      case Region.calabria:
        return 104;
      case Region.campania:
        return 105;
      case Region.emiliaRomagna:
        return 106;
      case Region.friuli:
        return 107;
      case Region.lazio:
        return 108;
      case Region.liguria:
        return 109;
      case Region.lombardia:
        return 110;
      case Region.marche:
        return 111;
      case Region.molise:
        return 112;
      case Region.piemonte:
        return 113;
      case Region.puglia:
        return 114;
      case Region.toscana:
        return 115;
      case Region.trentino:
        return 116;
      case Region.sardegna:
        return 117;
      case Region.sicilia:
        return 118;
      case Region.umbria:
        return 119;
      case Region.valDaosta:
        return 120;
      case Region.veneto:
        return 121;
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
  String description;

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
      this.producer = 0,
      this.description = ""});

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
        producer: map['producer'],
        description: map['description']);
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
      'producer': producer,
      'description': description
    };
  }

  @override
  String toString() {
    return '$name - \u20AC ${price.toStringAsFixed(2)}';
  }
}
