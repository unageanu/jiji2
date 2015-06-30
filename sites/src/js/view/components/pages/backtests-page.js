import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import BacktestList from "../backtests/backtest-list"

export default class BacktestsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.backtestsPageModel();
    model.initialize(this.props.params);
  }

  render() {
    const model = this.backtestsPageModel();
    return (
      <div className="backtests">
        <BacktestList
          selectedId={model.selectedBacktestId}
          model={model.backtestListModel} />
      </div>
    );
  }

  backtestsPageModel() {
    return this.context.application.backtestsPageModel;
  }
}
BacktestsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
