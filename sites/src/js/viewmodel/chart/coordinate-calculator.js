import Observable    from "../../utils/observable";

const padding           = 8;
const sideLabelWidth    = 48;
const bottomLabelheight = 16;
const stickWidth = 5;
const stickGap   = 1;

export default class CoordinateCalculator extends Observable {

  constructor() {
    super();
  }

  static totalPaddingWidth() {
    return padding*2 + sideLabelWidth;
  }
  static totalPaddingHeight() {
    return padding*2 + bottomLabelheight;
  }
  static padding() {
    return padding;
  }
  static sideLabelWidth() {
    return sideLabelWidth;
  }
  static bottomLabelheight() {
    return bottomLabelheight;
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
    const index = Math.floor( (date.getTime() - currentRange.start.getTime()) / intervalMs);
    return (stickWidth + stickGap) * index + ((stickWidth +  stickGap) / 2) + padding;
  }
  calculateY(rate) {
    if (!this.rateRange || !this.ratePerPixel) {
      throw new Error("illegalState");
    }
    return Math.floor( (this.rateRange.highest - rate) / this.ratePerPixel ) + padding;
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

  get axisPosition() {
    return {
      vertical:   this.stageSize.h - (bottomLabelheight + padding),
      horizontal: this.stageSize.w - (sideLabelWidth + padding)
    };
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
