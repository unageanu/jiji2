import Observable      from "../../utils/observable"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import _               from "underscore"

const colorPattern = [
  { color: "#F7464A", highlight: "#FF5A5E" },
  { color: "#46BFBD", highlight: "#5AD3D1" },
  { color: "#FDB45C", highlight: "#FFC870" }
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
      color: "#F7464A",
      highlight: "#FF5A5E",
      value: this.sellOrBuy.buy,
      valueAndRatio: this.valueAndRatio( this.sellOrBuy.buy )
    }, {
      label: "売",
      color: "#46BFBD",
      highlight: "#5AD3D1",
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
      this.profitOrLoss.maxProfit);
  }
  get formatedMaxLoss() {
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.maxLoss);
  }
  get formatedAvgProfit() {
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.avgProfit);
  }
  get formatedAvgLoss() {
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.avgLoss);
  }
  get formatedTotalProfit() {
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.totalProfit);
  }
  get formatedTotalLoss() {
    return NumberFormatter.insertThousandsSeparator(
      this.profitOrLoss.totalLoss);
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

  get formatedMaxUnit() {
    return NumberFormatter.insertThousandsSeparator(this.units.maxUnit);
  }
  get formatedMinUnit() {
    return NumberFormatter.insertThousandsSeparator(this.units.minUnit);
  }
  get formatedAvgUnit() {
    return NumberFormatter.insertThousandsSeparator(this.units.avgUnit);
  }

  valueAndRatio( value, count=this.states.count ) {
    const ratio = value / count;
    return NumberFormatter.insertThousandsSeparator(value)
      + " (" + NumberFormatter.formatRatio(ratio) + ")";
  }

}
