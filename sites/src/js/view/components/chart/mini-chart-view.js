import React        from "react"
import MUI          from "material-ui"
import AbstractCard from "../widgets/abstract-card"
import Chart        from "../chart/chart"

import IntervalSelector from "../chart/interval-selector"
import PairSelector     from "../chart/pair-selector"

export default class MiniChartView extends AbstractCard {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  getClassName() {
    return "mini-chart";
  }
  getTitle() {
    return "";
  }
  getBodyContentStyle() {
    return {padding: "0px 0px 8px 0px"};
  }
  createBody() {
    return <div>
      <div className="header">
      <PairSelector model={this.props.model} />
      <IntervalSelector model={this.props.model} />
      </div>
      <div className="chart">
        <Chart
          {...this.props}
          enableSlider={false} />
      </div>
    </div>;
  }

}
MiniChartView.propTypes = {
  size:  React.PropTypes.object.isRequired,
  model: React.PropTypes.object.isRequired
};
MiniChartView.defaultProps = {
  size: {w:1280-300-16*4, h:300, profitAreaHeight:80}
};
