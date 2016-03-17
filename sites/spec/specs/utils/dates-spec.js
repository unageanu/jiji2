import Dates          from "src/utils/dates"
import CustomMatchers from "../../utils/custom-matchers"

describe("Dates", () => {

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);
  });
  afterEach(() => {
    Dates.resetTimezoneOffset();
  });

  it("setTimezoneOffsetで指定したタイムゾーンを持つDateを生成できる", () => {
    Dates.setTimezoneOffset(0);
    expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(12);

    Dates.setTimezoneOffset(60);
    expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(13);
    Dates.setTimezoneOffset(540);
    expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(21);
  });

  describe("truncate", () => {
    it("truncate a date.", () => {
      expect( Dates.truncate(new Date(2015, 5, 10, 1, 19, 23)) )
        .toEq( new Date(2015, 5, 10) );
      expect( Dates.truncate(new Date(2015, 5, 10, 21, 19, 23)) )
        .toEq( new Date(2015, 5, 10) );
    });
  });

  describe("plusDays", () => {
    it("plus 7 days.", () => {
      expect( Dates.plusDays(new Date(2015, 5, 10, 1, 19, 23), 7) )
        .toEq( new Date(2015, 5, 17, 1, 19, 23) );
      expect( Dates.plusDays(new Date(2015, 5, 25, 1, 19, 23), 7) )
        .toEq( new Date(2015, 6, 2, 1, 19, 23) );
    });
    it("plus 0 days.", () => {
      expect( Dates.plusDays(new Date(2015, 5, 10, 1, 19, 23), 0) )
        .toEq( new Date(2015, 5, 10, 1, 19, 23) );
    });
    it("plus -7 days.", () => {
      expect( Dates.plusDays(new Date(2015, 5, 10, 1, 19, 23), -7) )
        .toEq( new Date(2015, 5, 3, 1, 19, 23) );
      expect( Dates.plusDays(new Date(2015, 5, 2, 1, 19, 23), -7) )
        .toEq( new Date(2015, 4, 26, 1, 19, 23) );
    });
  });

  describe("plusYears", () => {
    it("plus 7 years.", () => {
      expect( Dates.plusYears(new Date(2015, 5, 10, 1, 19, 23), 7) )
        .toEq( new Date(2022, 5, 10, 1, 19, 23) );
    });
    it("plus 0 years.", () => {
      expect( Dates.plusYears(new Date(2015, 5, 10, 1, 19, 23), 0) )
        .toEq( new Date(2015, 5, 10, 1, 19, 23) );
    });
    it("plus -7 years.", () => {
      expect( Dates.plusYears(new Date(2015, 5, 10, 1, 19, 23), -7) )
        .toEq( new Date(2008, 5, 10, 1, 19, 23) );
    });
  });

});
