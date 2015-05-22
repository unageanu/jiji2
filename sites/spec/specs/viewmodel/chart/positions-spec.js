import ContainerJS      from "container-js"
import DateWithOffset   from "date-with-offset"
import _                from "underscore"

import CandleSticks     from "src/viewmodel/chart/candle-sticks"
import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import ContainerFactory from "../../../utils/test-container-factory"
import CustomMatchers   from "../../../utils/custom-matchers"
import ChartOperator    from "./chart-operator"

describe("Positions", () => {

  var chart;
  var slider;
  var positions;
  var operator;

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);

    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    chart                = factory.createChart(null, {displayPositonsAndGraphs:true});
    operator             = new ChartOperator(chart);
    slider               = chart.slider;
    positions            = chart.positions;

    Dates.setTimezoneOffset(540);
  });

  afterEach( ()=> Dates.resetTimezoneOffset() );

  it("必要なデータが揃うと、ポジションの取得が行われsticksが更新される", () => {
    // 最初は未初期化
    expect(positions.positions).toEqual(undefined);
    expect(positions.displayPositions).toEqual(undefined);

    // データを設定
    operator.initialize(1000, 300);

    expect(extract(positions.positionsForDisplay)).toEq([
      [{
        normalizedStart: Dates.date("2015-05-08T09:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 5,
        endX: 41
      }, {
        normalizedStart: Dates.date("2015-05-08T18:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T18:00:00Z"),
        startX: 59,
        endX: 59
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T12:00:00Z"),
        startX: 17,
        endX: 23
      }],
      [],
      [],
      [],
      [],
      [],
      []
    ]);
  });


  it("endがnullの場合、未決済と判定される。", () => {
    operator.initialize(1000, 300, "fifteen_minutes");
    chart.slider.preferences.chartInterval = "one_hour";

    const requests = chart.slider.context.rates.rateService.xhrManager.requests;
    requests[0].resolve(operator.createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:Dates.date("2015-05-08T10:00:00Z")}
    ]));
    requests[1].resolve([
      {enteredAt:Dates.date("2015-05-08T09:00:10Z"), exitedAt:Dates.date("2015-05-08T15:30:00Z")},
      {enteredAt:Dates.date("2015-05-08T01:30:10Z")},
      {enteredAt:Dates.date("2015-05-08T16:10:10Z")},
      {enteredAt:Dates.date("2015-05-08T19:30:10Z")},
      {enteredAt:Dates.date("2015-05-08T16:30:10Z"), exitedAt:Dates.date("2015-05-08T18:26:01Z")}
    ]);

    expect(extract(positions.positionsForDisplay)).toEq([
      [{
        normalizedStart: Dates.date("2015-05-08T09:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 5,
        endX: 41
      }, {
        normalizedStart: Dates.date("2015-05-08T16:00:00Z"),
        normalizedEnd: null,
        startX: 47,
        endX: undefined
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T01:00:00Z"),
        normalizedEnd: null,
        startX: -43,
        endX: undefined
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T19:00:00Z"),
        normalizedEnd: null,
        startX: 65,
        endX: undefined
      }, {
        normalizedStart: Dates.date("2015-05-08T16:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T18:00:00Z"),
        startX: 47,
        endX: 59
      }],
      [],
      [],
      [],
      [],
      []
    ]);
  });


  it("同時刻に8以上ポジションがある場合、表示されない。", () => {
    operator.initialize(1000, 300, "fifteen_minutes");
    chart.slider.preferences.chartInterval = "one_hour";

    const requests = chart.slider.context.rates.rateService.xhrManager.requests;
    requests[0].resolve(operator.createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:Dates.date("2015-05-08T10:00:00Z")}
    ]));
    requests[1].resolve([
      {enteredAt:Dates.date("2015-05-08T09:00:10Z"), exitedAt:Dates.date("2015-05-08T15:30:00Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T12:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T11:30:10Z"), exitedAt:Dates.date("2015-05-08T15:00:01Z")},
      {enteredAt:Dates.date("2015-05-08T16:30:10Z"), exitedAt:Dates.date("2015-05-08T18:26:01Z")}
    ]);

    expect(extract(positions.positionsForDisplay)).toEq([
      [{
        normalizedStart: Dates.date("2015-05-08T09:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 5,
        endX: 41
      }, {
        normalizedStart: Dates.date("2015-05-08T16:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T18:00:00Z"),
        startX: 47,
        endX: 59
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T12:00:00Z"),
        startX: 17,
        endX: 23
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }],
      [{
        normalizedStart: Dates.date("2015-05-08T11:00:00Z"),
        normalizedEnd: Dates.date("2015-05-08T15:00:00Z"),
        startX: 17,
        endX: 41
      }]
    ]);
  });


  function extract(displayPositions) {
    return displayPositions.map((array)=>{
      return array.map((item) => {
        return {
          normalizedStart: item.normalizedStart,
          normalizedEnd: item.normalizedEnd,
          startX: item.startX,
          endX: item.endX
        };
      });
    });
  }

});
