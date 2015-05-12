import CreateJS     from "easeljs";
import CandleSticks from "./candle-sticks";

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
  }
  buildViewComponents() {
    this.candleSticks = new CandleSticks( this.chartModel );
  }
  initViewComponents() {
    this.candleSticks.attach( this.stage );
  }

}
