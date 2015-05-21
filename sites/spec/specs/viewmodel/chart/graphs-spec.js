import ContainerJS      from "container-js"

import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import ContainerFactory from "../../../utils/test-container-factory"
import CustomMatchers   from "../../../utils/custom-matchers"
import ChartOperator    from "./chart-operator"

describe("Graphs", () => {

  var chart;
  var slider;
  var operator;
  var graphs;

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);

    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    chart                = factory.createChart(true, null, [
      {id:"a", type:"rate", label:"aaa", colors:["#aaa", "#bbb"]},
      {id:"b", type:"line", label:"bbb", colors:["#ccc"], axises:[30, 70]},
      {id:"c", type:"profitOrLoss"}
    ]);
    operator             = new ChartOperator(chart);
    slider               = chart.slider;
    graphs               = chart.graphs;
  });

  afterEach( ()=> Dates.resetTimezoneOffset() );

  it("必要なデータが揃うと、ポジションの取得が行われgraphが更新される", () => {
    // 最初は未初期化
    expect(graphs.lines).toEqual(undefined);
    expect(graphs.axises).toEqual(undefined);

    // データを設定
    operator.initialize(1000, 300, "one_hour", 100);

    expect(graphs.lines).toEq([{
      type:  "rate",
      color: "#aaa",
      line:  [
        {x:41, y:119, value:178.2, timestamp:Dates.date("2015-05-08T15:00:00Z")},
        {x:53, y:113, value:178.3, timestamp:Dates.date("2015-05-08T17:00:00Z")}
      ]
    }, {
      type:  "rate",
      color: "#bbb",
      line:  [
        {x:47, y:107, value:178.4, timestamp:Dates.date("2015-05-08T16:00:00Z")},
        {x:53, y:119, value:178.2, timestamp:Dates.date("2015-05-08T17:00:00Z")}
      ]
    }, {
      type:  "line",
      color: "#ccc",
      line:  [
        {x:47, y:305, value: 20, timestamp:Dates.date("2015-05-08T16:00:00Z")},
        {x:53, y:368, value:-10, timestamp:Dates.date("2015-05-08T17:00:00Z")}
      ]
    }, {
      type:  "line",
      color: "#999",
      line:  [
        {x:41, y:284, value:30, timestamp:Dates.date("2015-05-08T15:00:00Z")},
        {x:47, y:326, value:10, timestamp:Dates.date("2015-05-08T16:00:00Z")},
        {x:53, y:341, value: 3, timestamp:Dates.date("2015-05-08T17:00:00Z")}
      ]
    }, {
      type:  "profitOrLoss",
      color: "#999",
      line:  [
        {x:41, y:248, value:    0, timestamp:Dates.date("2015-05-08T15:00:00Z")},
        {x:47, y:268, value:-4720, timestamp:Dates.date("2015-05-08T16:00:00Z")},
        {x:53, y:184, value:15280, timestamp:Dates.date("2015-05-08T17:00:00Z")},
        {x:59, y:243, value: 1234, timestamp:Dates.date("2015-05-08T18:00:00Z")}
      ]
    }]);

    expect(graphs.axises).toEq([
      { value: 30,    y: 284 },
      { value: 70,    y: 201 },
      { value: 10000, y: 206 },
      { value: 0,     y: 248 }
    ]);

  });

  it("グラフデータの更新は、レートの更新が終わった後に実行される。", () => {

    operator.initialize(1000, 300, "fifteen_minutes", 100);
    chart.slider.preferences.chartInterval = "one_hour";

    const requests = chart.slider.rates.rateService.xhrManager.requests;
    requests[2].resolve([{
      id:"b", data: [
        { values:[30], timestamp:Dates.date("2015-05-08T15:00:00Z") },
        { values:[10], timestamp:Dates.date("2015-05-08T16:00:00Z") },
        { values:[ 3], timestamp:Dates.date("2015-05-08T17:00:00Z") }
      ]
    }]);

    // グラフのデータ取得が終わっても、rateの取得が終わるまでグラフは更新されない。
    expect(graphs.lines.length).toEq(5);
    expect(graphs.axises.length).toEq(4);

    // rateのレスポンスが返されると、グラフも更新される。
    requests[0].resolve(operator.createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:Dates.date("2015-05-08T10:00:00Z")}
    ]));

    expect(graphs.lines).toEq([{
      type:  "line",
      color: "#ccc",
      line:  [
        {x:41, y:284, value:30, timestamp:Dates.date("2015-05-08T15:00:00Z")},
        {x:47, y:346, value:10, timestamp:Dates.date("2015-05-08T16:00:00Z")},
        {x:53, y:368, value: 3, timestamp:Dates.date("2015-05-08T17:00:00Z")}
      ]
    }]);
    expect(graphs.axises).toEq([
      { value: 30,    y: 284 },
      { value: 70,    y: 161 }
    ]);
  });


});
