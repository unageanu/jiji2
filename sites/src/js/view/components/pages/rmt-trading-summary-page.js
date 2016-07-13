import React              from "react"

import AbstractPage       from "./abstract-page"
import TradingSummaryView from "../trading-summary/trading-summary-view"

import Card from "material-ui/Card"

export default class RMTTradingSummaryPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize();
  }

  render() {
    return (
      <div className="rmt-trading-summary-page page">
        <Card className="main-card">
          <TradingSummaryView model={this.model().tradingSummary} />
        </Card>
      </div>
    );
  }

  model() {
    return this.context.application.rmtTradingSummaryPageModel;
  }
}
RMTTradingSummaryPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.object
};
