import Dates                from "src/utils/dates"
import CoordinateCalculator from "src/viewmodel/chart/coordinate-calculator"

const candleStickPadding = CoordinateCalculator.totalPaddingWidth();

export default class ChartOperator {

  constructor(chart) {
    this.chart = chart;
  }

  initialize(width=1000, chartWidth=20*6+candleStickPadding, interval="one_hour") {
    const requests = this.chart.slider.rates.rateService.xhrManager.requests;
    this.chart.slider.width = width;
    this.chart.candleSticks.stageSize = {w:chartWidth, h:200};
    this.chart.coordinateCalculator.stageSize = {w:chartWidth, h:200};
    this.chart.slider.preferences.chartInterval = interval;
    this.chart.slider.preferences.preferredPair = "USDJPY";
    this.chart.slider.rates.initialize();
    requests[0].resolve({
      start: this.date("2015-05-01T00:01:10Z"),
      end:   this.date("2015-05-10T00:02:20Z")
    });
    requests[1].resolve(this.createRates([
      {high:179.0, low:178.0, open:178.2, close:178.5, timestamp:this.date("2015-05-08T10:00:00Z")},
      {high:179.5, low:178.2, open:178.5, close:179.5, timestamp:this.date("2015-05-08T11:00:00Z")},
      {high:179.8, low:179.0, open:179.5, close:179.0, timestamp:this.date("2015-05-08T12:00:00Z")},
      {high:179.0, low:178.0, open:179.0, close:178.5, timestamp:this.date("2015-05-08T13:00:00Z")},
      {high:178.7, low:177.5, open:178.5, close:177.5, timestamp:this.date("2015-05-09T14:00:00Z")},
      {high:179.0, low:177.7, open:177.7, close:178.5, timestamp:this.date("2015-05-10T00:00:00Z")}
    ]));
    if (requests.length >= 3) requests[2].resolve([
      {enteredAt:this.date("2015-05-08T09:00:10Z"), exitedAt:this.date("2015-05-08T15:30:00Z")},
      {enteredAt:this.date("2015-05-08T11:30:10Z"), exitedAt:this.date("2015-05-08T12:00:01Z")},
      {enteredAt:this.date("2015-05-08T18:30:10Z"), exitedAt:this.date("2015-05-08T18:26:01Z")}
    ]);

    this.chart.slider.rates.rateService.xhrManager.clear();
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
