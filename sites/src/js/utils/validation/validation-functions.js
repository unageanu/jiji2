
const CONTROL_CODE_REGEXP = /^[^\x00-\x08\x0b\x0c\x0e-\x1f\x7f]*$/;
const NUMBER_REGEXP = /^[0-9]*$/;
const NUMBER_OR_HYPHEN_REGEXP = /^[0-9\-]*$/;
const ALPHABET_REGEXP = /^[\x20-\x7E \t\r\n]*$/;
  // 英数字 + 記号 + 半角空白文字類

const KATAKANA_REGEXP = /^[\u30a1-\u30fa\u30fc-\u30fe\u3000 \t\r\n]*$/;
  // 全角カタカナ + 全角スペース + 半角空白文字類

const HIRAGANA_REGEXP = /^[\u3040-\u309f\u30fc-\u30fe\u3000 \t\r\n]*$/;
  // 全角ひらがな + 全角スペース + 半角空白文字類

const SPECIAL_CHARACTERS_REGEXP = /([\ufff0-\uffff])/;
const EXTERNAL_CHARACTERS_REGEXP = /([\ue000-\uf8ff])/;
const HNKAKUKANA_REGEXP = /([\uff61-\uff9f])/;

// 「0×0××××××××」or「0×0-××××-××××」を許可
const MOBILE_TEL_REGEXP = /^0[0-9]0[0-9]{4}[0-9]{4}$/;

const isNil = function(value) {
    return value === null || value === undefined;
};
const sizeOf = function(value) {
    return value.size ? value.size() : value.length;
};


export default class ValidationFunctions {

  static notNull( value, restriction ) {
    if ( value === null || value === undefined || value === "" ) {
      return {type : "NOT_NULL"};
    }
    return null;
  }
  static custom( value, restriction ) {
    return restriction( value ) || null;
  }

  // 文字列用
  static maxLength( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( value.length > restriction ) {
      return { type : "MAX_LENGTH", maxLength: restriction };
    }
    return null;
  }
  static minLength( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( value.length < restriction ) {
      return { type : "MIN_LENGTH", minLength: restriction };
    }
    return null;
  }
  static prohibitedCharacter( value, restriction ) {
    if ( isNil(value) ) return null;
    for ( let i=0, n=restriction.length; i<n; i++ ) {
      const c = restriction.charAt(i);
      if ( value.indexOf(c) !== -1 ) {
        return { type : "PROHIBITED_CHARACTER", character:c };
      }
    }
    return null;
  }
  static pattern( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    const regexp = restriction instanceof RegExp
               ? restriction : restriction.regexp;
    if ( !regexp.test(value) ) {
      return { type : restriction.code || "PATTERN" };
    }
    return null;
  }
  static controlCode( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !CONTROL_CODE_REGEXP.test(value) ) {
        return { type : "CONTROL_CODE" };
    }
    return null;
  }
  static number( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !NUMBER_REGEXP.test(value) ) {
        return {type : "NOT_NUMBER"};
    }
    return null;
  }
  static numberOrHyphen( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !NUMBER_OR_HYPHEN_REGEXP.test(value) ) {
        return {type : "NOT_NUMBER_OR_HYPHEN"};
    }
    return null;
  }
  static alphabet( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !ALPHABET_REGEXP.test(value) ) {
        return {type : "NOT_ALPHABET"};
    }
    return null;
  }
  static katakana( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !KATAKANA_REGEXP.test(value) ) {
        return {type : "NOT_KATAKANA"};
    }
    return null;
  }
  static hiragana( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    if ( !HIRAGANA_REGEXP.test(value) ) {
        return {type : "NOT_HIRAGANA"};
    }
    return null;
  }
  static noSpecials( value ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    const m = value.match(SPECIAL_CHARACTERS_REGEXP);
    if ( m ) {
      return {type : "PROHIBITED_CHARACTER", character:m[1] };
    }
    return null;
  }
  static noExternalCharacters( value ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    const m = value.match(EXTERNAL_CHARACTERS_REGEXP);
    if ( m ) {
      return {type : "PROHIBITED_CHARACTER", character:m[1] };
    }
    return null;
  }
  static noHankakuKana( value ) {
    if ( isNil(value) ) return null;
    if ( typeof value !== "string" ) return null;
    const m = value.match(HNKAKUKANA_REGEXP);
    if ( m ) {
      return {type : "PROHIBITED_CHARACTER", character:m[1] };
    }
    return null;
  }

  // 配列用
  static size( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( sizeOf(value) > restriction ) {
      return { type: "SIZE", size: restriction };
    }
    return null;
  }
  static notEmpty( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( sizeOf(value) <= 0 ) {
      return { type: "NOT_EMPTY" };
    }
    return null;
  }

  // 数値用
  static max( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( value > restriction ) {
      return { type: "MAX", max: restriction };
    }
    return null;
  }
  static min( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( value < restriction ) {
      return {  type: "MIN", min: restriction };
    }
    return null;
  }
  static range( value, restriction ) {
    if ( isNil(value) ) return null;
    if ( restriction.max && value > restriction.max ) {
      return { type: "RANGE", max: restriction.max, min:restriction.min};
    }
    if ( restriction.min && value < restriction.min ) {
      return { type: "RANGE", max: restriction.max, min:restriction.min};
    }
    return null;
  }


  // 携帯電話
  static mobileTel( value, restriction ) {
    if (!value) return null;
    const v = value.replace(/\-/g, "");
    if ( !MOBILE_TEL_REGEXP.test(v) ) {
      return {type : "MOBILE_TEL_ERROR"};
    }
    return null;
  }
}
