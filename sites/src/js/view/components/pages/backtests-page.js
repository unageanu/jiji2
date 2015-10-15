import React                from "react"
import MUI                  from "material-ui"
import AbstractPage         from "./abstract-page"
import BacktestList         from "../backtests/backtest-list"
import BacktestDetailsPanel from "../backtests/backtest-details-panel"

export default class BacktestsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      selectedBacktest: null,
    };
  }

  componentWillMount() {
    const model = this.model();
    model.initialize();
    model.selectedBacktestId = this.props.params.id;
  }

  componentWillReceiveProps(nextProps) {
    this.model().selectedBacktestId = nextProps.params.id;
  }

  render() {
    const model      = this.model();
    return (
      <div className="backtests-page">
        <BacktestList model={model} />
        <BacktestDetailsPanel model={model} />
      </div>
    );
  }

  model() {
    return this.context.application.backtestsPageModel;
  }
}
BacktestsPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
