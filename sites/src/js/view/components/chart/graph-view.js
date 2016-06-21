
import CreateJS               from "easeljs"
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
    if (this.chartModel.graphs) this.chartModel.graphs.addObserver(
      "propertyChanged", this.onGraphPropertyChanged.bind(this), this);
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.shape);
  }
  unregisterObservers() {
    if (this.chartModel.graphs) this.chartModel.graphs.removeAllObservers(this);
    if (this.chartModel.slider) this.chartModel.slider.removeAllObservers(this);
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
    this.stage.update();
  }

  clearScreen() {
    this.shape.graphics.clear();
    this.shape.x = this.shape.y = 0;
  }

  renderGraphs() {
    const series = this.chartModel.graphs.lines;
    let g = this.shape.graphics;
    series.forEach((s) => this.renderSeries(s, g));
  }

  renderSeries(series, graphics) {
    if (series.type === "balance") {
      this.renderBalanceGraph(series, graphics);
    } else {
      this.renderLinerGraph(series, graphics);
    }
  }

  renderLinerGraph(series, graphics) {
    let g = graphics.beginStroke(series.color);
    g.setStrokeStyle(1);
    series.line.forEach( (data, i) => {
      if (i === 0) {
        g = g.moveTo( data.x, data.y );
      } else {
        g = g.lineTo( data.x, data.y );
      }
    });
    g = g.endStroke();
  }
  renderBalanceGraph(series, graphics) {
    if (series.line.length <= 0) return;

    let g = graphics.beginFill("rgba(50,90,205,0.10)");
    series.line.forEach( (data, i) => {
      if (i === 0) {
        g = g.moveTo( data.x, data.y );
      } else {
        g = g.lineTo( data.x, data.y );
      }
    });

    const axisPosition = this.chartModel.candleSticks.axisPosition;
    const last  = series.line[series.line.length-1];
    const first = series.line[0];
    const bottom = axisPosition.verticalSpliter || axisPosition.vertical;
    g = g.lineTo( axisPosition.horizontal, last.y )
         .lineTo( axisPosition.horizontal, bottom )
         .lineTo( 0, bottom )
         .lineTo( 0, first.y )
         .closePath();
    g = g.endFill();
  }

  cache() {}

}
