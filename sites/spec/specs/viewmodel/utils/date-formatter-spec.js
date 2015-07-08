import DateFormatter  from "src/viewmodel/utils/date-formatter";

describe("DateFormatter", () => {

  it("format", () => {
      var d = new Date(2013, 2, 2, 10, 2, 10);
      expect(DateFormatter.format(d)).toBe( "2013-03-02 10:02:10" );
      expect(DateFormatter.formatDateYYYYMMDD(d)).toBe( "2013-03-02" );
      expect(DateFormatter.formatDateMMDD(d)).toBe( "03-02" );
      expect(DateFormatter.formatTimeHHMM(d)).toBe( "10:02" );
      expect(DateFormatter.formatTimeHHMMSS(d)).toBe( "10:02:10" );

      expect(DateFormatter.format(null)).toBe( "-" );
  });

  describe("formatPeriod", () => {
    it("null", () => {
      expect(DateFormatter.formatPeriod(null)).toBe( "" );
      expect(DateFormatter.formatPeriod(undefined)).toBe( "" );
    });
    it("0", () => {
      expect(DateFormatter.formatPeriod(0)).toBe( "0秒" );
    });
    it("59", () => {
      expect(DateFormatter.formatPeriod(59)).toBe( "59秒" );
    });
    it("60", () => {
      expect(DateFormatter.formatPeriod(60)).toBe( "1分" );
    });
    it("121", () => {
      expect(DateFormatter.formatPeriod(121)).toBe( "2分1秒" );
    });
    it("60*59+59", () => {
      expect(DateFormatter.formatPeriod(60*59+59)).toBe( "59分59秒" );
    });
    it("5*60*60 +9", () => {
      expect(DateFormatter.formatPeriod(5*60*60 +9))
        .toBe( "5時間9秒" );
    });
    it("5*60*60 +9*60", () => {
      expect(DateFormatter.formatPeriod(5*60*60 +9*60))
        .toBe( "5時間9分" );
    });
    it("5*60*60 +60*12 +9", () => {
      expect(DateFormatter.formatPeriod(5*60*60 +60*12 +9))
        .toBe( "5時間12分9秒" );
    });
    it("23*60*60 +60*59 +59", () => {
      expect(DateFormatter.formatPeriod(23*60*60 +60*59 +59))
        .toBe( "23時間59分59秒" );
    });
    it("24*60*60", () => {
      expect(DateFormatter.formatPeriod(24*60*60))
        .toBe( "1日" );
    });
    it("145*24*60*60+9*60", () => {
      expect(DateFormatter.formatPeriod(145*24*60*60+9*60))
        .toBe( "145日9分" );
    });
  });

});
