import DateFormatter  from "src/viewmodel/utils/date-formatter";

describe("DateFormatter", () => {

  it("format", () => {
      var d = new Date(2013, 2, 2, 10, 2, 10);
      expect(DateFormatter.format(d)).toBe( "2013-03-02 10:02:10" );
      expect(DateFormatter.formatDateYYYYMMDD(d)).toBe( "2013-03-02" );
      expect(DateFormatter.formatDateMMDD(d)).toBe( "03-02" );
      expect(DateFormatter.formatTimeHHMM(d)).toBe( "10:02" );
      expect(DateFormatter.formatTimeHHMMSS(d)).toBe( "10:02:10" );
  });

});
