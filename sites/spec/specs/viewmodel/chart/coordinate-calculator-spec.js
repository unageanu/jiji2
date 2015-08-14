import ContainerJS      from "container-js"
import DateWithOffset   from "date-with-offset"
import _                from "underscore"

import CandleSticks     from "src/viewmodel/chart/candle-sticks"
import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import ContainerFactory from "../../../utils/test-container-factory"
import ChartOperator    from "./chart-operator"
import CustomMatchers   from "../../../utils/custom-matchers"

describe("coordinateCalculator", () => {

  var operator;
  var target;
  var xhrManager;

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);

    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    let chart                = factory.createChart();
    operator             = new ChartOperator(chart);
    target               = chart.coordinateCalculator;
    xhrManager           = chart.slider.context.rates.rateService.xhrManager;

    Dates.setTimezoneOffset(540);
  });

  afterEach( ()=> Dates.resetTimezoneOffset() );

  it("必要なデータが揃うと、座標計算ができる", () => {
    expect(target.displayableCandleCount).toEqual(undefined);
    expect(target.rateRange).toEqual(undefined);
    expect(
      () => target.calculateX(Dates.date("2015-05-01T00:01:10Z"))
    ).toThrowError();
    expect(target.calculateTime(100)).toBe(null);
    expect(
      () => target.calculateY(172)
    ).toThrowError();
    expect(target.calculatePrice(-100)).toBe(null);

    // データを設定
    operator.initialize(300, 300);

    expect(target.displayableCandleCount).toEqual(39);
    expect(target.rateRange.highest).toEqual(180.03);
    expect(target.rateRange.lowest).toEqual(177.27);

    expect(target.calculateX(Dates.date("2015-05-08T16:00:00Z"))).toEqual(47);
    expect(target.calculateTime(47)).toEq(Dates.date("2015-05-08T16:00:00Z"));
    expect(target.calculateX(Dates.date("2015-05-09T00:01:00Z"))).toEqual(95);
    expect(target.calculateTime(95)).toEq(Dates.date("2015-05-09T00:00:00Z"));
    expect(target.calculateY(170)).toEqual(618);
    expect(target.calculatePrice(618)).toBe("170.009");
    expect(target.calculateY(178)).toEqual(131);
    expect(target.calculatePrice(131)).toBe("178.009");
    expect(target.calculatePrice(132)).toBe("177.993");
  });

});
