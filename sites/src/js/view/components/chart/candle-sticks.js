import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"

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
      this.renderSticks( event.newValue );
      this.stage.update();
    }
  }

  initSprite() {
    this.sticksShape = new CreateJS.Shape();
    this.sticksShape.x = this.sticksShape.y = 0;
  }

  renderSticks( sticks ) {
    const g = this.sticksShape.graphics;
    sticks.reduce( (g, s)=>{
      g = g.beginFill("#bbbbbb")
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
}
