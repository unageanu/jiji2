
export default class Numbers {

  static round(number, digit) {
    const positiveDigits = Numbers.getPositiveDigits(number);
    const x  = Math.pow(10, digit-Math.max(positiveDigits, 1));
    return Math.floor(number * x) / x;
  }

  /**
   * 整数の桁数を取得する。
   *
   * Numbers.getPositiveDigits(1); => 1
   * Numbers.getPositiveDigits(10); => 2
   * Numbers.getPositiveDigits(100); => 3
   * Numbers.getPositiveDigits(10.023); => 2
   * Numbers.getPositiveDigits(0.023); => 0
   * Numbers.getPositiveDigits(-1); => NaN
   */
  static getPositiveDigits(number) {
    return Math.max( Math.floor(Math.log10(number))+1, 0);
  }
}
