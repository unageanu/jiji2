import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import ChartView        from "../chart/chart-view"

const Card = MUI.Card;

export default class RMTChartPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="rmt-chart-page page">
        <Card className="main-card">
          <ChartView
            model={this.model().chart}
            size={this.calculateChartSize()}/>
        </Card>
      </div>
    );
  }

  calculateChartSize() {
    const windowSize = this.context.windowResizeManager.windowSize;
    return {
      w: windowSize.w - 288 - 16*2 - 16*2 -16,
      h: windowSize.h - 100 - 16*2 - 250,
      profitAreaHeight:100,
      graphAreaHeight:100
    };
  }

  model() {
    return this.context.application.rmtChartPageModel;
  }
}
RMTChartPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  windowResizeManager: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
