
import CreateJS               from "easeljs";
import AbstractChartComponent from "./abstract-chart-component"

export default class Background extends AbstractChartComponent {

  constructor( chartModel ) {
    super(chartModel);
    this.initSprite();
  }

  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.backgroundShape);
  }

  initSprite() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    this.backgroundShape = this.initializeElement(new CreateJS.Shape());
    this.backgroundShape.graphics
        .beginFill("#F0F0F0")
        .drawRect( 0, 0, stageSize.w, stageSize.h )
        .endFill();
  }
}
