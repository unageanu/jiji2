import NumberFormatter  from "src/viewmodel/utils/number-formatter"

describe("NumberFormatter", () => {

  describe("paddingZero", () => {
    it("2ケタ補完", () => {
      expect( NumberFormatter.paddingZero(9, 3)).toBe( "009");
      expect( NumberFormatter.paddingZero(19, 3)).toBe( "019");
      expect( NumberFormatter.paddingZero(999, 4)).toBe( "0999");
    });
    it("補完不要", () => {
      expect( NumberFormatter.paddingZero(9, 1)).toBe( "9");
      expect( NumberFormatter.paddingZero(9, 0)).toBe( "9");
      expect( NumberFormatter.paddingZero(19, 2)).toBe( "19");
      expect( NumberFormatter.paddingZero(999, 2)).toBe( "999");
    });
  });

  describe("insertThousandsSeparator ", () => {
    it("null", () => {
      expect( NumberFormatter.insertThousandsSeparator(null)).toBe("");
    });
    it("0", () => {
      expect( NumberFormatter.insertThousandsSeparator(0)).toBe("0");
    });
    it("1000", () => {
      expect( NumberFormatter.insertThousandsSeparator(1000)).toBe("1,000");
    });
    it("44543", () => {
      expect( NumberFormatter.insertThousandsSeparator(44543)).toBe("44,543");
    });
    it("123456789", () => {
      expect( NumberFormatter.insertThousandsSeparator(123456789)).toBe("123,456,789");
    });
    it("89", () => {
      expect( NumberFormatter.insertThousandsSeparator(89)).toBe("89");
    });
    it("999", () => {
      expect( NumberFormatter.insertThousandsSeparator(999)).toBe("999");
    });
    it("1010", () => {
      expect( NumberFormatter.insertThousandsSeparator(1010)).toBe("1,010");
    });
    it("1001", () => {
      expect( NumberFormatter.insertThousandsSeparator(1001)).toBe("1,001");
    });
    it("10100", () => {
      expect( NumberFormatter.insertThousandsSeparator(10100)).toBe("10,100");
    });
    it("-89", () => {
      expect( NumberFormatter.insertThousandsSeparator(-89)).toBe("-89");
    });
    it("-999", () => {
      expect( NumberFormatter.insertThousandsSeparator(-999)).toBe("-999");
    });
    it("-1010", () => {
      expect( NumberFormatter.insertThousandsSeparator(-1010)).toBe("-1,010");
    });
    it("-1001", () => {
      expect( NumberFormatter.insertThousandsSeparator(-1001)).toBe("-1,001");
    });
    it("-10100", () => {
      expect( NumberFormatter.insertThousandsSeparator(-10100)).toBe("-10,100");
    });
    it("-1211.234", () => {
      expect( NumberFormatter.insertThousandsSeparator(-1211.234)).toBe("-1,211.234");
    });
    it("1211.23456", () => {
      expect( NumberFormatter.insertThousandsSeparator(1211.23456)).toBe("1,211.23456");
    });
  });

  describe("formatRatio", () => {
    it("null", () => {
      expect( NumberFormatter.formatRatio(null)).toBe("");
      expect( NumberFormatter.formatRatio(null, 3)).toBe("");
    });
    it("0", () => {
      expect( NumberFormatter.formatRatio(0)).toBe("0.0%");
      expect( NumberFormatter.formatRatio(0, 3)).toBe("0.000%");
    });
    it("0.0011", () => {
      expect( NumberFormatter.formatRatio(0.0011)).toBe("0.1%");
      expect( NumberFormatter.formatRatio(0.0011, 3)).toBe("0.110%");
    });
    it("-0.0011", () => {
      expect( NumberFormatter.formatRatio(-0.0011)).toBe("-0.1%");
      expect( NumberFormatter.formatRatio(-0.0011, 3)).toBe("-0.110%");
    });
    it("0.11", () => {
      expect( NumberFormatter.formatRatio(0.11)).toBe("11.0%");
      expect( NumberFormatter.formatRatio(0.11, 3)).toBe("11.000%");
    });
    it("0.111", () => {
      expect( NumberFormatter.formatRatio(0.111)).toBe("11.1%");
      expect( NumberFormatter.formatRatio(0.111, 3)).toBe("11.100%");
    });
    it("0.1114", () => {
      expect( NumberFormatter.formatRatio(0.1114)).toBe("11.1%");
      expect( NumberFormatter.formatRatio(0.1114, 3)).toBe("11.140%");
    });
    it("0.1115", () => {
      expect( NumberFormatter.formatRatio(0.1115)).toBe("11.2%");
      expect( NumberFormatter.formatRatio(0.1115, 3)).toBe("11.150%");
    });
    it("1/3", () => {
      expect( NumberFormatter.formatRatio(1/3)).toBe("33.3%");
      expect( NumberFormatter.formatRatio(1/3, 3)).toBe("33.333%");
    });
    it("2.1239", () => {
      expect( NumberFormatter.formatRatio(2.1239)).toBe("212.4%");
      expect( NumberFormatter.formatRatio(2.1239, 3)).toBe("212.390%");
    });
    it("-2.1239", () => {
      expect( NumberFormatter.formatRatio(-2.1239)).toBe("-212.4%");
      expect( NumberFormatter.formatRatio(-2.1239, 3)).toBe("-212.390%");
    });
    it("-0.0233", () => {
      expect( NumberFormatter.formatRatio(-0.0233)).toBe("-2.3%");
      expect( NumberFormatter.formatRatio(-0.0233, 3)).toBe("-2.330%");
    });
  });

  describe("formatDecimal", () => {
    it("null", () => {
      expect( NumberFormatter.formatDecimal(null)).toBe("");
    });
    it("0", () => {
      expect( NumberFormatter.formatDecimal(0)).toBe("0");
      expect( NumberFormatter.formatDecimal(0, 1)).toBe("0.0");
      expect( NumberFormatter.formatDecimal(0, 2)).toBe("0.00");
    });
    it("0.1111", () => {
      expect( NumberFormatter.formatDecimal(0.1111)).toBe("0");
      expect( NumberFormatter.formatDecimal(0.1111, 1)).toBe("0.1");
      expect( NumberFormatter.formatDecimal(0.1111, 2)).toBe("0.11");
    });
    it("-0.1111", () => {
      expect( NumberFormatter.formatDecimal(-0.1111)).toBe("-0");
      expect( NumberFormatter.formatDecimal(-0.1111, 1)).toBe("-0.1");
      expect( NumberFormatter.formatDecimal(-0.1111, 2)).toBe("-0.11");
    });
    it("0.135", () => {
      expect( NumberFormatter.formatDecimal(0.135)).toBe("0");
      expect( NumberFormatter.formatDecimal(0.135, 1)).toBe("0.1");
      expect( NumberFormatter.formatDecimal(0.135, 2)).toBe("0.14");
    });
    it("-0.135", () => {
      expect( NumberFormatter.formatDecimal(-0.135)).toBe("-0");
      expect( NumberFormatter.formatDecimal(-0.135, 1)).toBe("-0.1");
      expect( NumberFormatter.formatDecimal(-0.135, 2)).toBe("-0.14");
    });
    it("1/3", () => {
      expect( NumberFormatter.formatDecimal(1/3)).toBe("0");
      expect( NumberFormatter.formatDecimal(1/3, 1)).toBe("0.3");
      expect( NumberFormatter.formatDecimal(1/3, 2)).toBe("0.33");
    });
    it("21.239", () => {
      expect( NumberFormatter.formatDecimal(21.239)).toBe("21");
      expect( NumberFormatter.formatDecimal(21.239, 1)).toBe("21.2");
      expect( NumberFormatter.formatDecimal(21.239, 2)).toBe("21.24");
    });
    it("-21.239", () => {
      expect( NumberFormatter.formatDecimal(-21.239)).toBe("-21");
      expect( NumberFormatter.formatDecimal(-21.239, 1)).toBe("-21.2");
      expect( NumberFormatter.formatDecimal(-21.239, 2)).toBe("-21.24");
    });
  });

  describe("formatPrice", () => {
    it("null", () => {
      expect( NumberFormatter.formatPrice(null)).toEqual({});
    });
    it("0", () => {
      expect( NumberFormatter.formatPrice(0)).toEqual({
        price: 0, str: "0.000", unit: null
      });
    });
    it("0.1111", () => {
      expect( NumberFormatter.formatPrice(0.1111)).toEqual({
        price: 0.1111, str: "0.111", unit: null
      });
    });
    it("-0.1111", () => {
      expect( NumberFormatter.formatPrice(-0.1111)).toEqual({
        price: -0.1111, str: "-0.111", unit: null
      });
    });
    it("0.1356", () => {
      expect( NumberFormatter.formatPrice(0.1356)).toEqual({
        price: 0.1356, str: "0.136", unit: null
      });
    });
    it("-0.1356", () => {
      expect( NumberFormatter.formatPrice(-0.1356)).toEqual({
        price: -0.1356, str: "-0.136", unit: null
      });
    });
    it("1.1356", () => {
      expect( NumberFormatter.formatPrice(1.1356)).toEqual({
        price: 1.1356, str: "1.136", unit: null
      });
    });
    it("-1.1356", () => {
      expect( NumberFormatter.formatPrice(-1.1356)).toEqual({
        price: -1.1356, str: "-1.136", unit: null
      });
    });
    it("19.1356", () => {
      expect( NumberFormatter.formatPrice(19.1356)).toEqual({
        price: 19.1356, str: "19.14", unit: null
      });
    });
    it("-19.1356", () => {
      expect( NumberFormatter.formatPrice(-19.1356)).toEqual({
        price: -19.1356, str: "-19.14", unit: null
      });
    });
    it("199.1356", () => {
      expect( NumberFormatter.formatPrice(199.1356)).toEqual({
        price: 199.1356, str: "199.1", unit: null
      });
    });
    it("-199.1356", () => {
      expect( NumberFormatter.formatPrice(-199.1356)).toEqual({
        price: -199.1356, str: "-199.1", unit: null
      });
    });
    it("2199.1356", () => {
      expect( NumberFormatter.formatPrice(2199.1356)).toEqual({
        price: 2199.1356, str: "2,199", unit: null
      });
    });
    it("-2199.1356", () => {
      expect( NumberFormatter.formatPrice(-2199.1356)).toEqual({
        price: -2199.1356, str: "-2,199", unit: null
      });
    });
    it("32199.1356", () => {
      expect( NumberFormatter.formatPrice(32199.1356)).toEqual({
        price: 32199.1356, str: "32,199", unit: null
      });
    });
    it("-32199.1356", () => {
      expect( NumberFormatter.formatPrice(-32199.1356)).toEqual({
        price: -32199.1356, str: "-32,199", unit: null
      });
    });
    it("432199.1356", () => {
      expect( NumberFormatter.formatPrice(432199.1356)).toEqual({
        price: 432199.1356, str: "432,199", unit: null
      });
    });
    it("-432199.1356", () => {
      expect( NumberFormatter.formatPrice(-432199.1356)).toEqual({
        price: -432199.1356, str: "-432,199", unit: null
      });
    });
    it("999999.1356", () => {
      expect( NumberFormatter.formatPrice(999999.1356)).toEqual({
        price: 999999.1356, str: "999,999", unit: null
      });
    });
    it("-999999.1356", () => {
      expect( NumberFormatter.formatPrice(-999999.1356)).toEqual({
        price: -999999.1356, str: "-999,999", unit: null
      });
    });
    it("1999999.1356", () => {
      expect( NumberFormatter.formatPrice(1999999.1356)).toEqual({
        price: 200, str: "200", unit: "万"
      });
    });
    it("-199999.1356", () => {
      expect( NumberFormatter.formatPrice(-1999999.1356)).toEqual({
        price: -200, str: "-200", unit: "万"
      });
    });
    it("19900000.1356", () => {
      expect( NumberFormatter.formatPrice(19900000.1356)).toEqual({
        price: 1990, str: "1,990", unit: "万"
      });
    });
    it("-19900000.1356", () => {
      expect( NumberFormatter.formatPrice(-19900000.1356)).toEqual({
        price: -1990, str: "-1,990", unit: "万"
      });
    });
  });
});
