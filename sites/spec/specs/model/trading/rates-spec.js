import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";
import _                from "underscore";

describe("Rates", () => {

  var rates;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("rates");
    rates = ContainerJS.utils.Deferred.unpack(d);
  });

  it("初期値", () => {
    expect(rates.range).toBe(undefined);
  });

  it("initializeで利用可能なrateの期間をロードできる", () => {

    rates.initialize();
    rates.rateService.xhrManager.requests[0].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  10, 0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 6, 10, 21, 0, 10).getTime());
  });

  it("reloadで通貨ペアの一覧を再ロードできる", () => {

    rates.initialize();
    rates.rateService.xhrManager.requests[0].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    rates.reload();
    rates.rateService.xhrManager.requests[1].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 22, 0, 10)
    });

    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  10, 0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 6, 10, 22, 0, 10).getTime());
  });

  it("fetchRatesでレート情報をロードできる", () => {
    const d = rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10,  0,  0),
      new Date(2015, 4, 1,  10, 25,  0));

    rates.rateService.xhrManager.requests[0].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ]);

    const data = ContainerJS.utils.Deferred.unpack(d);
    expect(_.isEqual(data, [
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ])).toBe(true);
  });

  it("fetchRatesで新しいor古いレート情報をロードした場合、rangeも更新される", () => {
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10,  0,  0),
      new Date(2015, 4, 1,  10, 25,  0));

    rates.rateService.xhrManager.requests[0].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ]);

    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  10,  0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 4, 1,  10, 20,  0).getTime());

    // 新しいレートを取得 → rangeのendが伸びる
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10, 25,  0),
      new Date(2015, 4, 1,  10, 40,  0));
    rates.rateService.xhrManager.requests[1].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 30,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 40,  0)}
    ]);
    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  10,  0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 4, 1,  10, 40,  0).getTime());

    // 古いレートを取得 → rangeのstartが伸びる
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  9, 25,  0),
      new Date(2015, 4, 1, 10, 40,  0));
    rates.rateService.xhrManager.requests[2].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  9, 30,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  9, 40,  0)}
    ]);
    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,   9, 30,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 4, 1,  10, 40,  0).getTime());

    // 広い範囲を取得すると両帆伸びる場合もある
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  0, 0,  0),
      new Date(2015, 4, 1, 20, 0,  0));
    rates.rateService.xhrManager.requests[3].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  0, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1, 20, 0,  0)}
    ]);
    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  0,  0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 4, 1, 20,  0,  0).getTime());

    // 範囲内のレートを取得した場合は増えない
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  0, 0,  0),
      new Date(2015, 4, 1, 20, 0,  0));
    rates.rateService.xhrManager.requests[4].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  1, 0,  0)}
    ]);
    expect(rates.range.start.getTime()).toBe(new Date(2015, 4, 1,  0,  0,  0).getTime());
    expect(rates.range.end.getTime()).toBe(  new Date(2015, 4, 1, 20,  0,  0).getTime());
  });
});
