import ContainerJS      from "container-js"
import DateWithOffset   from "date-with-offset"
import _                from "underscore"

import ChartOperator    from "./chart-operator"
import CandleSticks     from "src/viewmodel/chart/candle-sticks"
import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import ContainerFactory from "../../../utils/test-container-factory"

describe("CandleSticks", () => {

  var operator;
  var candleSticks;
  var chart;
  var slider;
  var coordinateCalculator;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    chart                = factory.createChart();
    operator             = new ChartOperator(chart);
    candleSticks         = chart.candleSticks;
    slider               = chart.slider;
    coordinateCalculator = chart.coordinateCalculator;
    xhrManager           = slider.context.rates.rateService.xhrManager;

    Dates.setTimezoneOffset(540);

  });

  afterEach( ()=> Dates.resetTimezoneOffset() );

  it("必要なデータが揃うと、レートの取得が行われsticksが更新される", () => {
    // 最初は未初期化
    expect(candleSticks.stageSize).toEqual(undefined);
    expect(coordinateCalculator.displayableCandleCount).toEqual(undefined);
    expect(coordinateCalculator.rateRange).toEqual(undefined);
    expect(candleSticks.sticks).toEqual(undefined);

    // データを設定
    operator.initialize(300, 300);

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(180.03);
    expect(coordinateCalculator.rateRange.lowest).toEqual(177.27);
    expect(candleSticks.verticalAxisLabels).toEqual([
      {value:178, y:131},
      {value:179, y:70},
      {value:180, y:9}
    ]);
    expect(candleSticks.horizontalAxisLabels).toEqual([
      {value:"05-09 01:00", x:47},
      {value:"09:00",       x:95},
      {value:"17:00",       x:143},
      {value:"05-10 01:00", x:191},
      {value:"09:00",       x:239}
    ]);
    expect(candleSticks.axisPosition).toEqual({
      vertical: 176, horizontal: 244, verticalSpliter: null
    });
    expect(ignoreData(candleSticks.sticks)).toEqual([
      { high: 70, low: 131, open: 119, close: 101, isUp:  true, x:  11 },
      { high: 40, low: 119, open: 101, close:  40, isUp:  true, x:  17 },
      { high: 21, low:  70, open:  40, close:  70, isUp: false, x:  23 },
      { high: 70, low: 131, open:  70, close: 101, isUp: false, x:  29 },
      { high: 88, low: 162, open: 101, close: 162, isUp: false, x: 179 },
      { high: 70, low: 149, open: 149, close: 101, isUp:  true, x: 239 }
    ]);
  });

  it("rangeが更新されると、それに応じてデータの再取得が行われる", () => {
    operator.initialize(300, 300);
    slider.positionX = 90;
    expect(xhrManager.requests.length).toEqual(4);
    xhrManager.requests[0].resolve(operator.createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:Dates.date("2015-05-03T20:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:Dates.date("2015-05-03T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:Dates.date("2015-05-03T18:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.verticalAxisLabels).toEqual([
      {value:178.5, y:135},
      {value:179,   y:92},
      {value:179.5, y:48}
    ]);
    expect(candleSticks.horizontalAxisLabels).toEqual([
      {value:"09:00",       x:59},
      {value:"17:00",       x:107},
      {value:"05-05 01:00", x:155},
      {value:"09:00",       x:203}
    ]);
    expect(candleSticks.axisPosition).toEqual({
      vertical: 176, horizontal: 244, verticalSpliter: null
    });
    expect(ignoreData(candleSticks.sticks)).toEqual([
      { high: 92, low: 109, open: 109, close: 109, isUp: false, x: 35 },
      { high: 92, low: 162, open: 135, close:  92, isUp: true,  x: 29 },
      { high: 21, low:  92, open:  48, close:  92, isUp: false, x: 23 }
    ]);
  });

  it("集計期間を変更すると、状態が更新される", () => {
    operator.initialize(300, 300);

    slider.preferences.chartInterval = "fifteen_minutes";

    expect(xhrManager.requests.length).toEqual(4);
    xhrManager.requests[0].resolve(operator.createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:Dates.date("2015-05-09T23:30:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:Dates.date("2015-05-09T23:45:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:Dates.date("2015-05-10T00:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.verticalAxisLabels).toEqual([
      {value:178.5, y:135},
      {value:179,   y:92},
      {value:179.5, y:48}
    ]);
    expect(candleSticks.horizontalAxisLabels).toEqual([
      {value:"05-10 01:00", x:47},
      {value:"03:00",       x:95},
      {value:"05:00",       x:143},
      {value:"07:00",       x:191},
      {value:"09:00",       x:239}
    ]);
    expect(candleSticks.axisPosition).toEqual({
      vertical: 176, horizontal: 244, verticalSpliter: null
    });
    expect(ignoreData(candleSticks.sticks)).toEqual([
      { high: 92, low: 109, open: 109, close: 109, isUp: false, x: 227 },
      { high: 92, low: 162, open: 135, close:  92, isUp: true,  x: 233 },
      { high: 21, low:  92, open:  48, close:  92, isUp: false, x: 239 }
    ]);
  });

  it("通貨ペアを変更すると、状態が更新される", () => {
    operator.initialize(300, 300);

    slider.preferences.preferredPair = "EURUSD";

    expect(xhrManager.requests.length).toEqual(1);
    xhrManager.requests[0].resolve(operator.createRates([
      {high:179.0, low:178.8, open:178.8, close:178.8, timestamp:Dates.date("2015-05-08T10:00:00Z")},
      {high:179.0, low:178.2, open:178.5, close:179.0, timestamp:Dates.date("2015-05-09T19:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:Dates.date("2015-05-10T00:00:00Z")}
    ]));

    expect(candleSticks.stageSize).toEqual({w:300, h:200});
    expect(coordinateCalculator.displayableCandleCount).toEqual(39);
    expect(coordinateCalculator.rateRange.highest).toEqual(179.96);
    expect(coordinateCalculator.rateRange.lowest).toEqual(178.04);
    expect(candleSticks.verticalAxisLabels).toEqual([
      {value:178.5, y:135},
      {value:179,   y:92},
      {value:179.5, y:48}
    ]);
    expect(candleSticks.horizontalAxisLabels).toEqual([
      {value:"05-09 01:00", x:47},
      {value:"09:00",       x:95},
      {value:"17:00",       x:143},
      {value:"05-10 01:00", x:191},
      {value:"09:00",       x:239}
    ]);
    expect(candleSticks.axisPosition).toEqual({
      vertical: 176, horizontal: 244, verticalSpliter: null
    });
    expect(ignoreData(candleSticks.sticks)).toEqual([
      { high: 92, low: 109, open: 109, close: 109, isUp: false, x:  11 },
      { high: 92, low: 162, open: 135, close:  92, isUp: true,  x: 209 },
      { high: 21, low:  92, open:  48, close:  92, isUp: false, x: 239 }
    ]);
  });

  describe( "verticalAxisLabelsのパターン", () => {
    it("レートがすべて同一の場合も、一定値以上のrangeが確保される。verticalAxisLabelsも正しく取得できる", () => {
      operator.initialize(300, 300);
      slider.positionX = 90;
      expect(xhrManager.requests.length).toEqual(4);
      xhrManager.requests[0].resolve(operator.createRates([
        {high:179.0, low:179.0, open:179.0, close:179.0, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(coordinateCalculator.rateRange.highest).toEqual(179.01);
      expect(coordinateCalculator.rateRange.lowest).toEqual(178.99);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:178.995, y:134},
        {value:179,     y: 92},
        {value:179.005, y: 50}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 92, low: 92, open: 92, close: 92, isUp: false, x:  35 }
      ]);


      slider.positionX = 84;
      expect(xhrManager.requests.length).toEqual(8);
      xhrManager.requests[4].resolve(operator.createRates([
        {high:179.222, low:179.222, open:179.222, close:179.222, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(coordinateCalculator.rateRange.highest).toEqual(179.232);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000)).toEqual(1792120);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:179.215, y:150},
        {value:179.22,  y:108},
        {value:179.225, y: 66},
        {value:179.23,  y: 24}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 92, low: 92, open: 92, close: 92, isUp: false, x:   59 }
      ]);


      slider.positionX = 90;
      xhrManager.requests[8].resolve(operator.createRates([
        {high:1.79222, low:1.79222, open:1.79222, close:1.79222, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1792320);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1792120);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:1.79215, y:150},
        {value:1.7922,  y:108},
        {value:1.79225, y: 66},
        {value:1.7923,  y: 24}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 92, low: 92, open: 92, close: 92, isUp: false, x:   35 }
      ]);
    });
    it("レートの範囲が狭い場合も、verticalAxisLabelsを正しく取得できる", () => {
      operator.initialize(300, 300);
      slider.positionX = 90;
      expect(xhrManager.requests.length).toEqual(4);
      xhrManager.requests[0].resolve(operator.createRates([
        {high:179.002, low:179.000, open:179.0, close:179.002, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1790120);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1789900);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:179,     y:99},
        {value:179.01,  y:23}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 84, low: 99, open: 99, close: 84, isUp: true, x:   35 }
      ]);


      slider.positionX = 84;
      xhrManager.requests[4].resolve(operator.createRates([
        {high:179.025, low:179.013, open:179.02, close:179.02, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1790262);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1790118);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:179.015, y:138},
        {value:179.019, y: 80},
        {value:179.024, y: 22}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 22, low: 161, open: 80, close: 80, isUp: false, x:   59 }
      ]);


      slider.positionX = 90;
      xhrManager.requests[8].resolve(operator.createRates([
        {high:1.79223, low:1.79222, open:1.79222, close:1.79222, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1792330);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1792120);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:1.7922, y:111},
        {value:1.7923, y:31}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 87, low: 96, open: 96, close: 96, isUp: false, x:   35 }
      ]);
    });
    it("レートの範囲が広い場合も、verticalAxisLabelsを正しく取得できる", () => {
      operator.initialize(300, 300);
      slider.positionX = 90;
      expect(xhrManager.requests.length).toEqual(4);
      xhrManager.requests[0].resolve(operator.createRates([
        {high:190.002, low:179.000, open:179.0, close:179.002, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*10000)).toEqual(1911022);
      expect(Math.round(coordinateCalculator.rateRange.lowest*10000) ).toEqual(1778998);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:180, y:149},
        {value:185, y:85},
        {value:190, y:22}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 22, low: 162, open: 162, close: 161, isUp: true, x:   35 }
      ]);


      slider.positionX = 86;
      xhrManager.requests[4].resolve(operator.createRates([
        {high:1.82223, low:1.79222, open:1.79222, close:1.79222, timestamp:Dates.date("2015-05-03T20:00:00Z")}
      ]));

      expect(Math.round(coordinateCalculator.rateRange.highest*1000000)).toEqual(1825231);
      expect(Math.round(coordinateCalculator.rateRange.lowest *1000000)).toEqual(1789219);
      expect(candleSticks.verticalAxisLabels).toEqual([
        {value:1.79,  y:172},
        {value:1.8,   y:125},
        {value:1.81,  y:79},
        {value:1.82,  y:32}
      ]);
      expect(ignoreData(candleSticks.sticks)).toEqual([
        { high: 22, low: 161, open: 161, close: 161, isUp: false, x:   53 }
      ]);
    });
  });

  describe( "horizontalAxisLabelsのパターン", () => {
    it("stepが1日以上になる場合、mm:dd形式になる", () => {
      operator.initialize(300, 300);

      slider.preferences.chartInterval = "six_hours";
      expect(candleSticks.horizontalAxisLabels).toEqual([
        {value:"05-01", x:23},
        {value:"05-03", x:71},
        {value:"05-05", x:119},
        {value:"05-07", x:167},
        {value:"05-09", x:215}
      ]);

      slider.preferences.chartInterval = "one_day";
      expect(candleSticks.horizontalAxisLabels).toEqual([
        {value:"04-03", x:17},
        {value:"04-11", x:65},
        {value:"04-19", x:113},
        {value:"04-27", x:161},
        {value:"05-05", x:209}
      ]);
    });
  });

  it("calculateStep でラベルのメモリを計算できる", () => {
    expect(CandleSticks.calculateStep(121.123456)).toEqual(0.001);
    expect(CandleSticks.calculateStep(100.123456)).toEqual(0.001);
    expect(CandleSticks.calculateStep( 99.123456)).toEqual(0.0001);
    expect(CandleSticks.calculateStep( 21.123456)).toEqual(0.0001);
    expect(CandleSticks.calculateStep(  9.123456)).toEqual(0.00001);
    expect(CandleSticks.calculateStep(  1.123456)).toEqual(0.00001);
    expect(CandleSticks.calculateStep(  0.123456)).toEqual(0.00001);
  });

  function ignoreData(sticks) {
    sticks.forEach((value) => delete value.data );
    return sticks;
  }

});
