import Observable   from "../../utils/observable"
import Dates        from "../../utils/dates"
import Deferred     from "../../utils/deferred"
import Intervals    from "../../model/trading/intervals"
import BigDecimal   from "big.js"

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
  static stickWidthAndGap() {
    return stickWidth+stickGap;
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

  prepareUpdate() {
    this.updateDeferred = new Deferred();
  }

  update() {
    if (!this.rateRange || !this.stageSize) return;
    const height      = this.rateAreaHeight;
    this.ratePerPixel = (this.rateRange.highest - this.rateRange.lowest) / height;
    if (!this.updateDeferred.fixed()) this.updateDeferred.resolve();
  }

  calculateX(date, range=null) {
    const currentRange  = range || this.slider.currentRange;
    const chartInterval = this.preferences.chartInterval;
    if (!currentRange || !chartInterval) {
      throw new Error("illegalState");
    }
    const intervalMs =  Intervals.resolveCollectingInterval(chartInterval);
    const index = Math.floor( (date.getTime() - currentRange.start.getTime()) / intervalMs);
    return (stickWidth + stickGap) * index + ((stickWidth + stickGap) / 2) + padding;
  }
  calculateY(rate) {
    if (!this.rateRange || !this.ratePerPixel) {
      throw new Error("illegalState");
    }
    return Math.floor( (this.rateRange.highest - rate) / this.ratePerPixel ) + padding;
  }
  calculateTime(x, range=null)  {
    const currentRange  = range || this.slider.currentRange;
    const chartInterval = this.preferences.chartInterval;
    if (!currentRange || !chartInterval) {
      return null;
    }
    const intervalMs =  Intervals.resolveCollectingInterval(chartInterval);
    const stickWidthAndGap = stickWidth + stickGap;
    const index = Math.floor((x - padding - (stickWidthAndGap/2)) / stickWidthAndGap);
    return Dates.date( currentRange.start.getTime() + intervalMs*index );
  }
  calculatePrice(y) {
    if (!this.rateRange || !this.ratePerPixel) {
      return null;
    }
    return new BigDecimal((y-padding) * this.ratePerPixel)
            .minus(this.rateRange.highest)
            .times(-1).toFixed(3);
  }

  normalizeDate(date) {
    const chartInterval = this.preferences.chartInterval;
    if (!chartInterval) {
      throw new Error("illegalState");
    }
    const intervalMs =  Intervals.resolveCollectingInterval(chartInterval);
    return Dates.date(Math.floor( date.getTime() / intervalMs) * intervalMs);
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
    const spliter = this.graphAreaHeight > 0
      ? this.stageSize.h - (bottomLabelheight + padding + this.graphAreaHeight)
      : null;
    return {
      vertical:        this.stageSize.h - (bottomLabelheight + padding),
      horizontal:      this.stageSize.w - (sideLabelWidth + padding),
      verticalSpliter: spliter
    };
  }

  get rateAreaHeight() {
    return this.stageSize.h
      - this.profitAreaHeight
      - this.graphAreaHeight
      - (bottomLabelheight + padding*2);
  }
  get profitAreaHeight() {
    return this.stageSize.profitAreaHeight || 0;
  }
  get graphAreaHeight() {
    return this.stageSize.graphAreaHeight || 0;
  }

  isRateArea(y) {
    if ( y <  padding ) return false;
    if ( y >  padding + this.rateAreaHeight ) return false;
    return true;
  }
  isProfitArea(y) {
    if ( y <=  padding + this.rateAreaHeight ) return false;
    if ( y >  padding + this.rateAreaHeight + this.profitAreaHeight ) return false;
    return true;
  }
  isGraphArea(y) {
    if (this.graphAreaHeight <= 0) return false;
    if (y <= padding + this.rateAreaHeight + this.profitAreaHeight ) return false;
    if (y > this.axisPosition.vertical ) return false;
    return true;
  }

  static calculateDisplayableCandleCount( stageWidth ) {
    return Math.floor((stageWidth - CoordinateCalculator.totalPaddingWidth() )
                    / (stickWidth + stickGap));
  }
}
