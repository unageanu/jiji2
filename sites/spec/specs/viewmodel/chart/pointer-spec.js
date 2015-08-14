import ContainerJS      from "container-js"
import DateWithOffset   from "date-with-offset"
import _                from "underscore"

import CandleSticks     from "src/viewmodel/chart/candle-sticks"
import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import ContainerFactory from "../../../utils/test-container-factory"
import ChartOperator    from "./chart-operator"
import CustomMatchers   from "../../../utils/custom-matchers"

describe("Pointer", () => {

  var operator;
  var target;
  var xhrManager;

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);

    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    let chart            = factory.createChart();
    operator             = new ChartOperator(chart);
    target               = chart.pointer;
    xhrManager           = chart.slider.context.rates.rateService.xhrManager;

    Dates.setTimezoneOffset(540);
  });

  afterEach( ()=> Dates.resetTimezoneOffset() );

  it("必要なデータが揃うと、各種プロパティが初期化される", () => {
    expect(target.x).toEqual(undefined);
    expect(target.y).toEqual(undefined);
    expect(target.time).toEqual(undefined);
    expect(target.rate).toEqual(undefined);
    expect(target.price).toEqual(undefined);
    expect(target.balance).toEqual(undefined);

    // データを設定
    operator.initialize(300, 300, "one_hour", 100);

    expect(target.x).toEqual(239);
    expect(target.y).toEqual(101);
    expect(target.time).toEq(Dates.date("2015-05-10T00:00:00Z"));
    expect(target.rate.data).toEqual(operator.createRates([{
      high:179.0, low:177.7, open:177.7, close:178.5,
      timestamp:Dates.date("2015-05-10T00:00:00Z")
    }])[0]);
    expect(target.price).toEqual(178.5);
    expect(target.balance).toEqual(null);

    // ポインターを移動
    target.x = 233;
    expect(target.x).toEqual(233);
    expect(target.y).toEqual(101);
    expect(target.time).toEq(Dates.date("2015-05-09T23:00:00Z"));
    expect(target.rate).toEqual(undefined);
    expect(target.price).toEqual(178.5);
    expect(target.balance).toEqual(null);

    target.y = 115;
    expect(target.x).toEqual(233);
    expect(target.y).toEqual(115);
    expect(target.time).toEq(Dates.date("2015-05-09T23:00:00Z"));
    expect(target.rate).toEqual(undefined);
    expect(target.price).toEqual("178.272");
    expect(target.balance).toEqual(null);

    target.x = 179;
    expect(target.x).toEqual(179);
    expect(target.y).toEqual(115);
    expect(target.time).toEq(Dates.date("2015-05-09T14:00:00Z"));
    expect(target.rate.data).toEqual(operator.createRates([{
      high:178.7, low:177.5, open:178.5, close:177.5,
      timestamp:Dates.date("2015-05-09T14:00:00Z")
    }])[0]);
    expect(target.price).toEqual("178.272");
    expect(target.balance).toEqual(null);

    target.y = 275;
    expect(target.x).toEqual(179);
    expect(target.y).toEqual(275);
    expect(target.time).toEq(Dates.date("2015-05-09T14:00:00Z"));
    expect(target.rate.data).toEqual(operator.createRates([{
      high:178.7, low:177.5, open:178.5, close:177.5,
      timestamp:Dates.date("2015-05-09T14:00:00Z")
    }])[0]);
    expect(target.price).toEqual(null);
    expect(target.balance).toEqual("-6480.00");
  });

});
