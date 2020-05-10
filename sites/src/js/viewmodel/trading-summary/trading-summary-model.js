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

  get formattedProfitOrLoss() {
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

  getSellOrBuyData(formatMessage) {
    return {
      labels: [formatMessage({id:'common.buy'}), formatMessage({id:'common.sell'})],
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

  getWinsAndLossesData(formatMessage) {
    const values = this.winsAndLosses;
    return {
      labels: [formatMessage({id:'common.win'}), formatMessage({id:'common.lose'}), formatMessage({id:'common.draw'})],
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

  getAgentsData(formatMessage) {
    const data = this.createInitialDataset();
    _.sortBy(_.keys(this.agentSummary),
      (key) => this.agentSummary[key].states.count * -1).forEach((key, i) => {
      const color = colorPattern[i % colorPattern.length];
      const summary = this.agentSummary[key];
      data.labels.push(summary.name || formatMessage({id:'common.unknown'}));
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

  get formattedWinPercentage() {
    if (!this.states.count) return "-%";
    const values = this.winsAndLosses;
    const ratio = values.win / this.states.count;
    return NumberFormatter.formatRatio(ratio);
  }

  get formattedPositionCount() {
    return NumberFormatter.insertThousandsSeparator(this.states.count);
  }
  get formattedExitedPositionCount() {
    return NumberFormatter.insertThousandsSeparator(this.states.exited);
  }

  get formattedMaxProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.maxProfit||0);
  }
  get formattedMaxLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.maxLoss||0);
  }
  get formattedAvgProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.avgProfit||0);
  }
  get formattedAvgLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.avgLoss||0);
  }
  get formattedTotalProfit() {
    return NumberFormatter.formatPrice(this.profitOrLoss.totalProfit||0);
  }
  get formattedTotalLoss() {
    return NumberFormatter.formatPrice(this.profitOrLoss.totalLoss||0);
  }
  get formattedProfitFactor() {
    return NumberFormatter.formatDecimal(this.profitOrLoss.profitFactor, 3);
  }

  getFormattedMaxPeriod(formatMessage) {
    return DateFormatter.formatPeriod(this.holdingPeriod.maxPeriod||0, formatMessage);
  }
  getFormattedMinPeriod(formatMessage) {
    return DateFormatter.formatPeriod(this.holdingPeriod.minPeriod||0, formatMessage);
  }
  getFormattedAvgPeriod(formatMessage) {
    return DateFormatter.formatPeriod(this.holdingPeriod.avgPeriod||0, formatMessage);
  }

  get formattedMaxUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.maxUnits||0);
  }
  get formattedMinUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.minUnits||0);
  }
  get formattedAvgUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.avgUnits||0);
  }

  valueAndRatio( value, count=this.states.count ) {
    const ratio = value / count;
    return NumberFormatter.insertThousandsSeparator(value)
      + " (" + NumberFormatter.formatRatio(ratio) + ")";
  }

}
