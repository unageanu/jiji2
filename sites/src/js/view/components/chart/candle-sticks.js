import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"

export default class CandleSticks extends AbstractChartComponent {

  constructor( chartModel, slidableMask ) {
    super(chartModel);
    this.initSprite(slidableMask);
  }

  addObservers() {
    this.chartModel.candleSticks.addObserver(
      "propertyChanged", this.onCandlePropertyChanged.bind(this));
    this.chartModel.slider.addObserver(
      "propertyChanged", this.onSliderPropertyChanged.bind(this));
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.sticksShape);
  }

  onCandlePropertyChanged(name, event) {
    if (event.key === "sticks") {
      this.update();
    }
  }
  onSliderPropertyChanged(name, event) {
    if (event.key === "temporaryCurrentRange") {
      if (!event.newValue || !event.newValue.start) return;
      this.slideTo(event.newValue.start);
    }
  }
  slideTo( temporaryStart ) {
    const x = this.calculateSlideX( temporaryStart );
    this.sticksShape.x = x;
    this.stage.update();
  }

  initSprite(slidableMask) {
    this.sticksShape      = this.initializeElement(new CreateJS.Shape());
    this.sticksShape.mask = slidableMask;
  }

  update() {
    this.clearScreen();
    this.renderSticks( this.chartModel.candleSticks.sticks );
    this.stage.update();
    this.cache();
  }

  clearScreen() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    this.sticksShape.graphics.clear();
    this.sticksShape.x = this.sticksShape.y = 0;
  }

  renderSticks( sticks ) {
    const g = this.sticksShape.graphics;
    sticks.reduce( (g, s)=>{
      g = g.beginFill("#AAAAAA")
           .drawRect( s.x-2, s.open, 5, s.close - s.open || 1 )
           .drawRect( s.x,   s.high, 1, Math.min(s.open, s.close) - s.high)
           .drawRect( s.x,   Math.max(s.open, s.close), 1, s.low - Math.max(s.open, s.close))
           .endFill();
      if ( s.isUp && (s.open-s.close) > 2) {
        g = g.beginFill("#FFFFFF").drawRect( s.x-1, s.close+1, 3, (s.open-s.close)-2 ).endFill();
      }
      return g;
    }, g);
  }

  cache() {
  }
}
