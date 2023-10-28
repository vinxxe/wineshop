import "order.dart";

class GlobalInfo {
  // Private constructor
  GlobalInfo._();

  // Singleton instance
  static final GlobalInfo _instance = GlobalInfo._();

  // Getter for the singleton instance
  static GlobalInfo get instance => _instance;

  // Current Order id
  Order? currOrder;
}
