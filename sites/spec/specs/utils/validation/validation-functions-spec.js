import ValidationFunctions from "src/utils/validation/validation-functions"

describe("ValidationFunctions", () => {

  const matchers = {
    toBeValidationError(util, customEqualityTesters) {
      return {
        compare(actual, expected) {
          return {
            pass: actual.type === expected
          };
        }
      };
    },
    notToBeError(util, customEqualityTesters) {
      return {
        compare(actual, expected) {
          return {
            pass: actual === null
          };
        }
      };
    }
  };

  beforeEach(() => jasmine.addMatchers(matchers) );

  describe("notNull", () => {
    const f = ValidationFunctions.notNull;

    it("null", () => {
      expect( f(null) ).toBeValidationError("NOT_NULL");
    });
    it("undefined", () => {
      expect( f(undefined) ).toBeValidationError("NOT_NULL");
    });
    it("空文字", () => {
      expect( f("") ).toBeValidationError("NOT_NULL");
    });
    it("a", () => {
      expect( f("a") ).notToBeError();
    });
    it("0", () => {
      expect( f(0) ).notToBeError();
    });
    it("1", () => {
      expect( f(1) ).notToBeError();
    });
    it("-1", () => {
      expect( f(-1) ).notToBeError();
    });
    it("NaN", () => {
      expect( f(NaN) ).notToBeError();
    });
    it("false", () => {
      expect( f(false) ).notToBeError();
    });
  });

  describe("maxLength", () => {
    const f = ValidationFunctions.maxLength;

    it("半角", () => {
      expect( f("aaaa", 3) ).toBeValidationError("MAX_LENGTH", {maxLength:3});
      expect( f("aaaax", 3) ).toBeValidationError("MAX_LENGTH", {maxLength:3});
      expect( f("aaa", 3) ).notToBeError();
      expect( f("aa", 3) ).notToBeError();
      expect( f("a", 3) ).notToBeError();
    });
    it("全角", () => {
      expect( f("あああああ", 4) ).toBeValidationError("MAX_LENGTH", {maxLength:4});
      expect( f("あああああい", 4) ).toBeValidationError("MAX_LENGTH", {maxLength:4});
      expect( f("ああああ", 4) ).notToBeError();
      expect( f("あ", 4) ).notToBeError();
    });
    it("空文字", () => {
      expect( f("", 4) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, 4) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, 4) ).notToBeError();
    });
  });

  describe("minLength", () => {
    const f = ValidationFunctions.minLength;

    it("半角", () => {
      expect( f("aa", 3) ).toBeValidationError("MIN_LENGTH", {minLength:3});
      expect( f("a", 3) ).toBeValidationError("MIN_LENGTH", {minLength:3});
      expect( f("aaa", 3) ).notToBeError();
      expect( f("aaaa", 3) ).notToBeError();
    });
    it("全角", () => {
      expect( f("あああ", 4) ).toBeValidationError("MIN_LENGTH", {minLength:4});
      expect( f("ああ", 4) ).toBeValidationError("MIN_LENGTH", {minLength:4});
      expect( f("あ", 4) ).toBeValidationError("MIN_LENGTH", {minLength:4});
      expect( f("ああああ", 4) ).notToBeError();
      expect( f("あああああ", 4) ).notToBeError();
    });
    it("空文字", () => {
      expect( f("", 4) ).toBeValidationError("MIN_LENGTH", {minLength:4});
    });
    it("null", () => {
      expect( f(null, 4) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, 4) ).notToBeError();
    });
  });

  describe("prohibitedCharacter", () => {
    const f = ValidationFunctions.prohibitedCharacter;

    it("半角", () => {
      expect( f("aa_aa", "_%&") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"_"});
      expect( f("%", "_%&") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"%"});
      expect( f("aa&", "&") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"&"});
      expect( f("aaaa", "_%&") ).notToBeError();
    });
    it("全角", () => {
      expect( f("aaう", "&あいう_") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"う"});
      expect( f("ああ", "_%&") ).notToBeError();
      expect( f("aa", "&あいう_") ).notToBeError();
    });
    it("空文字", () => {
      expect( f("", "_%&") ).notToBeError();
    });
    it("null", () => {
      expect( f(null, "_%&") ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, "_%&") ).notToBeError();
    });
  });

  describe("controlCode", () => {
    const f = ValidationFunctions.controlCode;

    it("コントロールコード", () => {
      expect( f("\u0000") ).toBeValidationError("CONTROL_CODE");
      expect( f("\u0001") ).toBeValidationError("CONTROL_CODE");
      expect( f("\u0008") ).toBeValidationError("CONTROL_CODE");
      expect( f("\u000e") ).toBeValidationError("CONTROL_CODE");
      expect( f("\u001f") ).toBeValidationError("CONTROL_CODE");
      expect( f("\u007f") ).toBeValidationError("CONTROL_CODE");
    });
    it("通常の文字", () => {
      expect( f("aaa") ).notToBeError();
      expect( f("ああ") ).notToBeError();
    });
    it("スペース/タブ", () => {
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\r") ).notToBeError();
      expect( f("\n") ).notToBeError();
    });
    it("空文字", () => {
      expect( f("") ).notToBeError();
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("pattern", () => {
    const f = ValidationFunctions.pattern;

    it("マッチしない", () => {
      expect( f("axa", /^[abc]+$/) ).toBeValidationError("PATTERN");
      expect( f("axa", {regexp: /^[abc]+$/, code: "INVALID" }) ).toBeValidationError("INVALID");
    });
    it("マッチする", () => {
      expect( f("aaa", /^[abc]+$/) ).notToBeError();
      expect( f("aba", /^[abc]+$/) ).notToBeError();
      expect( f("aacc", /^[abc]+$/) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, /^[abc]+$/) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, /^[abc]+$/) ).notToBeError();
    });
  });

  describe("number", () => {
    const f = ValidationFunctions.number;

    it("数字", () => {
      expect( f("0123456789") ).notToBeError();
      expect( f("100") ).notToBeError();
      expect( f("10") ).notToBeError();
    });
    it("エラー", () => {
      expect( f("a") ).toBeValidationError("NOT_NUMBER");
      expect( f("あ") ).toBeValidationError("NOT_NUMBER");
      expect( f(" ") ).toBeValidationError("NOT_NUMBER");
      expect( f("一") ).toBeValidationError("NOT_NUMBER");
      expect( f("１") ).toBeValidationError("NOT_NUMBER");
      expect( f("1.2") ).toBeValidationError("NOT_NUMBER");
      expect( f("-10") ).toBeValidationError("NOT_NUMBER");
      expect( f("+3") ).toBeValidationError("NOT_NUMBER");
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("numberOrHyphen", () => {
    const f = ValidationFunctions.numberOrHyphen;

    it("数字", () => {
      expect( f("0123456789") ).notToBeError();
      expect( f("100") ).notToBeError();
      expect( f("10") ).notToBeError();
      expect( f("-10") ).notToBeError();
      expect( f("1-0") ).notToBeError();
      expect( f("10-") ).notToBeError();
    });
    it("エラー", () => {
      expect( f("a") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f("あ") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f(" ") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f("一") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f("１") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f("1.2") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
      expect( f("+3") ).toBeValidationError("NOT_NUMBER_OR_HYPHEN");
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("alphabet", () => {
    const f = ValidationFunctions.alphabet;

    it("英数字", () => {
      expect( f("ABCDEFGHIJKLMNOPQRSTUVWXYZ") ).notToBeError();
      expect( f("abcdefrhijklmnopqrstuvwxyz") ).notToBeError();
      expect( f("0123456789") ).notToBeError();
    });
    it("記号", () => {
      expect( f("!\"#$%&'()=~|-^\@[`{+*};:]<>?_,./\\") ).notToBeError();
    });
    it("空白", () => {
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\n") ).notToBeError();
      expect( f("\r") ).notToBeError();
    });
    it("それ以外", () => {
      expect( f("あ") ).toBeValidationError("NOT_ALPHABET");
      expect( f("一") ).toBeValidationError("NOT_ALPHABET");
      expect( f("１") ).toBeValidationError("NOT_ALPHABET");
      expect( f("Ａ") ).toBeValidationError("NOT_ALPHABET");
      expect( f("ａ") ).toBeValidationError("NOT_ALPHABET");
      expect( f("±") ).toBeValidationError("NOT_ALPHABET");
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("カタカナ", () => {
    const f = ValidationFunctions.katakana;

    it("カタカナ", () => {
      expect( f("アイウエオカキクケコサシスセソタチツテトナニヌネノ") ).notToBeError();
      expect( f("ハヒフヘホマミムメモヤユヨワヲン") ).notToBeError();
      expect( f("ァィゥェォャュョッ") ).notToBeError();
      expect( f("ガギグゲゴザジズゼゾダヂズデドバビブベボヴパピプペポ") ).notToBeError();
    });
    it("空白", () => {
      expect( f("　") ).notToBeError();
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\n") ).notToBeError();
      expect( f("\r") ).notToBeError();
    });
    it("それ以外", () => {
      expect( f("あ") ).toBeValidationError("NOT_KATAKANA");
      expect( f("一") ).toBeValidationError("NOT_KATAKANA");
      expect( f("１") ).toBeValidationError("NOT_KATAKANA");
      expect( f("Ａ") ).toBeValidationError("NOT_KATAKANA");
      expect( f("ａ") ).toBeValidationError("NOT_KATAKANA");
      expect( f("±") ).toBeValidationError("NOT_KATAKANA");
      expect( f("ｱ") ).toBeValidationError("NOT_KATAKANA");
      expect( f("ｲ") ).toBeValidationError("NOT_KATAKANA");
      expect( f("㌔") ).toBeValidationError("NOT_KATAKANA");
      expect( f("㍍") ).toBeValidationError("NOT_KATAKANA");
      expect( f("\ue000") ).toBeValidationError("NOT_KATAKANA");
      expect( f("\ue001") ).toBeValidationError("NOT_KATAKANA");
      expect( f("\uF8FF") ).toBeValidationError("NOT_KATAKANA");
      expect( f("\uF900") ).toBeValidationError("NOT_KATAKANA");
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("外字禁止", () => {
    const f = ValidationFunctions.noExternalCharacters;

    it("空白", () => {
      expect( f("　") ).notToBeError();
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\n") ).notToBeError();
      expect( f("\r") ).notToBeError();
    });
    it("各種文字列", () => {
      expect( f("あ") ).notToBeError();
      expect( f("一") ).notToBeError();
      expect( f("１") ).notToBeError();
      expect( f("Ａ") ).notToBeError();
      expect( f("ａ") ).notToBeError();
      expect( f("±") ).notToBeError();
      expect( f("ｱ") ).notToBeError();
      expect( f("ｲ") ).notToBeError();
      expect( f("㌔") ).notToBeError();
      expect( f("㍍") ).notToBeError();
      expect( f("\ue000") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"\ue000"});
      expect( f("\ue001") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"\ue001"});
      expect( f("\uF8FF") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"\uF8FF"});
      expect( f("\uF900") ).notToBeError();
      expect( f("\uFFF0") ).notToBeError();
      expect( f("\uFFFF") ).notToBeError();
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("特殊用途文字禁止", () => {
    const f = ValidationFunctions.noSpecials;

    it("空白", () => {
      expect( f("　") ).notToBeError();
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\n") ).notToBeError();
      expect( f("\r") ).notToBeError();
    });
    it("各種文字列", () => {
      expect( f("あ") ).notToBeError();
      expect( f("一") ).notToBeError();
      expect( f("１") ).notToBeError();
      expect( f("Ａ") ).notToBeError();
      expect( f("ａ") ).notToBeError();
      expect( f("±") ).notToBeError();
      expect( f("ｱ") ).notToBeError();
      expect( f("ｲ") ).notToBeError();
      expect( f("㌔") ).notToBeError();
      expect( f("㍍") ).notToBeError();
      expect( f("\ue000") ).notToBeError();
      expect( f("\ue001") ).notToBeError();
      expect( f("\uF8FF") ).notToBeError();
      expect( f("\uF900") ).notToBeError();
      expect( f("\uFFF0") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"\uFFF0"});
      expect( f("\uFFFF") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"\uFFFF"});
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("半角カタカナ禁止", () => {

    const f = ValidationFunctions.noHankakuKana;

    it("空白", () => {
      expect( f("　") ).notToBeError();
      expect( f(" ") ).notToBeError();
      expect( f("\t") ).notToBeError();
      expect( f("\n") ).notToBeError();
      expect( f("\r") ).notToBeError();
    });
    it("各種文字列", () => {
      expect( f("あ") ).notToBeError();
      expect( f("一") ).notToBeError();
      expect( f("１") ).notToBeError();
      expect( f("Ａ") ).notToBeError();
      expect( f("ａ") ).notToBeError();
      expect( f("±") ).notToBeError();
      expect( f("ｱ") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"ｱ"});
      expect( f("ｲ") ).toBeValidationError("PROHIBITED_CHARACTER", {character:"ｲ"});
      expect( f("㌔") ).notToBeError();
      expect( f("㍍") ).notToBeError();
      expect( f("\ue000") ).notToBeError();
      expect( f("\ue001") ).notToBeError();
      expect( f("\uF8FF") ).notToBeError();
      expect( f("\uF900") ).notToBeError();
      expect( f("\uFFF0") ).notToBeError();
      expect( f("\uFFFF") ).notToBeError();
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("size", () => {
    const f = ValidationFunctions.size;

    it("超過", () => {
      expect( f(["a", "b", "c", "d"], 3) ).toBeValidationError("SIZE");
      expect( f([1, 2, 3, 4, 5], 3) ).toBeValidationError("SIZE");
    });
    it("超過しない", () => {
      expect( f([1, 2, 3], 3) ).notToBeError();
      expect( f(["a", "b"], 3) ).notToBeError();
      expect( f([], 3) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, 3) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, 3) ).notToBeError();
    });
  });

  describe("notEmpty", () => {
    const f = ValidationFunctions.notEmpty;

    it("空", () => {
      expect( f([]) ).toBeValidationError("NOT_EMPTY");
    });
    it("空でない", () => {
      expect( f([1, 2, 3]) ).notToBeError();
      expect( f(["a", "b"]) ).notToBeError();
    });
    it("null", () => {
      expect( f(null) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined) ).notToBeError();
    });
  });

  describe("max", () => {
    const f = ValidationFunctions.max;

    it("範囲外", () => {
      expect( f(5, 3) ).toBeValidationError("MAX", {max:3});
      expect( f(4, 3) ).toBeValidationError("MAX", {max:3});
      expect( f(5, 4) ).toBeValidationError("MAX", {max:4});
      expect( f(6, 4) ).toBeValidationError("MAX", {max:4});
    });
    it("範囲内", () => {
      expect( f(3, 3) ).notToBeError();
      expect( f(4, 4) ).notToBeError();
      expect( f(2, 3) ).notToBeError();
      expect( f(3, 4) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, 4) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, 4) ).notToBeError();
    });
  });

  describe("min", () => {
    const f = ValidationFunctions.min;

    it("範囲外", () => {
      expect( f(2, 3) ).toBeValidationError("MIN", {min:3});
      expect( f(1, 3) ).toBeValidationError("MIN", {min:3});
      expect( f(3, 4) ).toBeValidationError("MIN", {min:4});
      expect( f(1, 4) ).toBeValidationError("MIN", {min:4});
    });
    it("範囲内", () => {
      expect( f(3, 3) ).notToBeError();
      expect( f(4, 4) ).notToBeError();
      expect( f(4, 3) ).notToBeError();
      expect( f(5, 4) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, 4) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, 4) ).notToBeError();
    });
  });

  describe("range", () => {
    const f = ValidationFunctions.range;

    it("範囲外", () => {
      expect( f(6, {min:2, max:5}) ).toBeValidationError("RANGE", {min:2, max:5});
      expect( f(1, {min:2, max:5}) ).toBeValidationError("RANGE", {min:2, max:5});
    });
    it("範囲内", () => {
      expect( f(2, {min:2, max:5}) ).notToBeError();
      expect( f(5, {min:2, max:5}) ).notToBeError();
      expect( f(3, {min:2, max:5}) ).notToBeError();
    });
    it("null", () => {
      expect( f(null, {min:2, max:5}) ).notToBeError();
    });
    it("undefined", () => {
      expect( f(undefined, {min:2, max:5}) ).notToBeError();
    });
  });

  describe("custom", () => {
    const f = ValidationFunctions.custom;
    const action = function(v) {
      if (v === "a")  return { type : "MAX_LENGTH", maxLength: 11 };
    };

    it("null", () => {
      expect( f(null, action) ).notToBeError();
    });
    it("a", () => {
      expect( f("a", action) ).toBeValidationError("MAX_LENGTH", {maxLength:11});
    });
    it("b", () => {
      expect( f("b", action) ).notToBeError();
    });
  });

});
