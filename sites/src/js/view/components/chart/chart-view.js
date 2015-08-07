import React             from "react"
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component"
import Chart             from "../chart/chart"

import IntervalSelector from "../chart/interval-selector"
import PairSelector     from "../chart/pair-selector"

export default class ChartView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <PairSelector model={this.props.model} />
        <IntervalSelector model={this.props.model} />
        <Chart
          {...this.props}
          enableSlider={true}
          displayPositionsAndGraphs={true} />
      </div>
    );
  }

  model() {
    return this.context.application.homePageModel;
  }
}
ChartView.propTypes = {
  devicePixelRatio: React.PropTypes.number.isRequired,
  size: React.PropTypes.object.isRequired,
  model: React.PropTypes.object.isRequired
};
ChartView.defaultProps = {
  devicePixelRatio: window.devicePixelRatio || 1,
  size: {w:600, h:500}
};
