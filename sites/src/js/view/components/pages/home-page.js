import React               from "react"

import AbstractPage        from "./abstract-page"
import AccountSummaryCard  from "../accounts/account-summary-card"
import MiniChart           from "../chart/mini-chart-view"
import NotificationsCard   from "../notifications/notifications-card"
import PositionsCard       from "../positions/positions-card"

export default class HomePage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize();
  }

  render() {
    const model = this.model();
    return (
      <div className="home-page page">
        <AccountSummaryCard
          accounts={model.accounts}
          visibleTradingSummary={model.visibleTradingSummary}
          tradingSummary={model.tradingSummary} />
        <MiniChart
          model={model.miniChart}
          size={this.calculateChartSize()}/>
        <NotificationsCard
          model={model.notifications} />
        <PositionsCard
          model={model.positions} />
      </div>
    );
  }

  calculateChartSize() {
    const windowSize = this.context.windowResizeManager.windowSize;
    return {
      w: windowSize.w - 288 - 16*5,
      h: 300,
      profitAreaHeight: 80
    };
  }

  model() {
    return this.context.application.homePageModel;
  }
}
HomePage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  windowResizeManager: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
