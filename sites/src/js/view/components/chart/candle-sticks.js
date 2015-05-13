import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"
import CoordinateCalculator   from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class CandleSticks extends AbstractChartComponent {

  constructor( chartModel ) {
    super(chartModel);
    this.initSprite();
  }

  addObservers() {
    this.chartModel.candleSticks.addObserver(
      "propertyChanged", this.onPropertyChanged.bind(this));
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.sticksShape);
  }

  onPropertyChanged(name, event) {
    if (event.key === "sticks") {
      this.update();
    }
  }

  initSprite() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    this.sticksShape = this.initializeElement(new CreateJS.Shape(), stageSize);
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
