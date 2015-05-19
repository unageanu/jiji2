import Intervals      from "src/model/trading/intervals"
import CustomMatchers from "../../../utils/custom-matchers"

const m = 60 * 1000;

describe("Intervals", () => {

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);
  });

  it("all()で利用可能な集計期間の一覧を取得できる", () => {
    expect(Intervals.all().length).toEqual(6);
  });

  it("byId()でidに対応する集計期間を取得できる", () => {
    expect(Intervals.byId("one_day")).toEq(
      { id:"one_day", name:"日足", ms: 24 * 60 * m });
    expect(Intervals.byId("fifteen_minutes")).toEq(
      { id:"fifteen_minutes", name:"15分足",  ms: 15 * m });

    expect(Intervals.byId("unknown")).toEq(undefined);
  });

  it("resolveCollectingInterval()で、idに対応する集計期間のミリ秒値を取得できる", () => {
    expect(Intervals.resolveCollectingInterval("one_day")).toBe(24 * 60 * m);
    expect(Intervals.resolveCollectingInterval("fifteen_minutes")).toBe(15 * m);

    expect(Intervals.resolveCollectingInterval("unknown")).toBe( m );
  });

});
