
import CreateJS               from "easeljs"
import AbstractChartComponent from "./abstract-chart-component"
import Theme                  from "../../theme"

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
        .beginFill(Theme.getPalette().backgroundColorDark)
        .drawRect( 0, 0, stageSize.w, stageSize.h )
        .endFill();
  }
}
