import React               from "react"
import MUI                 from "material-ui"
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
      <div>
        <AccountSummaryCard
          accounts={model.accounts}
          visibleTradingSummary={model.visibleTradingSummary}
          tradingSummary={model.tradingSummary} />
        <MiniChart
          model={model.miniChart}/>
        <NotificationsCard
          model={model.notifications} />
        <PositionsCard
          model={model.positions} />
      </div>
    );
  }

  model() {
    return this.context.application.homePageModel;
  }
}
HomePage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
