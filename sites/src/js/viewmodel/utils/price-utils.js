export default class PriceUtils {

  static resolvePriceClass(price) {
    if (price == null) {
      return "";
    } else if (price > 0) {
      return "up";
    } else if (price < 0) {
      return "down";
    } else if (price == 0) {
      return "flat";
    }
  }

}
