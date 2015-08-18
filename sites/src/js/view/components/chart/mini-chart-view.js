import React        from "react"
import MUI          from "material-ui"
import AbstractCard from "../widgets/abstract-card"
import Chart        from "../chart/chart"
import Theme        from "../../theme"

import IntervalSelector from "../chart/interval-selector"
import PairSelector     from "../chart/pair-selector"
import RateView         from "../chart/rate-view"
import MenuItem         from 'material-ui/lib/menus/menu-item'

const IconButton = MUI.IconButton;
const IconMenu   = MUI.IconMenu;
//const MenuItem   = MUI.MenuItem;

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
    const iconButtonElement = <IconButton
        iconClassName="md-more-vert"
        iconStyle={{color:Theme.getPalette().textColorLight}}
      />;
    return <div>
      <div className="header">
        <PairSelector model={this.props.model} />
        <IntervalSelector model={this.props.model} />
        <IconMenu iconButtonElement={iconButtonElement}
          style={{float:"right",marginTop:"8px"}}
          onItemTouchTap={this.onMenuItemTouchTap.bind(this)}>
          <MenuItem primaryText="更新" />
        </IconMenu>
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
