import ContainerJS          from "container-js"
import Numbers              from "../../utils/numbers"
import CandleSticks         from "./candle-sticks"
import CoordinateCalculator from "./coordinate-calculator"

export default class GraphCoordinateCalculator {
  constructor(coordinateCalculator) {
    this.coordinateCalculator = coordinateCalculator;
  }
  calculateRange(allValues, axises) {}
  calculateY(value) {}
  calculateAxises(axises) {
    return [];
  }

  static create( type, coordinateCalculator ) {
    switch (type) {
      case "rate"         : return new Rate(coordinateCalculator);
      case "profitOrLoss" : return new ProfitOrLoss(coordinateCalculator);
      default :             return new Line(coordinateCalculator);
    }
  }

  calculateHighAndLow(allValues) {
    const initialValue =
      allValues.length > 0 && allValues[0].values.length > 0
      ? allValues[0].values[0] : 0;
    const result = allValues.reduce((r, values) => {
      values.values.forEach((v) => {
        if (v === null || v === undefined) return;
        if (r.highest < v) r.highest = v;
        if (r.lowest  > v) r.lowest  = v;
      });
      return r;
    }, {highest:initialValue, lowest:initialValue});
    const margin = this.calculateMargin(result);
    return {
      highest: result.highest + margin,
      lowest:  result.lowest  - margin
    };
  }
  calculateMargin(highAndLow) {
    const margin = (highAndLow.highest - highAndLow.lowest) / 10;
    return margin === 0 ? 1 : margin;
  }
}

class Rate extends GraphCoordinateCalculator {
  constructor(coordinateCalculator) {
    super(coordinateCalculator);
  }
  calculateY(value) {
    return this.coordinateCalculator.calculateY(value);
  }
}

class Line extends GraphCoordinateCalculator {
  constructor(coordinateCalculator) {
    super(coordinateCalculator);
  }
  calculateRange(allValues, axises) {
    this.range = this.calculateHighAndLow(
      axises ? allValues.concat([{values:axises}]) : allValues );
    this.valuesPerPixel =
      (this.range.highest - this.range.lowest) / this.getAreaHeight();
    this.bottom = this.getAreaBottom();
  }
  calculateY(value) {
    if (value === null || value === undefined) return null;
    return Math.round(this.bottom - ((value - this.range.lowest) / this.valuesPerPixel ));
  }
  calculateAxises(axises) {
    return axises.map((axis)=>{
      return {
        value : axis,
        y: this.calculateY(axis)
      };
    });
  }
  getAreaHeight() {
    return this.coordinateCalculator.graphAreaHeight;
  }
  getAreaBottom() {
    return this.coordinateCalculator.graphAreaHeight
        + this.coordinateCalculator.profitAreaHeight
        + this.coordinateCalculator.rateAreaHeight
        + CoordinateCalculator.padding();
  }
}

class ProfitOrLoss extends Line {
  constructor(coordinateCalculator) {
    super(coordinateCalculator);
  }
  calculateAxises(axises) {
    const max = Math.max(Math.abs(this.range.lowest), Math.abs(this.range.highest));
    const diff = this.range.highest - this.range.lowest;
    const step = CandleSticks.adjustStep(ProfitOrLoss.calculateStep( max ), diff);
    return this.createVerticalAxisLabels(step, max);
  }
  getAreaHeight() {
    return this.coordinateCalculator.profitAreaHeight;
  }
  getAreaBottom() {
    return this.coordinateCalculator.profitAreaHeight
        + this.coordinateCalculator.rateAreaHeight
        + CoordinateCalculator.padding();
  }
  createVerticalAxisLabels(step) {
    const start = Math.ceil( this.range.highest / step) * step;
    const results = [];
    for( let i=start; i > this.range.lowest; i-=step ) {
      if (i >= this.range.highest) continue;
      results.push({
        value: i,
        y: this.calculateY(i)
      });
    }
    return results;
  }
  static calculateStep( val ) {
    const positiveDigit = Numbers.getPositiveDigits(val);
    return Math.max(Math.pow(10, positiveDigit-2), 100);
  }
}
