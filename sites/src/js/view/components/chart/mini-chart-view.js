import React        from "react"
import MUI          from "material-ui"
import AbstractCard from "../widgets/abstract-card"
import Chart        from "../chart/chart"

import IntervalSelector  from "../chart/interval-selector"
import PairSelector      from "../chart/pair-selector"
import RateView          from "../chart/rate-view"
import SettingMenuButton from "../widgets/setting-menu-button"

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
        <SettingMenuButton
          menuItems={["更新"]}
          style={{float:"right",marginTop:"8px"}}
          onItemTouchTap={this.onMenuItemTouchTap.bind(this)} />
      </div>
      <div className="chart">
        <RateView chartModel={this.props.model} />
        <Chart
          {...this.props}
          enableSlider={false} />
      </div>
    </div>;
  }

  onMenuItemTouchTap(e, item) {
    this.props.model.reload();
  }

}
MiniChartView.propTypes = {
  size:  React.PropTypes.object.isRequired,
  model: React.PropTypes.object.isRequired
};
MiniChartView.defaultProps = {
  size: {w:1280-300-16*4, h:300, profitAreaHeight:80}
};
