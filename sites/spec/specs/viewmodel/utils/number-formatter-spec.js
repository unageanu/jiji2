import NumberFormatter  from "src/viewmodel/utils/number-formatter";

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

  describe("formatPrice ", () => {
    it("null", () => {
      expect( NumberFormatter.formatPrice(null)).toBe("");
    });
    it("0", () => {
      expect( NumberFormatter.formatPrice(0)).toBe("0");
    });
    it("1000", () => {
      expect( NumberFormatter.formatPrice(1000)).toBe("1,000");
    });
    it("44543", () => {
      expect( NumberFormatter.formatPrice(44543)).toBe("44,543");
    });
    it("123456789", () => {
      expect( NumberFormatter.formatPrice(123456789)).toBe("123,456,789");
    });
    it("89", () => {
      expect( NumberFormatter.formatPrice(89)).toBe("89");
    });
    it("999", () => {
      expect( NumberFormatter.formatPrice(999)).toBe("999");
    });
    it("1010", () => {
      expect( NumberFormatter.formatPrice(1010)).toBe("1,010");
    });
    it("1001", () => {
      expect( NumberFormatter.formatPrice(1001)).toBe("1,001");
    });
    it("10100", () => {
      expect( NumberFormatter.formatPrice(10100)).toBe("10,100");
    });
    it("-89", () => {
      expect( NumberFormatter.formatPrice(-89)).toBe("-89");
    });
    it("-999", () => {
      expect( NumberFormatter.formatPrice(-999)).toBe("-999");
    });
    it("-1010", () => {
      expect( NumberFormatter.formatPrice(-1010)).toBe("-1,010");
    });
    it("-1001", () => {
      expect( NumberFormatter.formatPrice(-1001)).toBe("-1,001");
    });
    it("-10100", () => {
      expect( NumberFormatter.formatPrice(-10100)).toBe("-10,100");
    });
    it("-1211.234", () => {
      expect( NumberFormatter.formatPrice(-1211.234)).toBe("-1,211.234");
    });
    it("1211.23456", () => {
      expect( NumberFormatter.formatPrice(1211.23456)).toBe("1,211.23456");
    });
  });

});
