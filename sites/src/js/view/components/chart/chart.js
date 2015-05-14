import CreateJS             from "easeljs"
import CandleSticks         from "./candle-sticks"
import Background           from "./background"
import Axises               from "./axises"
import CoordinateCalculator from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class Chart {

  constructor( canvas, scale, viewModel ) {

    this.chartModel = viewModel;

    this.buildStage(canvas, scale);
    this.buildViewComponents();

    this.initViewComponents();
  }

  buildStage(canvas, scale) {
    this.stage = new CreateJS.Stage(canvas);
    this.stage.scaleX = scale;
    this.stage.scaleY = scale;

    this.registerSlideAction();
  }

  buildViewComponents() {
    this.slidableMask = this.createSlidableMask();

    this.background   = new Background( this.chartModel );
    this.axises       = new Axises( this.chartModel, this.slidableMask );
    this.candleSticks = new CandleSticks( this.chartModel, this.slidableMask );
  }
  initViewComponents() {
    this.background.attach( this.stage );
    this.axises.attach( this.stage );
    this.candleSticks.attach( this.stage );
  }

  registerSlideAction() {
    this.stage.addEventListener("mousedown", (event) => {
      this.slideStart = event.stageX;
      this.chartModel.slider.slideStart();
    });
    this.stage.addEventListener("pressmove", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
    });
    this.stage.addEventListener("pressup", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
      this.chartModel.slider.slideEnd();
      this.slideStart = null;
    });
  }

  doSlide(x) {
    x = Math.ceil((this.slideStart - x) / 6) * -6;
    this.chartModel.slider.slideByChart(x/6);
  }

  createSlidableMask() {
    const stageSize    = this.chartModel.candleSticks.stageSize;
    const axisPosition = this.chartModel.candleSticks.axisPosition;
    const mask         = new CreateJS.Shape();
    mask.graphics.beginFill("#000000")
      .drawRect( padding, padding, axisPosition.horizontal- padding, stageSize.h )
      .endFill();
    return mask;
  }
}
