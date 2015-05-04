
export default class NumberUtils {

  static round(number, digit) {
    const positiveDigits = NumberUtils.getPositiveDigits(number);
    const x  = Math.pow(10, 5-Math.max(positiveDigits, 1));
    return Math.floor(number * x) / x;
  }

  /**
   * 整数の桁数を取得する。
   *
   * NumberUtils.getPositiveDigits(1); => 1
   * NumberUtils.getPositiveDigits(10); => 2
   * NumberUtils.getPositiveDigits(100); => 3
   * NumberUtils.getPositiveDigits(10.023); => 2
   * NumberUtils.getPositiveDigits(0.023); => 0
   * NumberUtils.getPositiveDigits(-1); => NaN
   */
  static getPositiveDigits(number) {
    return Math.max( Math.floor(Math.log10(number))+1, 0);
  }
}
