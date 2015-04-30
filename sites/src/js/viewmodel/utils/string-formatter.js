
export default class StringFormatter {

  /**
   * テンプレート文字列内の「#{<key>}」を params の値で置き換える。
   */
   static processTemplate(template, params, escapeHTMLChars=false) {
    return template.replace(/\#\{([a-zA-Z0-1]+)\}/mg, (match) => {
      const key = match.substring(2, match.length-1);
      const str = params[key] || "";
      return escapeHTMLChars ? StringFormatter.escape(str) : str;
    });
  }

  /**
   * HTMLおよびXMLでエスケープが必要な文字列をエスケープする。
   */
   static escape(str) {
    if(!str) return "";
    return str.replace(/[&"'<>]/g, (c) => {
      switch (c) {
        case "&":  return "&amp;";
        case "\"": return "&#034;";
        case "'":  return "&#039;";
        case "<":  return "&lt;";
        case ">":  return "&gt;";
      }
    });
  }

  /**
   * 文字列中の全角英数字を半角に変換します。
   */
  static toAscii(value) {
      return value.replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) =>
          String.fromCharCode(s.charCodeAt(0)-0xFEE0));
  }
}
