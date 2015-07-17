import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

describe("Rates", () => {

  var rates;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("rates");
    rates = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = rates.rateService.xhrManager;
  });

  it("初期値", () => {
    expect(rates.range).toBe(undefined);
  });

  it("initializeで利用可能なrateの期間をロードできる", () => {
    rates.initialize();
    xhrManager.requests[0].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  10, 0,  0));
    expect(rates.range.end).toEqual(new Date(2015, 6, 10, 21, 0, 10));
  });

  it("initializeの結果はキャッシュされる。", () => {
    const d1 = rates.initialize();
    const d2 = rates.initialize();
    xhrManager.requests[0].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    expect(ContainerJS.utils.Deferred.unpack(d1)).toEqual({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    expect(ContainerJS.utils.Deferred.unpack(d2)).toEqual({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    const d3 = rates.initialize();
    expect(ContainerJS.utils.Deferred.unpack(d3)).toEqual({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
  });

  it("initializeでエラーとなった場合、結果はキャッシュされない。", () => {
    const d1 = rates.initialize();
    const d2 = rates.initialize();
    xhrManager.requests[0].reject({});

    expect(() => {
      ContainerJS.utils.Deferred.unpack(d1);
    }).toThrowError();
    expect(() => {
      ContainerJS.utils.Deferred.unpack(d2);
    }).toThrowError();

    const d3 = rates.initialize();
    xhrManager.requests[1].resolve({
      start: new Date(2015, 4, 2,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    expect(ContainerJS.utils.Deferred.unpack(d3)).toEqual({
      start: new Date(2015, 4, 2,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
  });



  it("reloadで通貨ペアの一覧を再ロードできる", () => {

    rates.initialize();
    xhrManager.requests[0].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });

    rates.reload();
    xhrManager.requests[1].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 22, 0, 10)
    });

    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  10, 0,  0));
    expect(rates.range.end).toEqual(new Date(2015, 6, 10, 22, 0, 10));
  });

  it("fetchRatesでレート情報をロードできる", () => {
    const d = rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10,  0,  0),
      new Date(2015, 4, 1,  10, 25,  0));

    xhrManager.requests[0].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ]);

    const data = ContainerJS.utils.Deferred.unpack(d);
    expect(data).toEqual([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ]);
  });

  it("fetchRatesで新しいor古いレート情報をロードした場合、rangeも更新される", () => {
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10,  0,  0),
      new Date(2015, 4, 1,  10, 25,  0));

    xhrManager.requests[0].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 10,  0)},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date(2015, 4, 1,  10, 20,  0)}
    ]);

    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  10,  0,  0));
    expect(rates.range.end).toEqual(  new Date(2015, 4, 1,  10, 20,  0));

    // 新しいレートを取得 → rangeのendが伸びる
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  10, 25,  0),
      new Date(2015, 4, 1,  10, 40,  0));
    xhrManager.requests[1].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  10, 30,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  10, 40,  0)}
    ]);
    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  10,  0,  0));
    expect(rates.range.end).toEqual(  new Date(2015, 4, 1,  10, 40,  0));

    // 古いレートを取得 → rangeのstartが伸びる
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  9, 25,  0),
      new Date(2015, 4, 1, 10, 40,  0));
    xhrManager.requests[2].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  9, 30,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1,  9, 40,  0)}
    ]);
    expect(rates.range.start).toEqual(new Date(2015, 4, 1,   9, 30,  0));
    expect(rates.range.end).toEqual(  new Date(2015, 4, 1,  10, 40,  0));

    // 広い範囲を取得すると両帆伸びる場合もある
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  0, 0,  0),
      new Date(2015, 4, 1, 20, 0,  0));
    xhrManager.requests[3].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  0, 0,  0)},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date(2015, 4, 1, 20, 0,  0)}
    ]);
    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  0,  0,  0));
    expect(rates.range.end).toEqual(  new Date(2015, 4, 1, 20,  0,  0));

    // 範囲内のレートを取得した場合は増えない
    rates.fetchRates( "EURUSD", "ten_minute",
      new Date(2015, 4, 1,  0, 0,  0),
      new Date(2015, 4, 1, 20, 0,  0));
    xhrManager.requests[4].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date(2015, 4, 1,  1, 0,  0)}
    ]);
    expect(rates.range.start).toEqual(new Date(2015, 4, 1,  0,  0,  0));
    expect(rates.range.end).toEqual(  new Date(2015, 4, 1, 20,  0,  0));
  });
});
