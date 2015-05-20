import NumberUtils from "src/utils/number-utils";

describe("NumberUtils", () => {

  it("round", () => {
    expect( NumberUtils.round(121.12345, 4)).toBe( 121.1 );
    expect( NumberUtils.round(121.12999, 4)).toBe( 121.1 );
    expect( NumberUtils.round(21.123456, 4)).toBe( 21.12 );
    expect( NumberUtils.round(1.1234567, 4)).toBe( 1.123 );
    expect( NumberUtils.round(0.1234567, 4)).toBe( 0.123 );

    expect( NumberUtils.round(121.12345, 5)).toBe( 121.12 );
    expect( NumberUtils.round(121.12999, 5)).toBe( 121.12 );
    expect( NumberUtils.round(21.123456, 5)).toBe( 21.123 );
    expect( NumberUtils.round(1.1234567, 5)).toBe( 1.1234 );
    expect( NumberUtils.round(0.1234567, 5)).toBe( 0.1234 );

    expect( NumberUtils.round(121.12345, 6)).toBe( 121.123 );
    expect( NumberUtils.round(121.12999, 6)).toBe( 121.129 );
    expect( NumberUtils.round(21.123456, 6)).toBe( 21.1234 );
    expect( NumberUtils.round(1.1234567, 6)).toBe( 1.12345 );
    expect( NumberUtils.round(0.1234567, 6)).toBe( 0.12345 );
  });

  it("getPositiveDigits", () => {
    expect( NumberUtils.getPositiveDigits(1)).toBe( 1 );
    expect( NumberUtils.getPositiveDigits(2)).toBe( 1 );
    expect( NumberUtils.getPositiveDigits(9)).toBe( 1 );
    expect( NumberUtils.getPositiveDigits(10)).toBe( 2 );
    expect( NumberUtils.getPositiveDigits(99)).toBe( 2 );
    expect( NumberUtils.getPositiveDigits(100)).toBe( 3 );
    expect( NumberUtils.getPositiveDigits(999)).toBe( 3 );
    expect( NumberUtils.getPositiveDigits(0.001)).toBe( 0 );
    expect( NumberUtils.getPositiveDigits(0.9)).toBe( 0 );
    expect( NumberUtils.getPositiveDigits(-1)).toBeNaN();
  });

});
