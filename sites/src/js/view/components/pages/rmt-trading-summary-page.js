import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import TradingSummaryView from "../trading-summary/trading-summary-view"

export default class RMTTradingSummaryPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.model().tradingSummary.load("rmt");
  }

  render() {
    return (
      <div>
        <TradingSummaryView model={this.model().tradingSummary} />
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
