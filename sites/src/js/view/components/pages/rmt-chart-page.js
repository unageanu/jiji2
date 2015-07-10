import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import ChartView        from "../chart/chart-view"

export default class RMTChartPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <ChartView
          model={this.model().chart}
          size={{w:600, h:500, profitAreaHeight:100, graphAreaHeight:100}}/>
      </div>
    );
  }

  model() {
    return this.context.application.rmtChartPageModel;
  }
}
RMTChartPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
