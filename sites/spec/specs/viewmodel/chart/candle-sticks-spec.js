import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";
import CandleSticks     from "src/viewmodel/chart/candle-sticks";
import NumberUtils      from "src/viewmodel/utils/number-utils";
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
    expect(candleSticks.axisLabels).toEqual([
      {value:178, y:123},
      {value:179, y:62},
      {value:180, y:1}
    ]);
    expect(candleSticks.sticks).toEqual([
      { high: 62, low: 123, open: 111, close: 93,  isUp: true,  x:   3 },
      { high: 32, low: 111, open: 93,  close: 32,  isUp: true,  x:   9 },
      { high: 13, low: 62,  open: 32,  close: 62,  isUp: false, x:  15 },
      { high: 62, low: 123, open: 62,  close: 93,  isUp: false, x:  21 },
      { high: 80, low: 154, open: 93,  close: 154, isUp: false, x: 171 },
      { high: 62, low: 141, open: 141, close: 93,  isUp: true,  x: 231 }
    ]);
  });

  it("rangeが更新されると、それに応じてデータの再取得が行われる", () => {
    initialize();
    slider.positionX = 90;
    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-03T20:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-03T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-03T18:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.axisLabels).toEqual([
      {value:179, y:84}
    ]);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x: 27 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x: 21 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 15 }
    ]);
  });

  it("集計期間を変更すると、状態が更新される", () => {
    initialize();

    slider.preferences.chartInterval = "fifteen_minutes";

    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-09T23:30:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-09T23:45:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-10T00:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.axisLabels).toEqual([
      {value:179, y:84}
    ]);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x: 219 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x: 225 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 231 }
    ]);
  });

  it("通貨ペアを変更すると、状態が更新される", () => {
    initialize();

    slider.preferences.preferredPair = "EURUSD";

    expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
    slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:new Date("2015-05-08T10:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:new Date("2015-05-09T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-10T00:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.axisLabels).toEqual([
      {value:179, y:84}
    ]);
    expect(candleSticks.sticks).toEqual([
      { high: 84, low: 101, open: 101, close: 101, isUp: false, x:   3 },
      { high: 84, low: 154, open: 127, close:  84, isUp:  true, x: 201 },
      { high: 13, low:  84, open:  40, close:  84, isUp: false, x: 231 }
    ]);
  });

  describe( "axisLabelsのパターン", () => {
    it("レートがすべて同一の場合も、一定値以上のrangeが確保される。axisLabelsも正しく取得できる", () => {
      initialize();
      slider.positionX = 90;
      expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
      slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
        {high:179.0, low:179.0, open:179.0, close:179.0, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(coordinateCalculator.rateRange.highest).toEqual(179.01);
      expect(coordinateCalculator.rateRange.lowest).toEqual(178.99);
      expect(candleSticks.axisLabels).toEqual([
        {value:179, y:84}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 84, low: 84, open: 84, close: 84, isUp: false, x:  27 }
      ]);


      slider.positionX = 84;
      expect(slider.rates.rateService.xhrManager.requests.length).toEqual(2);
      slider.rates.rateService.xhrManager.requests[1].resolve(createRates([
        {high:179.222, low:179.222, open:179.222, close:179.222, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(coordinateCalculator.rateRange.highest).toEqual(179.232);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000)).toEqual(1792120);
      expect(candleSticks.axisLabels).toEqual([
        {value:179.22, y:100},
        {value:179.23, y:16}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 84, low: 84, open: 84, close: 84, isUp: false, x:   51 }
      ]);


      slider.positionX = 90;
      slider.rates.rateService.xhrManager.requests[2].resolve(createRates([
        {high:1.79222, low:1.79222, open:1.79222, close:1.79222, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1792320);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1792120);
      expect(candleSticks.axisLabels).toEqual([
        {value:1.7922, y:100},
        {value:1.7923, y:16}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 84, low: 84, open: 84, close: 84, isUp: false, x:   27 }
      ]);
    });
    it("レートの範囲が狭い場合も、axisLabelsを正しく取得できる", () => {
      initialize();
      slider.positionX = 90;
      expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
      slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
        {high:179.002, low:179.000, open:179.0, close:179.002, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1790120);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1789900);
      expect(candleSticks.axisLabels).toEqual([
        {value:179,    y:91},
        {value:179.01, y:15}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 76, low: 91, open: 91, close: 76, isUp: true, x:   27 }
      ]);


      slider.positionX = 84;
      slider.rates.rateService.xhrManager.requests[1].resolve(createRates([
        {high:179.025, low:179.013, open:179.02, close:179.02, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1790262);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1790118);
      expect(candleSticks.axisLabels).toEqual([
        {value:179.02, y:72}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 14, low: 153, open: 72, close: 72, isUp: false, x:   51 }
      ]);


      slider.positionX = 90;
      slider.rates.rateService.xhrManager.requests[2].resolve(createRates([
        {high:1.79223, low:1.79222, open:1.79222, close:1.79222, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1792330);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1792120);
      expect(candleSticks.axisLabels).toEqual([
        {value:1.7922, y:103},
        {value:1.7923, y:23}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 79, low: 88, open: 88, close: 88, isUp: false, x:   27 }
      ]);
    });
    it("レートの範囲が広い場合も、axisLabelsを正しく取得できる", () => {
      initialize();
      slider.positionX = 90;
      expect(slider.rates.rateService.xhrManager.requests.length).toEqual(1);
      slider.rates.rateService.xhrManager.requests[0].resolve(createRates([
        {high:190.002, low:179.000, open:179.0, close:179.002, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1911022);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1778998);
      expect(candleSticks.axisLabels).toEqual([
        {value:180, y:141},
        {value:190, y:14}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 14, low: 154, open: 154, close: 153, isUp: true, x:   27 }
      ]);


      slider.positionX = 86;
      slider.rates.rateService.xhrManager.requests[1].resolve(createRates([
        {high:1.82223, low:1.79222, open:1.79222, close:1.79222, timestamp:new Date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1825231);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1789219);
      expect(candleSticks.axisLabels).toEqual([
        {value:1.79, y:164},
        {value:1.8,  y:117},
        {value:1.81, y:71},
        {value:1.82, y:24}
      ]);
      expect(candleSticks.sticks).toEqual([
        { high: 14, low: 153, open: 153, close: 153, isUp: false, x:   45 }
      ]);
    });
  });

  it("calculateStep でラベルのメモリを計算できる", () => {
    expect(CandleSticks.calculateStep(121.123456)).toEqual(0.01);
    expect(CandleSticks.calculateStep(100.123456)).toEqual(0.01);
    expect(CandleSticks.calculateStep( 99.123456)).toEqual(0.001);
    expect(CandleSticks.calculateStep( 21.123456)).toEqual(0.001);
    expect(CandleSticks.calculateStep(  9.123456)).toEqual(0.0001);
    expect(CandleSticks.calculateStep(  1.123456)).toEqual(0.0001);
    expect(CandleSticks.calculateStep(  0.123456)).toEqual(0.0001);
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
    slider.rates.rateService.xhrManager.requests[1].resolve(createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:new Date("2015-05-08T10:00:00Z")},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:new Date("2015-05-08T11:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:new Date("2015-05-08T12:00:00Z")},
      {high:179.0, low:178.0, open:179.0, close:178.5, timestamp:new Date("2015-05-08T13:00:00Z")},
      {high:178.7, low:177.5, open:178.5, close:177.5, timestamp:new Date("2015-05-09T14:00:00Z")},
      {high:179.0, low:177.7, open:177.7, close:178.5, timestamp:new Date("2015-05-10T00:00:00Z")}
    ]));
    slider.rates.rateService.xhrManager.clear();
  }
  function createRates(seed) {
    return seed.map((item) => {
      return {
        high:  { ask: item.high  + 0.003, bid: item.high  },
        low:   { ask: item.low   + 0.003, bid: item.low   },
        open:  { ask: item.open  + 0.003, bid: item.open  },
        close: { ask: item.close + 0.003, bid: item.close },
        timestamp: item.timestamp
      };
    });
  }
});
