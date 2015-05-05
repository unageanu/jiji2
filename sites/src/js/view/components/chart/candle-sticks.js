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
  attache( stage ) {
    stage.addChild(this.sticksShape);
  }

  onPropertyChanged(name, event) {
    if (event.key === "sticks") {
      this.renderSticks( event.newValue );
      this.stage.update();
    }
  }

  initSprite() {
    this.sticksShape = new CreateJS.Shape();
    this.sticksShape.x = this.sticksShape.y = 8;
  }

  renderSticks( sticks ) {
    const g = this.sticksShape.graphics;
    sticks.reduce( (g, s)=>{
      g = g.beginFill("#bbbbbb")
           .drawRect( s.x-4, s.open, 10, s.close - s.open )
           .drawRect( s.x,   s.high, 2, Math.min(s.open, s.close) - s.high)
           .drawRect( s.x,   Math.max(s.open, s.close), 2, s.low - Math.max(s.open, s.close))
           .endFill();
      if ( s.isUp ) {
        g = g.beginFill("#FFFFFF").drawRect( s.x-2, s.close+2, 6, (s.open - s.close)-4 ).endFill();
      }
      return g;
    }, g);

    // const g = this.sticksShape.graphics.setStrokeStyle(2, 0, 0, 0, true).beginStroke("#bbbbbb");
    // sticks.reduce( (g, s)=>{
    //   let g = s.isUp ? g.beginFill("#FFFFFF") : g.beginFill("#bbbbbb");
    //   return g.drawRect( s.x-3, s.open, 6, s.close - s.open )
    //           .moveTo( s.x+1, s.high  )
    //           .lineTo( s.x+1, s.isUp ? s.close : s.open )
    //           .moveTo( s.x+1, s.low  )
    //           .lineTo( s.x+1, s.isUp ? s.open : s.close );
    //
    // }, g);
  }
}
