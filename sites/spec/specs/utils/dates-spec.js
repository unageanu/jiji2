import Dates from "src/utils/dates"

describe("Dates", () => {

    it("setTimezoneOffsetで指定したタイムゾーンを持つDateを生成できる", () => {
      Dates.setTimezoneOffset(0);
      expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(12);

      Dates.setTimezoneOffset(60);
      expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(13);
      Dates.setTimezoneOffset(540);
      expect( Dates.date("2015-05-10T12:00:00.000Z").getHours() ).toEqual(21);

      Dates.resetTimezoneOffset();
    });

});
