
import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"
import CoordinateCalculator   from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class GraphView extends AbstractChartComponent {

  constructor( chartModel, slidableMask ) {
    super(chartModel);
    this.initSprite(slidableMask);
  }

  addObservers() {
    this.chartModel.slider.addObserver(
      "propertyChanged", this.onSliderPropertyChanged.bind(this), this);
    this.chartModel.graphs.addObserver(
      "propertyChanged", this.onGraphPropertyChanged.bind(this), this);
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.shape);
  }
  unregisterObservers() {
    this.chartModel.graphs.removeAllObservers(this);
    this.chartModel.slider.removeAllObservers(this);
  }

  onGraphPropertyChanged(name, event) {
    if (event.key === "lines") {
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
    this.shape.x = x;
    this.stage.update();
  }

  initSprite(slidableMask) {
    this.shape   = this.initializeElement(new CreateJS.Shape());
    this.shape.mask = slidableMask;
  }

  update() {
    this.clearScreen();
    this.renderGraphs();
    this.cache();
  }

  clearScreen() {
    this.shape.graphics.clear();
    this.shape.x = this.shape.y = 0;
  }

  renderGraphs() {
    const lines = this.chartModel.graphs.lines;
    let g = this.shape.graphics;
    g.setStrokeStyle(1);
    lines.forEach((line) => this.renderLine(line, g));
  }

  renderLine(line, graphics) {
    let g = graphics.beginStroke(line.color);
    line.line.forEach( (data, i) => {
      if (i === 0) {
        g = g.moveTo( data.x, data.y );
      } else {
        g = g.lineTo( data.x, data.y );
      }
    });
    g = g.endStroke();
  }

  cache() {}

}
