import React                from "react"

import AbstractPage         from "./abstract-page"
import BacktestList         from "../backtests/backtest-list"
import BacktestDetailsPanel from "../backtests/backtest-details-panel"

import Card from "material-ui/Card"

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
      <div className="backtests-page page">
        <Card className="main-card">
          <BacktestList model={model} />
          <BacktestDetailsPanel model={model} />
        </Card>
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
