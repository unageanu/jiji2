import Numbers from "src/utils/numbers";

describe("Numbers", () => {

  it("round", () => {
    expect( Numbers.round(121.12345, 4)).toBe( 121.1 );
    expect( Numbers.round(121.12999, 4)).toBe( 121.1 );
    expect( Numbers.round(21.123456, 4)).toBe( 21.12 );
    expect( Numbers.round(1.1234567, 4)).toBe( 1.123 );
    expect( Numbers.round(0.1234567, 4)).toBe( 0.123 );

    expect( Numbers.round(121.12345, 5)).toBe( 121.12 );
    expect( Numbers.round(121.12999, 5)).toBe( 121.12 );
    expect( Numbers.round(21.123456, 5)).toBe( 21.123 );
    expect( Numbers.round(1.1234567, 5)).toBe( 1.1234 );
    expect( Numbers.round(0.1234567, 5)).toBe( 0.1234 );

    expect( Numbers.round(121.12345, 6)).toBe( 121.123 );
    expect( Numbers.round(121.12999, 6)).toBe( 121.129 );
    expect( Numbers.round(21.123456, 6)).toBe( 21.1234 );
    expect( Numbers.round(1.1234567, 6)).toBe( 1.12345 );
    expect( Numbers.round(0.1234567, 6)).toBe( 0.12345 );
  });

  it("getPositiveDigits", () => {
    expect( Numbers.getPositiveDigits(1)).toBe( 1 );
    expect( Numbers.getPositiveDigits(2)).toBe( 1 );
    expect( Numbers.getPositiveDigits(9)).toBe( 1 );
    expect( Numbers.getPositiveDigits(10)).toBe( 2 );
    expect( Numbers.getPositiveDigits(99)).toBe( 2 );
    expect( Numbers.getPositiveDigits(100)).toBe( 3 );
    expect( Numbers.getPositiveDigits(999)).toBe( 3 );
    expect( Numbers.getPositiveDigits(0.001)).toBe( 0 );
    expect( Numbers.getPositiveDigits(0.9)).toBe( 0 );
    expect( Numbers.getPositiveDigits(-1)).toBeNaN();
  });

});
