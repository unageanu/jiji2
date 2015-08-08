import Dates                from "src/utils/dates"
import CoordinateCalculator from "src/viewmodel/chart/coordinate-calculator"

const candleStickPadding = CoordinateCalculator.totalPaddingWidth();

export default class ChartOperator {

  constructor(chart) {
    this.chart = chart;
  }

  initialize(width=1000, chartWidth=20*6+candleStickPadding,
    interval="one_hour", graphAreaHeight=null) {
    const requests = this.chart.rates.rateService.xhrManager.requests;
    this.chart.slider.width = width;
    let stageSize = this.createStageSize(chartWidth, graphAreaHeight);
    this.chart.candleSticks.stageSize = stageSize;
    this.chart.coordinateCalculator.stageSize = stageSize;
    this.chart.slider.preferences.chartInterval = interval;
    this.chart.slider.preferences.preferredPair = "USDJPY";
    this.chart.initialize();
    requests[0].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);
    requests[1].resolve({
      start: this.date("2015-05-01T00:01:10Z"),
      end:   this.date("2015-05-10T00:02:20Z")
    });
    requests[2].resolve(this.createDefaultRateResponse());
    if (requests.length >= 4) requests[3].resolve(this.createDefaultPositionsResponse());
    if (requests.length >= 5) requests[4].resolve(this.createDefaultGraphResponse());
    if (requests.length >= 6) requests[5].resolve(this.createDefaultGraphDataResponse());
    this.chart.rates.rateService.xhrManager.clear();
  }

  createStageSize(chartWidth, graphAreaHeight) {
    if (graphAreaHeight) {
      return {
        w:chartWidth,
        h:200 + graphAreaHeight*2,
        profitAreaHeight: graphAreaHeight,
        graphAreaHeight:  graphAreaHeight
      };
    } else {
      return {
        w:chartWidth,
        h:200
      };
    }
  }

  createDefaultRateResponse() {
    return this.createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:this.date("2015-05-08T10:00:00Z")},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:this.date("2015-05-08T11:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:this.date("2015-05-08T12:00:00Z")},
      {high:179.0, low:178.0, open:179.0, close:178.5, timestamp:this.date("2015-05-08T13:00:00Z")},
      {high:178.7, low:177.5, open:178.5, close:177.5, timestamp:this.date("2015-05-09T14:00:00Z")},
      {high:179.0, low:177.7, open:177.7, close:178.5, timestamp:this.date("2015-05-10T00:00:00Z")}
    ]);
  }

  createDefaultPositionsResponse() {
    return [
      {enteredAt:this.date("2015-05-08T09:00:10Z"), exitedAt:this.date("2015-05-08T15:30:00Z")},
      {enteredAt:this.date("2015-05-08T11:30:10Z"), exitedAt:this.date("2015-05-08T12:00:01Z")},
      {enteredAt:this.date("2015-05-08T18:30:10Z"), exitedAt:this.date("2015-05-08T18:26:01Z")}
    ];
  }

  createDefaultGraphResponse() {
    return [
      {id:"a", type:"rate", label:"aaa", colors:["#aaa", "#bbb"]},
      {id:"b", type:"line", label:"bbb", colors:["#ccc"], axises:[30, 70]},
      {id:"c", type:"balance"}
    ];
  }

  createDefaultGraphDataResponse() {
    return [
      {id:"a", data: [
          { values:[ 178.2,  null], timestamp:this.date("2015-05-08T15:00:00Z") },
          { values:[  null, 178.4], timestamp:this.date("2015-05-08T16:00:00Z") },
          { values:[ 178.3, 178.2], timestamp:this.date("2015-05-08T17:00:00Z") }
      ]},
      {id:"b", data: [
          { values:[  null,    30], timestamp:this.date("2015-05-08T15:00:00Z") },
          { values:[    20,    10], timestamp:this.date("2015-05-08T16:00:00Z") },
          { values:[   -10,     3], timestamp:this.date("2015-05-08T17:00:00Z") }
      ]},
      {id:"c", data: [
          { values:[    0], timestamp:this.date("2015-05-08T15:00:00Z") },
          { values:[-4720], timestamp:this.date("2015-05-08T16:00:00Z") },
          { values:[15280], timestamp:this.date("2015-05-08T17:00:00Z") },
          { values:[ 1234], timestamp:this.date("2015-05-08T18:00:00Z") }
      ]}
    ];
  }

  createRates(seed) {
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
  date( str ) {
    return Dates.date(str);
  }
}
