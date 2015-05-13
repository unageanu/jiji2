import CreateJS     from "easeljs";
import CandleSticks from "./candle-sticks";
import Background   from "./background";
import Axises       from "./axises";

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
    this.background   = new Background( this.chartModel );
    this.axises       = new Axises( this.chartModel );
    this.candleSticks = new CandleSticks( this.chartModel );
  }
  initViewComponents() {
    this.background.attach( this.stage );
    this.axises.attach( this.stage );
    this.candleSticks.attach( this.stage );
  }

}
