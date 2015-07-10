import React             from "react"
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component"
import Chart             from "../chart/chart"

export default class MiniChartView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <Chart
          {...this.props}
          enableSlider={false}
          displayPositionsAndGraphs={false} />
      </div>
    );
  }

  model() {
    return this.context.application.homePageModel;
  }
}
MiniChartView.propTypes = {
  devicePixelRatio: React.PropTypes.number.isRequired,
  size: React.PropTypes.object.isRequired,
  model: React.PropTypes.object.isRequired
};
MiniChartView.defaultProps = {
  devicePixelRatio: window.devicePixelRatio || 1,
  size: {w:600, h:500}
};
