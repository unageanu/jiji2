import React            from "react"
import Router           from "react-router"
import MUI              from "material-ui"
import AbstractCard     from "../widgets/abstract-card"
import BalancePanel     from "./balance-panel"
import PerformancePanel from "./performance-panel"

export default class AccountSummaryView extends AbstractCard {

  constructor(props) {
    super(props);
    this.state = {};
  }

  getClassName() {
    return "account-view";
  }
  getTitle() {
    return "";
  }
  createBody() {
    return [
      <PerformancePanel key="performance" model={this.props.tradingSummary} />,
      <BalancePanel     key="balance"     model={this.props.accounts} />,
      <div key="clear" style={{clear:"both"}} />
    ];
  }

}
AccountSummaryView.propTypes = {
  accounts: React.PropTypes.object.isRequired,
  tradingSummary: React.PropTypes.object.isRequired
};
