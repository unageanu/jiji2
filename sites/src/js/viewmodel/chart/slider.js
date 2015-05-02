import ContainerJS           from "container-js";
import Observable            from "../../utils/observable";
import DateFormatter         from "../utils/date-formatter";
import  CoordinateCalculator from "./coordinate-calculator";

export default class Slider extends Observable {

  constructor(coordinateCalculator, rates, preferences) {
    super();
    this.rates                = rates;
    this.preferences          = preferences;
    this.coordinateCalculator = coordinateCalculator;

    this.initialize();
  }

  initialize() {
    this.rates.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "range") return;
      this.range = e.newValue;
      this.update();
    });
    this.preferences.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "chartInterval") return;
      this.chartInterval = e.newValue;
      this.update();
    });
    this.coordinateCalculator.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "displayableCandleCount") return;
      this.displayableCandleCount = e.newValue;
      this.update();
    });

    this.range = this.rates.range;
    this.chartInterval = this.preferences.chartInterval;
    this.displayableCandleCount = this.coordinateCalculator.displayableCandleCount;

    if (this.existRequiredData()) this.update();
  }

  update() {
    const showLatest = this.scrollableWidth === this.positionX;
    const positionXResolver = this.createPositionXResolver(showLatest);
    this.calculateRange();
    this.setProperty("positionX", positionXResolver());
    this.calculateCurrentRange();
  }

  calculateRange() {
    if ( !this.existRequiredData() ) return;

    const candleCount = this.displayableCandleCount;
    this.intervalMs = CoordinateCalculator.resolveCollectingInterval(this.chartInterval);
    this.calculateNormalizedRange(this.intervalMs);

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

  calculateNormalizedRange(intervalMs) {
    const start = Slider.calcuratePartitionStartTime(this.range.start.getTime(), intervalMs);
    const end   = Slider.calcuratePartitionStartTime(this.range.end.getTime() + intervalMs, intervalMs);
    this.setProperty("normalizedRange", {
      start: new Date(start),
      end:   new Date(end)
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
      return () => this.calculatePositionXFromDate(new Date(centerMs));
    }
  }

  calculateCurrentRange() {
    if ( !this.existRequiredData() ) return;

    // 左端or右端にする
    if (this.scrollableWidth <= this.positionX) {
      this.setProperty("positionX", this.scrollableWidth);
    } else if (this.positionX < 0) {
      this.setProperty("positionX", 0);
    }
    const startMs = (this.positionX * this.msPerPixel) + this.range.start.getTime();
    const startPartitionMs =
      Slider.calcuratePartitionStartTime(startMs, this.intervalMs);
    this.setProperty("currentRange", {
      start : new Date(startPartitionMs),
      end   : new Date(startPartitionMs  + this.pageMs)
    });
  }

  calculatePositionXFromDate(date) {
    const ms = date.getTime() - this.normalizedRange.start.getTime() - (this.pageMs / 2);
    return Math.floor(ms / this.msPerPixel);
  }

  goTo( date ) {
    this.setProperty("positionX", this.calculatePositionXFromDate(date));
    this.calculateCurrentRange();
  }

  existRequiredData() {
    return this.width
        && this.range
        && this.displayableCandleCount
        && this.chartInterval;
  }

  static calcuratePartitionStartTime(time, intervalMs) {
    return Math.floor(time / intervalMs ) * intervalMs;
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
    this.calculateCurrentRange();
  }

}
