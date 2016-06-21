import React              from "react"

import AbstractPage       from "./abstract-page"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import BacktestBuilder    from "../backtests/backtest-builder"


import Card from "material-ui/Card"

export default class NewBacktestPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
      return (
      <div className="new-backtest page">
        <Card className="main-card">
          <BacktestBuilder model={this.backtestBuilder()} />
        </Card>
      </div>
    );
  }

  backtestBuilder() {
    return this.model().backtestBuilder;
  }
  model() {
    return this.context.application.newBacktestPageModel;
  }
}
NewBacktestPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
