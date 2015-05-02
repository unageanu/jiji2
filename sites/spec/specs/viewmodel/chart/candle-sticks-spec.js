import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";
import CandleSticks     from "src/viewmodel/chart/candle-sticks";
import _                from "underscore";

describe("CandleSticks", () => {

  var candleSticks;
  var chart;
  var slider;
  var coordinateCalculator;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    chart                = factory.createChart();
    candleSticks         = chart.candleSticks;
    slider               = chart.slider;
    coordinateCalculator = chart.coordinateCalculator;
  });

  it("必要なデータが揃うと、レートの取得が行われsticksが更新される", () => {
    // 最初は未初期化
    expect(candleSticks.stageSize).toEqual(undefined);
    expect(coordinateCalculator.displayableCandleCount).toEqual(undefined);
    expect(coordinateCalculator.rateRange).toEqual(undefined);
    expect(candleSticks.sticks).toEqual(undefined);

    // データを設定
    initialize();

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(180.03);
    expect(coordinateCalculator.rateRange.lowest).toEqual(177.27);
    expect(candleSticks.sticks).toEqual([
      { high: 62, low: 123, open: 111, close: 93,  isUp: true,  x:  3 },
      { high: 32, low: 111, open: 93,  close: 32,  isUp: true,  x:  9 },
      { high: 13, low: 62,  open: 32,  close: 62,  isUp: false, x: 15 },
      { high: 62, low: 123, open: 62,  close: 93,  isUp: false, x: 21 },
      { high: 80, low: 154, open: 93,  close: 154, isUp: false, x: 27 },
      { high: 62, low: 141, open: 141, close: 93,  isUp: true,  x: 33 }
    ]);
  });

  it("rangeが更新されると、それに応じてデータの再取得が行われる", () => {
    initialize();

    slider.positionX = 900;
    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-01T20:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-01T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-01T18:00:00Z")}
    ]);

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x:  3 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x:  9 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 15 }
    ]);
  });

  it("集計期間を変更すると、状態が更新される", () => {
    initialize();

    slider.preferences.chartInterval = "fifteen_minutes";

    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-01T20:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-01T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-01T18:00:00Z")}
    ]);

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x:  3 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x:  9 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 15 }
    ]);
  });

  it("通貨ペアを変更すると、状態が更新される", () => {
    initialize();

    slider.preferences.preferredPair = "EURUSD";

    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-01T20:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-01T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-01T18:00:00Z")}
    ]);

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x:  3 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x:  9 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 15 }
    ]);
  });


  function initialize(width=1000, candleCount=20, interval="one_hour") {
    chart.stageSize = {w:300, h:200};
    slider.rates.initialize();
    slider.rates.rateService.xhrManager.requests[0].resolve({
      start: new Date("2015-05-01T00:01:10Z"),
      end:   new Date("2015-05-10T00:02:20Z")
    });
    slider.preferences.chartInterval = interval;
    slider.preferences.preferredPair = "USDJPY";
    slider.rates.rateService.xhrManager.requests[1].resolve([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date("2015-05-01T20:00:00Z")},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date("2015-05-01T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-01T18:00:00Z")},
      {high:179.0, low:178.0, open:179.0, close:178.5, timestamp:new Date("2015-05-01T17:00:00Z")},
      {high:178.7, low:177.5, open:178.5, close:177.5, timestamp:new Date("2015-05-01T16:00:00Z")},
      {high:179.0, low:177.7, open:177.7, close:178.5, timestamp:new Date("2015-05-01T15:00:00Z")}
    ]);
    slider.rates.rateService.xhrManager.clear();
  }

});
