import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import TradingSummaryView from "../trading-summary/trading-summary-view"

const Card = MUI.Card;

export default class RMTTradingSummaryPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="rmt-trading-summary-page">
        <Card>
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
  router: React.PropTypes.func
};
