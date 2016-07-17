import ContainerJS           from "container-js"
import Observable            from "../../utils/observable"
import Dates                 from "../../utils/dates"
import DateFormatter         from "../utils/date-formatter"
import Intervals             from "../../model/trading/intervals"

export default class Slider extends Observable {

  constructor(context, coordinateCalculator, preferences) {
    super();
    this.context              = context;
    this.preferences          = preferences;
    this.coordinateCalculator = coordinateCalculator;

    this.registerObservers();
  }

  registerObservers() {
    this.context.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "range") return;
      this.range = e.newValue;
      this.update();
    }, this);
    this.preferences.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "chartInterval") return;
      this.chartInterval = e.newValue;
      this.update();
    }, this);
    this.coordinateCalculator.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "displayableCandleCount") return;
      this.displayableCandleCount = e.newValue;
      this.update();
    }, this);

    this.range = this.context.range;
    this.chartInterval = this.preferences.chartInterval;
    this.displayableCandleCount = this.coordinateCalculator.displayableCandleCount;

    if (this.existRequiredData()) this.update();
  }

  unregisterObservers() {
    this.preferences.removeAllObservers(this);
    this.context.removeAllObservers(this);
    this.coordinateCalculator.removeAllObservers(this);
  }

  initialize() {
    this.range = null;
    this.positionX = this.scrollableWidth;
  }

  update() {
    const showLatest = this.scrollableWidth === this.positionX;
    const positionXResolver = this.createPositionXResolver(showLatest);
    this.updateRange();
    this.setProperty("positionX", positionXResolver());
    this.updateCurrentRange();
  }

  updateRange() {
    if ( !this.existRequiredData() ) return;

    const candleCount = this.displayableCandleCount;
    this.intervalMs =  Intervals.resolveCollectingInterval(this.chartInterval);
    this.updateNormalizedRange(this.intervalMs);

    const ms = this.normalizedRange.end.getTime() - this.normalizedRange.start.getTime();
    const msPerPixel = ms  / this.width;

    this.pageMs     = this.intervalMs * candleCount;
    this.setProperty("pageWidth", Math.max(Math.floor(this.pageMs/msPerPixel), 30));

    this.scrollableWidth = this.width - this.pageWidth;
      // バーを最大までスクロールした場合の、バーの左端のx座標
    this.msPerPixel = (ms - this.pageMs) / this.scrollableWidth;
      // pageWidthが30以下になった場合の対応
      // バーを最大までスクロールした場合に最新のデータが見えるとして、
      // それを引いた残りのスクロール領域での1pxあたりのmsを再計算する
  }

  updateNormalizedRange(intervalMs) {
    const start = Slider.calcuratePartitionStartTime(this.range.start.getTime(), intervalMs);
    const end   = Slider.calcuratePartitionStartTime(this.range.end.getTime() + intervalMs, intervalMs);
    this.setProperty("normalizedRange", {
      start: Dates.date(start),
      end:   Dates.date(end)
    });
  }

  createPositionXResolver(isShownLatest) {
    var positionX;
    // 未初期化の場合or最新の情報を表示中の場合、更新後も最新の情報を表示した状態にする。
    if ( this.positionX == null || isShownLatest) {
      return () => this.scrollableWidth;
    } else {
      // そうでない場合、現在の中心位置を維持する。
      const centerMs = this.currentRange.start.getTime()
                     + (this.intervalMs * Math.ceil(this.displayableCandleCount / 2));
      return () => this.calculatePositionXFromDate(Dates.date(centerMs));
    }
  }

  updateCurrentRange() {
    if ( !this.existRequiredData() ) return;

    const result = this.calculateCurrentRangeByHanldePosition(this.positionX);
    if ( this.positionX !== result.x ) this.setProperty("positionX", result.x);

    this.setProperty("currentRange", result.range, () => false);
  }

  slideStart() {
    if ( !this.enableSlide() ) return;
    this.temporaryPositionX = this.positionX;
  }
  slideByChart(step) {
    if ( !this.existRequiredData() ) return;
    if ( !this.enableSlide() ) return;

    const result =   this.calculateCurrentRangeBySlideStep(step);
    this.setProperty("temporaryCurrentRange", result.range);
    this.setProperty("temporaryPositionX",    result.x);
  }
  slideByHandle(x) {
    if ( !this.existRequiredData() ) return;
    if ( x === this.temporaryPositionX ) return;
    if ( !this.enableSlide() ) return;

    const result = this.calculateCurrentRangeByHanldePosition(x);
    if ( this.temporaryPositionX !== result.x ) {
      this.setProperty("temporaryPositionX", result.x);
    }
    this.setProperty("temporaryCurrentRange", result.range);
  }
  slideEnd() {
    if ( !this.enableSlide() ) return;

    this.setProperty("currentRange", this.temporaryCurrentRange);
    this.setProperty("positionX",    this.temporaryPositionX);
  }

  calculateCurrentRangeBySlideStep(step) {
    const ms = this.intervalMs * step * -1;
    let startMs = ms + this.currentRange.start.getTime();
    let x = this.positionX + Math.round(ms / this.msPerPixel);
    if (startMs < this.normalizedRange.start.getTime()) {
      startMs = this.normalizedRange.start.getTime();
      x = 0;
    } else if ( startMs + this.pageMs > this.normalizedRange.end.getTime() ) {
      startMs = this.normalizedRange.end.getTime() - this.pageMs;
      x = this.scrollableWidth;
    }
    return  {
      range : {
        start : Dates.date(startMs),
        end   : Dates.date(startMs  + this.pageMs)
      },
      x : x
    };
  }

  calculateCurrentRangeByHanldePosition(x) {
    if ( !this.existRequiredData() ) throw new Error("illegal state.");

    // 左端or右端にする
    if (this.scrollableWidth <= x) {
      x = this.scrollableWidth;
    } else if (x < 0) {
      x = 0;
    }
    const startMs = (x * this.msPerPixel) + this.range.start.getTime();
    const startPartitionMs =
      Slider.calcuratePartitionStartTime(startMs, this.intervalMs);
    return {
      range : {
        start : Dates.date(startPartitionMs),
        end   : Dates.date(startPartitionMs  + this.pageMs)
      },
      x     : x
    };
  }

  calculatePositionXFromDate(date) {
    const ms = date.getTime() - this.normalizedRange.start.getTime() - (this.pageMs / 2);
    return Math.floor(ms / this.msPerPixel);
  }

  goTo( date ) {
    this.setProperty("positionX", this.calculatePositionXFromDate(date));
    this.updateCurrentRange();
  }

  enableSlide() {
    return this.width > this.pageWidth;
  }

  existRequiredData() {
    return this.width
        && this.range
        && this.displayableCandleCount
        && this.chartInterval;
  }

  static calcuratePartitionStartTime(time, intervalMs) {
    return Math.floor( time / intervalMs ) * intervalMs;
  }


  // スライダー全体の幅
  get width() {
    return this.getProperty("width");
  }
  set width(width) {
    this.setProperty("width", width);
    this.update();
  }
  // スライドする緑の部分の幅。最小でも30pxは確保する
  get pageWidth() {
    return this.getProperty("pageWidth");
  }
  // 現在表示中の範囲 {start:Date,end:Date}
  // チャートの集計期間でノーマライズされている
  // この期間を指定してレートを取得すると、UIで必要なレートが取得できる。
  // endは表示期間には含まれないので、UIで見せる場合には -1 intervalする必要がある。
  get currentRange() {
    return this.getProperty("currentRange");
  }
  // 現在表示中の期間としてUIに表示する文字列 {start:String, end:String}
  // currentRangeのendは表示期間には含まれないので、-1 interal している。
  get displayableCurrentRange() {
    const currentRange = this.getProperty("currentRange");
    if (!currentRange) return {start: "-", end: "-"};
    return {
      start: DateFormatter.format(currentRange.start),
      end:   DateFormatter.format(currentRange.end)
    };
  }

  // 表示可能なレートの範囲 {start:Date,end:Date}
  // Rates.rangeと異なり、チャートの集計期間でノーマライズしている。
  //
  // 例) 実データが 2015-1-1 10:20:31 ～ 20:30:45 あり、
  //     集計期間が1時間(one_hour)の場合、
  //     start : 2015-1-1 10:00:00
  //     end   : 2015-1-1 21:00:00
  //     になる。
  get normalizedRange() {
    return this.getProperty("normalizedRange");
  }
  // スライダーの左端のx座標
  get positionX() {
    return this.getProperty("positionX");
  }
  set positionX(positionX) {
    this.setProperty("positionX", positionX);
    this.updateCurrentRange();
  }


  get temporaryCurrentRange() {
    return this.getProperty("temporaryCurrentRange");
  }
  // スライダーの左端のx座標
  get temporaryPositionX() {
    return this.getProperty("temporaryPositionX");
  }
  set temporaryPositionX(positionX) {
    this.setProperty("temporaryPositionX", positionX);
  }

}
