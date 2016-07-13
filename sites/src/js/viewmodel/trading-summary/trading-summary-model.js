import Observable      from "../../utils/observable"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import _               from "underscore"

const colorPattern = [
  { color: "#00BFA5", highlight: "#4CD2C0" },
  { color: "#666699", highlight: "#9494B7" },
  { color: "#4B4560", highlight: "#817C8F" },
  { color: "#996666", highlight: "#B79494" },
  { color: "#DF4C52", highlight: "#E98186" },
  { color: "#FD8A6A", highlight: "#FEB49E" },
  { color: "#FFCC66", highlight: "#FFDB94" },
  { color: "#E8CBAB", highlight: "#EFDAC4" },
  { color: "#ADC383", highlight: "#C5D5A8" }
];

export default class TradingSummaryModel extends Observable {

  constructor(summary) {
    super();
    _.pairs(summary).forEach(
      (pair) => this[pair[0]] = pair[1] );
    this.agentSummary = _.mapObject(this.agentSummary || {}, (val, key) => {
      return new TradingSummaryModel(val);
    });
  }

  get formatedProfitOrLoss() {
    return NumberFormatter.formatPrice(
      this.profitOrLoss.totalProfitOrLoss );
  }

  get pairData() {
    const data = this.createInitialDataset();
    _.sortBy(_.keys(this.pairs), (v) => v.label).forEach((key, i) => {
      const color = colorPattern[i % colorPattern.length];
      data.labels.push(key.toUpperCase());
      data.datasets[0].data.push(this.pairs[key]);
      data.datasets[0].borderWidth.push(0);
      data.datasets[0].backgroundColor.push(color.color);
      data.datasets[0].hoverBackgroundColor.push(color.highlight);
    });
    return data;
  }

  get sellOrBuyData() {
    return {
      labels: ["買", "売"],
      datasets: [{
        data: [this.sellOrBuy.buy, this.sellOrBuy.sell],
        borderWidth: [0, 0],
        backgroundColor: [
            colorPattern[5].color,
            colorPattern[6].color
        ],
        hoverBackgroundColor: [
            colorPattern[5].highlight,
            colorPattern[6].highlight
        ]
      }]
    };
  }

  get winsAndLossesData() {
    const values = this.winsAndLosses;
    return {
      labels: ["勝", "負", "引き分け"],
      datasets: [{
        data: [values.win,this.winsAndLosses.lose,this.winsAndLosses.draw],
        borderWidth: [0, 0, 0],
        backgroundColor: [
          "#F7464A", "#46BFBD", "#999"
        ],
        hoverBackgroundColor: [
          "#FF5A5E", "#5AD3D1", "#AAA",
        ]
      }]
    };
  }

  get agentsData() {
    const data = this.createInitialDataset();
    _.sortBy(_.keys(this.agentSummary),
      (key) => this.agentSummary[key].states.count * -1).forEach((key, i) => {
      const color = colorPattern[i % colorPattern.length];
      const summary = this.agentSummary[key];
      data.labels.push(summary.name || "不明");
      data.datasets[0].data.push(summary.states.count);
      data.datasets[0].borderWidth.push(0);
      data.datasets[0].backgroundColor.push(color.color);
      data.datasets[0].hoverBackgroundColor.push(color.highlight);
    });
    return data;
  }

  createInitialDataset() {
    return {
      labels: [],
      datasets: [{
        borderWidth: [],
        data: [],
        backgroundColor: [],
        hoverBackgroundColor: []
      }]
    };
  }

  get formatedWinPercentage() {
    if (!this.states.count) return "-%";
    const values = this.winsAndLosses;
    const ratio = values.win / this.states.count;
    return NumberFormatter.formatRatio(ratio);
  }

  get formatedPositionCount() {
    return NumberFormatter.insertThousandsSeparator(this.states.count);
  }
  get formatedExitedPositionCount() {
    return NumberFormatter.insertThousandsSeparator(this.states.exited);
  }

  get formatedMaxProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.maxProfit||0);
  }
  get formatedMaxLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.maxLoss||0);
  }
  get formatedAvgProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.avgProfit||0);
  }
  get formatedAvgLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.avgLoss||0);
  }
  get formatedTotalProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.totalProfit||0);
  }
  get formatedTotalLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.totalLoss||0);
  }
  get formatedProfitFactor() {
    return NumberFormatter.formatDecimal(this.profitOrLoss.profitFactor, 3);
  }

  get formatedMaxPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.maxPeriod||0);
  }
  get formatedMinPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.minPeriod||0);
  }
  get formatedAvgPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.avgPeriod||0);
  }

  get formatedMaxUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.maxUnits||0);
  }
  get formatedMinUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.minUnits||0);
  }
  get formatedAvgUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.avgUnits||0);
  }

  valueAndRatio( value, count=this.states.count ) {
    const ratio = value / count;
    return NumberFormatter.insertThousandsSeparator(value)
      + " (" + NumberFormatter.formatRatio(ratio) + ")";
  }

}
