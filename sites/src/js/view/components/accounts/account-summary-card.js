import React            from "react"
import { Router } from 'react-router'

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
    const body = [];
    if (this.props.visibleTradingSummary) {
      body.push(<PerformancePanel
        key="performance" model={this.props.tradingSummary} />);
    }
    body.push(<BalancePanel key="balance"
      visibleTradingSummary={this.props.visibleTradingSummary}
      model={this.props.accounts} />);
    body.push(<div key="clear" style={{clear:"both"}} />);
    return body;
  }

}
AccountSummaryView.propTypes = {
  accounts: React.PropTypes.object.isRequired,
  tradingSummary: React.PropTypes.object,
  visibleTradingSummary: React.PropTypes.bool
};
