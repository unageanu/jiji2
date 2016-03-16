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
      Dates.setTimezoneOffset(0);
      expect( Dates.truncate(new Date(2015, 5, 10, 1, 19, 23)) )
        .toEq( new Date(2015, 5, 10) );
      expect( Dates.truncate(new Date(2015, 5, 10, 21, 19, 23)) )
        .toEq( new Date(2015, 5, 10) );
    });
  });
});
