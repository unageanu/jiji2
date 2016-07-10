
import CreateJS               from "easeljs"
import AbstractChartComponent from "./abstract-chart-component"
import Theme                  from "../../theme"

export default class Background extends AbstractChartComponent {

  constructor( chartModel, devicePixelRatio ) {
    super(chartModel, devicePixelRatio);
    this.initSprite();
  }

  attach( stage ) {
    this.stage = stage;
    this.stage.addChild(this.backgroundShape);
  }

  initSprite() {
    const stageSize = this.chartModel.candleSticks.stageSize;
    const dpr = this.devicePixelRatio;
    this.backgroundShape = this.initializeElement(new CreateJS.Shape());
    this.backgroundShape.graphics
        .beginFill(Theme.palette.backgroundColorDark)
        .drawRect( 0, 0, stageSize.w, stageSize.h )
        .endFill();
    this.backgroundShape.cache(0, 0, stageSize.w, stageSize.h, dpr);
  }
}
