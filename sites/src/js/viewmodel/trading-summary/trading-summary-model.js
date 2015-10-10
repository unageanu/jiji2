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
  { color: "#FD8A6A", highlight: "#FD8A6A" },
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
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.totalProfitOrLoss );
  }

  get pairData() {
    return _.sortBy(_.keys(this.pairs).map((key, i) => {
      const color = colorPattern[i % colorPattern.length];
      return _.defaults({
        label: key.toUpperCase(),
        value: this.pairs[key],
        valueAndRatio: this.valueAndRatio( this.pairs[key] )
      }, color);
    }), (v) => v.label );
  }

  get sellOrBuyData() {
    return [{
      label: "買",
      color: colorPattern[5].color,
      highlight: colorPattern[5].highlight,
      value: this.sellOrBuy.buy,
      valueAndRatio: this.valueAndRatio( this.sellOrBuy.buy )
    }, {
      label: "売",
      color: colorPattern[6].color,
      highlight: colorPattern[6].highlight,
      value: this.sellOrBuy.sell,
      valueAndRatio: this.valueAndRatio( this.sellOrBuy.sell )
    }];
  }

  get winsAndLossesData() {
    const values = this.winsAndLosses;
    return [{
      label: "勝",
      color: "#F7464A",
      highlight: "#FF5A5E",
      value: values.win,
      valueAndRatio: this.valueAndRatio( values.win )
    }, {
      label: "負",
      color: "#46BFBD",
      highlight: "#5AD3D1",
      value: this.winsAndLosses.lose,
      valueAndRatio: this.valueAndRatio( values.lose )
    }, {
      label: "引き分け",
      color: "#999",
      highlight: "#AAA",
      value: this.winsAndLosses.draw,
      valueAndRatio: this.valueAndRatio( values.draw )
    }];
  }

  get agentsData() {
    return _.sortBy(_.keys(this.agentSummary).map((key, i) => {
      const color = colorPattern[i % colorPattern.length];
      return _.defaults({
        label: this.agentSummary[key].name || "不明",
        value: this.agentSummary[key].states.count,
        valueAndRatio: this.valueAndRatio( this.agentSummary[key].states.count )
      }, color);
    }), (v) => v.value * -1 );
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
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.maxProfit,3));
  }
  get formatedMaxLoss() {
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.maxLoss,3));
  }
  get formatedAvgProfit() {
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.avgProfit,3));
  }
  get formatedAvgLoss() {
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.avgLoss,3));
  }
  get formatedTotalProfit() {
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.totalProfit,3));
  }
  get formatedTotalLoss() {
    return NumberFormatter.insertThousandsSeparator(
      NumberFormatter.formatDecimal(this.profitOrLoss.totalLoss,3));
  }
  get formatedProfitFactor() {
    return NumberFormatter.formatDecimal(this.profitOrLoss.profitFactor, 3);
  }

  get formatedMaxPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.maxPeriod);
  }
  get formatedMinPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.minPeriod);
  }
  get formatedAvgPeriod() {
    return DateFormatter.formatPeriod(this.holdingPeriod.avgPeriod);
  }

  get formatedMaxUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.maxUnits);
  }
  get formatedMinUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.minUnits);
  }
  get formatedAvgUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units.avgUnits);
  }

  valueAndRatio( value, count=this.states.count ) {
    const ratio = value / count;
    return NumberFormatter.insertThousandsSeparator(value)
      + " (" + NumberFormatter.formatRatio(ratio) + ")";
  }

}
