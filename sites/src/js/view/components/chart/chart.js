import CreateJS     from "easeljs";
import CandleSticks from "./candle-sticks";

export default class Chart {

  constructor( canvas, scale, stageSize, viewModelFactory ) {
    this.buildStage(canvas, scale);
    this.buildChartModel(stageSize, viewModelFactory);
    this.buildViewComponents();

    this.initViewComponents();
  }

  buildStage(canvas, scale) {
    this.stage = new CreateJS.Stage(canvas);
    this.stage.scaleX = scale;
    this.stage.scaleY = scale;
  }
  buildChartModel(stageSize, viewModelFactory) {
    this.chartModel = viewModelFactory.createChart();
    this.chartModel.stageSize = stageSize;
  }
  buildViewComponents() {
    this.candleSticks = new CandleSticks( this.chartModel );
  }
  initViewComponents() {
    this.candleSticks.attach( this.stage );
  }
  initModel() {
    this.chartModel.initialize();
  }

}
