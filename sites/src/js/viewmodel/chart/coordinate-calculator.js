import Observable    from "../../utils/observable";
import CandleSticks  from "./candle-sticks";
import Slider        from "./slider";

const padding           = 8 * 2;
const sideLabelWidth    = 48;
const bottomLabelheight = 16;
const stickWidth = 5;
const stickGap   = 1;

export default class CoordinateCalculator extends Observable {

  constructor() {
    super();
  }

  static totalPaddingWidth() {
    return padding + sideLabelWidth;
  }
  static totalPaddingHeight() {
    return padding + bottomLabelheight;
  }

  attach( slider, preferences ) {
    this.slider = slider;
    this.preferences = preferences;
  }

  update() {
    if (!this.rateRange || !this.stageSize) return;
    const height        = this.stageSize.h - CoordinateCalculator.totalPaddingHeight();
    this.ratePerPixel = (this.rateRange.highest - this.rateRange.lowest) / height;
  }

  calculateX(date) {
    const currentRange  = this.slider.currentRange;
    const chartInterval = this.preferences.chartInterval;
    if (!currentRange || !chartInterval) {
      throw new Error("illegalState");
    }
    const intervalMs =  CoordinateCalculator.resolveCollectingInterval(chartInterval);
    const index = Math.floor(currentRange.start.getTime() - date.getTime() / intervalMs);
    return (stickWidth + stickGap) * index + ((stickWidth +  stickGap) / 2);
  }
  calculateY(rate) {
    if (!this.rateRange || !this.ratePerPixel) {
      throw new Error("illegalState");
    }
    return Math.floor( (this.rateRange.highest - rate) / this.ratePerPixel );
  }

  set stageSize( size ) {
    this.displayableCandleCount =
      CoordinateCalculator.calculateDisplayableCandleCount(size.w);
    this.setProperty("stageSize", size);
    this.update();
  }
  get stageSize() {
    return this.getProperty("stageSize");
  }

  set displayableCandleCount( displayableCandleCount ) {
    return this.setProperty("displayableCandleCount", displayableCandleCount);
  }
  get displayableCandleCount() {
    return this.getProperty("displayableCandleCount");
  }


  get rateRange() {
    return this._rateRange;
  }
  set rateRange(rateRange) {
    this._rateRange = rateRange;
    this.update();
  }

  static calculateDisplayableCandleCount( stageWidth ) {
    return Math.floor((stageWidth - CoordinateCalculator.totalPaddingWidth() )
                    / (stickWidth + stickGap));
  }

  static resolveCollectingInterval(interval) {
    const m = 60 * 1000;
    switch(interval) {
      case "fifteen_minutes" : return      15 * m;
      case "thirty_minutes"  : return      30 * m;
      case "one_hour"        : return      60 * m;
      case "six_hours"       : return  6 * 60 * m;
      case "one_day"         : return 24 * 60 * m;
      default                : return       1 * m;
    }
  }
}
