
import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"
import CoordinateCalculator   from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class PositionsView extends AbstractChartComponent {

  constructor( chartModel, slidableMask ) {
    super(chartModel);
    this.initSprite(slidableMask);
  }

  addObservers() {
    if (this.chartModel.slider) this.chartModel.slider.addObserver(
      "propertyChanged", this.onSliderPropertyChanged.bind(this), this);
    if (this.chartModel.positions) this.chartModel.positions.addObserver(
      "propertyChanged", this.onPositionsPropertyChanged.bind(this), this);
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.shape);
  }
  unregisterObservers() {
    if (this.chartModel.positions) {
      this.chartModel.positions.removeAllObservers(this);
    }
    if (this.chartModel.slider) {
      this.chartModel.slider.removeAllObservers(this);
    }
  }

  onPositionsPropertyChanged(name, event) {
    if (event.key === "positionsForDisplay") {
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
    this.renderPositions();
    this.cache();
    this.stage.update();
  }

  clearScreen() {
    this.shape.graphics.clear();
    this.shape.x = this.shape.y = 0;
  }

  renderPositions() {
    const axisPosition = this.chartModel.candleSticks.axisPosition;
    const bottom = axisPosition.verticalSpliter || axisPosition.vertical;

    const slots = this.chartModel.positions.positionsForDisplay;
    let g = this.shape.graphics;
    slots.forEach((positions, index) => {
      const y = bottom - 5 - (index * 10);
      positions.forEach((position)=>{
        this.renderPosition(position, y-0.5, axisPosition, g);
      });
    });
  }

  renderPosition(position, y, axisPosition, graphics) {
    const color = this.calculateColor(position);
    let g = graphics.beginStroke(color);
    g = g.beginFill( position.sellOrBuy === "buy" ? color : "#FFF");
    g = g.drawCircle(position.startX, y, 2);
    if ( position.endX == null ) {
      g = g.moveTo(position.startX+2, y)
           .lineTo(axisPosition.horizontal, y).closePath();
    } else if ( position.endX - position.startX > 4 ) {
     g = g.moveTo(position.startX+2, y)
          .lineTo(position.endX-2, y).closePath();
    }
    if (position.startX !== position.endX) {
      g = g.moveTo(position.endX+2, y)
      g = g.drawCircle(position.endX, y, 2);
    }
    g.endStroke().endFill();
  }

  calculateColor(position) {
    if ( position.profitOrLoss == 0 ) return "#AAAAAA";
    return position.profitOrLoss > 0 ? "#00BFA5" : "#FF3366";
  }

  cache() {}

}
