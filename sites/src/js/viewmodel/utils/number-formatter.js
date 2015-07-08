
export default class NumberFormatter {

  static paddingZero(number, digit) {
      var str = ""+number;
      for ( let i=str.length; i<digit; i++ ) {
          str = "0"+str;
      }
      return str;
  }

  /**
   * 数値を3ケタごとに「,」で区切った文字列に変換する。
   */
   static insertThousandsSeparator(price) {
      if (price === 0) return "0";
      if (!price) return "";

      const result = /^([\-\+]?)(\d+)(\.\d+)?$/.exec(String(price));
      if (!result || result.length < 1) return "";

      var str = "";
      var tmp = result[2];
      while ( tmp.length > 3 ) {
          str = "," + tmp.substring(tmp.length-3, tmp.length) + str;
          tmp = tmp.substring(0, tmp.length-3);
      }
      str = tmp + str;
      return (result[1] || "") + str + (result[3] || "");
  }

  static formatRatio(ratio) {
    if (ratio === 0) return "0.0%";
    if (!ratio) return "";
    let str = "" + Math.abs(Math.round(ratio*1000));
    if (str.length <= 1) {
      str = "0." + str;
    } else {
      str = str.substring(0, str.length-1) + "." + str.charAt(str.length-1);
    }
    if (ratio < 0) str = "-" + str;
    return str + "%";
  }

}
