
import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"
import CoordinateCalculator   from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class Axises extends AbstractChartComponent {

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
    this.stage.addChild(this.verticalLineShape);
    this.stage.addChild(this.horizontalLineShape);
    this.stage.addChild(this.verticalAxisLabelContainer);
    this.stage.addChild(this.horizontalAxisLabelContainer);
    this.stage.addChild(this.baseLineShape);
  }

  onPropertyChanged(name, event) {
    if (event.key === "sticks") {
      this.update();
    }
  }

  initSprite() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    this.verticalLineShape   = this.initializeElement(new CreateJS.Shape(), stageSize);
    this.horizontalLineShape = this.initializeElement(new CreateJS.Shape(), stageSize);
    this.baseLineShape       = this.initializeElement(new CreateJS.Shape(), stageSize);

    this.verticalAxisLabelContainer   = this.initializeElement(new CreateJS.Container(), stageSize);
    this.horizontalAxisLabelContainer = this.initializeElement(new CreateJS.Container(), stageSize);

    this.renderBaseLine();
  }

  initializeElement(element, stageSize) {
    element.x = element.y = 0;
    element.setBounds( 0, 0, stageSize.w, stageSize.h );
    return element;
  }

  renderBaseLine() {
    const axisPosition = this.chartModel.candleSticks.axisPosition;
    let g = this.baseLineShape.graphics;
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

  update() {
    this.clearScreen();
    this.renderAxises();
    this.cache();
  }

  clearScreen() {
    this.verticalLineShape.graphics.clear();
    this.horizontalLineShape.graphics.clear();

    this.verticalAxisLabelContainer.removeAllChildren();
    this.horizontalAxisLabelContainer.removeAllChildren();
  }

  renderAxises() {
    const candleSticks         = this.chartModel.candleSticks;
    const axisPosition         = candleSticks.axisPosition;
    const verticalAxisLabels   = candleSticks.verticalAxisLabels;
    const horizontalAxisLabels = candleSticks.horizontalAxisLabels;

    this.renderHorizontalAxisLines( axisPosition, horizontalAxisLabels);
    this.renderVerticalAxisLines(   axisPosition, verticalAxisLabels);
    this.renderHorizontalAxisLabels(axisPosition, horizontalAxisLabels);
    this.renderVerticalAxisLabels(  axisPosition, verticalAxisLabels);
  }

  renderHorizontalAxisLines(axisPosition, horizontalAxisLabels) {
    let g = this.horizontalLineShape.graphics;
    g = this.drowLine(g, "#E5E5E5", horizontalAxisLabels.map((l)=>{
      return {
        x: l.x,
        y: padding,
        h: axisPosition.vertical - padding
      };
    }));
  }
  renderVerticalAxisLines(axisPosition, verticalAxisLabels) {
    let g = this.verticalLineShape.graphics;
    g = this.drowLine(g, "#E0E0E0", verticalAxisLabels.map((l)=>{
      return {
        x: padding,
        y: l.y,
        w: axisPosition.horizontal - padding
      };
    }));
  }
  renderHorizontalAxisLabels(axisPosition, horizontalAxisLabels) {
    horizontalAxisLabels.forEach((label) => {
      const text = this.createAxisLabelText( label.value );
      text.x = label.x - text.getMeasuredWidth() / 2;
      text.y = axisPosition.vertical + 2;
      this.horizontalAxisLabelContainer.addChild(text);
    });
  }
  renderVerticalAxisLabels(axisPosition, verticalAxisLabels) {
    verticalAxisLabels.forEach((label) => {
      const text = this.createAxisLabelText( label.value );
      text.x = axisPosition.horizontal + 4;
      text.y = label.y - text.getMeasuredHeight() / 2 -1;
      this.verticalAxisLabelContainer.addChild(text);
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
    return new CreateJS.Text(text, "11px Roboto Condensed", "#999999");
  }

}
