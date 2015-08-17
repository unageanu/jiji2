import CreateJS               from "easeljs"
import AbstractChartComponent from "./abstract-chart-component"
import CoordinateCalculator   from "../../../viewmodel/chart/coordinate-calculator"
import DateFormatter          from "../../../viewmodel/utils/date-formatter"
import Theme                  from "../../theme"

const padding = CoordinateCalculator.padding();
const palette = Theme.getPalette();
const color   = palette.accent1Color;
const textColor = "#FFF";
const shadowColor = "rgba(150,150,150,0.5)";
const verticalHandleWidth  = 72;
const verticalHandleHeight = 20;
const horizontalHandleWidth  = 72;
const horizontalHandleHeight = 20;

export default class Pointer extends AbstractChartComponent {

  constructor( chartModel, slidableMask ) {
    super(chartModel);
    this.initSprite(slidableMask);
    this.registerDragAction();
  }

  addObservers() {
    this.chartModel.pointer.addObserver(
      "propertyChanged", this.onPropertyChanged.bind(this), this);
  }
  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.verticalPointer);
    this.stage.addChild(this.horizontalPointer);
  }

  unregisterObservers() {
    this.chartModel.pointer.removeAllObservers(this);
    this.chartModel.slider.removeAllObservers(this);
  }

  onPropertyChanged(name, event) {
    this.initPointer();
    if (this.chartModel.pointer.time
      && (this.chartModel.pointer.price || this.chartModel.pointer.balance)) {
      this.show();
    }
    if (event.key === "x") {
      this.verticalPointer.x = event.newValue - verticalHandleWidth/2;
    } else if (event.key === "y") {
      this.horizontalPointer.y = event.newValue - horizontalHandleHeight/2;
    } else if (event.key === "time") {
      this.verticalLabel.text =
        DateFormatter.format(event.newValue, "MM-dd hh:mm");
    } else if (event.key === "price" || event.key === "balance") {
      this.horizontalLabel.text = event.newValue;
    }
    this.stage.update();
  }

  initSprite(slidableMask) {
    this.verticalPointer   = this.initializeElement(new CreateJS.Container());
    this.horizontalPointer = this.initializeElement(new CreateJS.Container());
  }
  initPointer() {
    if ( this.verticalLabel ) return;

    const candleSticks         = this.chartModel.candleSticks;
    const axisPosition         = candleSticks.axisPosition;
    this.initVerticalPointer(axisPosition);
    this.initHorizontalPointer(axisPosition);
    this.hide();
  }

  hide() {
    this.verticalPointer.visible = false;
    this.horizontalPointer.visible = false;
  }
  show() {
    this.verticalPointer.visible = true;
    this.horizontalPointer.visible = true;
  }

  initVerticalPointer(axisPosition) {
    const shape = new CreateJS.Shape();
    //shape.shadow = new CreateJS.Shadow(shadowColor, 1, 1, 3);
    shape.graphics.beginFill(color)
     .drawRect(verticalHandleWidth/2, padding, 1, axisPosition.vertical )
     .drawRect(0,  axisPosition.vertical+3,
        verticalHandleWidth, verticalHandleHeight )
     .moveTo(verticalHandleWidth/2-5, axisPosition.vertical+3)
     .lineTo(verticalHandleWidth/2+0.5, axisPosition.vertical-3)
     .lineTo(verticalHandleWidth/2+5, axisPosition.vertical+3)
     .endFill();

    this.verticalLabel = this.createLabelText();
    this.verticalLabel.x = 8;
    this.verticalLabel.y = axisPosition.vertical + 6;

    this.verticalPointer.addChild(shape);
    this.verticalPointer.addChild(this.verticalLabel);
  }
  initHorizontalPointer(axisPosition) {
    const shape = new CreateJS.Shape();
    //shape.shadow = new CreateJS.Shadow(shadowColor, 1, 1, 3);
    shape.graphics.beginFill(color)
     .drawRect(padding, horizontalHandleHeight/2, axisPosition.horizontal-3, 1)
     .moveTo(axisPosition.horizontal+3, horizontalHandleHeight/2-5)
     .lineTo(axisPosition.horizontal-3, horizontalHandleHeight/2+0.5)
     .lineTo(axisPosition.horizontal+3, horizontalHandleHeight/2+5)
     .drawRect(axisPosition.horizontal+3, 0,
       horizontalHandleWidth, horizontalHandleHeight )
     .endFill();

    this.horizontalLabel = this.createLabelText();
    this.horizontalLabel.x = axisPosition.horizontal + 7;
    this.horizontalLabel.y = 3;

    this.horizontalPointer.addChild(shape);
    this.horizontalPointer.addChild(this.horizontalLabel);
  }

  registerDragAction() {
    this.verticalPointer.addEventListener("mousedown", (event) => {
      this.slideXStart = this.chartModel.pointer.x - event.stageX;
    });
    this.verticalPointer.addEventListener("pressmove", (event) => {
      if (this.slideXStart == null) return;
      this.chartModel.pointer.x = this.slideXStart + event.stageX;
    });
    this.verticalPointer.addEventListener("pressup", (event) => {
      this.slideXStart = null;
    });
    this.horizontalPointer.addEventListener("mousedown", (event) => {
      this.slideYStart = this.chartModel.pointer.y - event.stageY;
    });
    this.horizontalPointer.addEventListener("pressmove", (event) => {
      if (this.slideYStart == null) return;
      this.chartModel.pointer.y = this.slideYStart + event.stageY;
    });
    this.horizontalPointer.addEventListener("pressup", (event) => {
      this.slideYStart = null;
    });
  }

  cache() {
  }

  createLabelText( text ) {
    return new CreateJS.Text("", "12px Roboto Condensed", textColor);
  }
}
