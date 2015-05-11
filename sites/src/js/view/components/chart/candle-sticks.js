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
    this.sticksShape = new CreateJS.Shape();
    this.sticksShape.x = this.sticksShape.y = 0;

    const stageSize = this.chartModel.candleSticks.stageSize;
    this.sticksShape.setBounds( 0, 0, stageSize.w, stageSize.h );
  }

  update() {
    this.clearScreen();
    this.renderAxises();
    this.renderSticks( this.chartModel.candleSticks.sticks );
    this.stage.update();
    this.cache();
  }

  clearScreen() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    this.sticksShape.graphics
        .beginFill("#F0F0F0")
        .drawRect( 0, 0, stageSize.w, stageSize.h )
        .endFill();
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
  renderAxises() {
    const candleSticks = this.chartModel.candleSticks;
    const axisPosition         = candleSticks.axisPosition;
    const verticalAxisLabels   = candleSticks.verticalAxisLabels;
    const horizontalAxisLabels = candleSticks.horizontalAxisLabels;

    this.renderAxisLines(axisPosition,
      verticalAxisLabels, horizontalAxisLabels);
    this.renderHorizontalAxisLabels(axisPosition, horizontalAxisLabels);
    this.renderVerticalAxisLabels(axisPosition, verticalAxisLabels);
  }

  renderAxisLines(axisPosition, verticalAxisLabels, horizontalAxisLabels) {
    let g = this.sticksShape.graphics;
    g = this.drowLine(g, "#DDDDDD", horizontalAxisLabels.map((l)=>{
      return {
        x: l.x,
        y: padding,
        h: axisPosition.vertical - padding
      };
    }));
    g = this.drowLine(g, "#DDDDDD", verticalAxisLabels.map((l)=>{
      return {
        x: padding,
        y: l.y,
        w: axisPosition.horizontal - padding
      };
    }));
    g = this.drowLine(g, "#CCCCCC", [{
      x: padding,
      y: axisPosition.vertical,
      w: axisPosition.horizontal - padding + 1
    }, {
      x: axisPosition.horizontal,
      y: padding,
      h: axisPosition.vertical - padding
    }]);
  }
  renderHorizontalAxisLabels(axisPosition, horizontalAxisLabels) {
    horizontalAxisLabels.forEach((label) => {
      const text = this.createAxisLabelText( label.value );
      text.x = label.x - text.getMeasuredWidth() / 2;
      text.y = axisPosition.vertical + 2;
      this.stage.addChild(text);
    });
  }
  renderVerticalAxisLabels(axisPosition, verticalAxisLabels) {
    verticalAxisLabels.forEach((label) => {
      const text = this.createAxisLabelText( label.value );
      text.x = axisPosition.horizontal + 4;
      text.y = label.y - text.getMeasuredHeight() / 2 -1;
      this.stage.addChild(text);
    });
  }

  cache() {

  }

  drowLine( g, color, lines ) {
    g = g.beginFill(color);
    lines.forEach( (line) => {
      if (line.w) {
        g = g.drawRect( line.x, line.y, line.w, 1 );
      } else if (line.h) {
        g = g.drawRect( line.x, line.y, 1, line.h );
      }
    });
    return g.endFill();
  }
  createAxisLabelText( text ) {
    return new CreateJS.Text(text, "10px Roboto Condensed", "#AAAAAA");
  }

}
