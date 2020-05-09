import React          from "react"
import { injectIntl } from 'react-intl';

import AbstractCard from "../widgets/abstract-card"
import Chart        from "../chart/chart"

import IntervalSelector  from "../chart/interval-selector"
import PairSelector      from "../chart/pair-selector"
import RateView          from "../chart/rate-view"
import SettingMenuButton from "../widgets/setting-menu-button"
import LoadingView       from "../widgets/loading-view"

class MiniChartView extends AbstractCard {

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
  getSettingMenuItems() {
    const { formatMessage } = this.props.intl;
    return [formatMessage({ id: 'common.action.reload' })];
  }
  createHeader() {
    const settingMenu = this.createSettingMenu("8px");
    return <div className="header">
        <span className="icon md-trending-up"></span>
        <PairSelector model={this.props.model} />
        <IntervalSelector model={this.props.model} />
        {settingMenu}
      </div>;
  }
  createBody() {
    return <div className="chart">
      <div className="loading">
        <LoadingView xhrManager={
            this.props.model.positionService.xhrManager
        } left={-40} />
      </div>
      <RateView chartModel={this.props.model} />
      <Chart
        {...this.props}
        enableSlider={false} />
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

export default injectIntl(MiniChartView);
