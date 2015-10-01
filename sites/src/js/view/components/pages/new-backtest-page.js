import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import BacktestBuilder    from "../backtests/backtest-builder"


export default class NewBacktestPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
      return (
      <div className="new-backtest">
         <BacktestBuilder model={this.backtestBuilder()} />
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
