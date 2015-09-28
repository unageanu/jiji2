import React             from "react"
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component"
import Chart             from "../chart/chart"

import IntervalSelector  from "../chart/interval-selector"
import PairSelector      from "../chart/pair-selector"
import RateView          from "../chart/rate-view"
import Slider            from "../chart/slider"
import LoadingView       from "../widgets/loading-view"

const conpactSelectorStyles = {
  style: {
    height: "32px"
  },
  labelStyle: {
    fontSize: "16px",
    lineHeight: "normal",
    top: "6px"
  },
  iconStyle: {
    top: "4px"
  }
};

export default class ChartView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="chart-view">
        <div className="menu">
          <PairSelector model={this.props.model} {...conpactSelectorStyles} />
          <IntervalSelector model={this.props.model} {...conpactSelectorStyles} />
        </div>
        <div className="chart">
          <div className="loading">
            <LoadingView xhrManager={
                this.props.model.positionService.xhrManager
            } type="gray" />
          </div>
          <RateView chartModel={this.props.model} />
          <Chart {...this.props} />
        </div>
        <div className="slider-panel">
          <Slider chartModel={this.props.model}></Slider>
        </div>
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
  size: {w:1280-300-16*4, h:600, profitAreaHeight:80}
};
