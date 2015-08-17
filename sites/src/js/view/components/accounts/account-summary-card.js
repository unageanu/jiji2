import React            from "react"
import Router           from "react-router"
import MUI              from "material-ui"
import AbstractCard     from "../widgets/abstract-card"
import BalancePanel     from "./balance-panel"
import PerformancePanel from "./performance-panel"

export default class AccountView extends AbstractCard {

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
      <PerformancePanel model={this.props.tradingSummary} />,
      <BalancePanel     model={this.props.accounts} />,
      <div style={{clear:"both"}} />
    ];
  }

}
AccountView.propTypes = {
  accounts: React.PropTypes.object.isRequired,
  tradingSummary: React.PropTypes.object.isRequired
};
