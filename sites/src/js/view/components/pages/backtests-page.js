import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import BacktestList from "../backtests/backtest-list"
import Chart        from "../chart/chart"

export default class BacktestsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      selectedBacktestId: null,
      selectedBacktest: null
    };
  }

  componentWillMount() {
    const model = this.model();
    model.addObserver("propertyChanged",
      this.onPropertyChanged.bind(this), this);
    model.initialize();
    model.selectedBacktestId = this.props.params.id;
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  componentWillReceiveProps(nextProps) {
    this.model().selectedBacktestId = nextProps.params.id;
  }

  render() {
    const model = this.model();
    const chart = this.state.selectedBacktest
      ? <Chart
          key={"chart_" + this.state.selectedBacktest.id}
          backtest={this.state.selectedBacktest}
          displayPositionsAndGraphs={true}
          size={{w:600, h:500, profitAreaHeight:150, graphAreaHeight:150}}
        />
      : null;
    return (
      <div className="backtests">
        <BacktestList
          selectedId={this.state.selectedBacktestId}
          model={model.backtestListModel} />
        <div className="details">
          {chart}
        </div>
      </div>
    );
  }

  onPropertyChanged(k, ev) {
    const newState = {};
    newState[ev.key] = ev.newValue;
    this.setState(newState);
  }

  model() {
    return this.context.application.backtestsPageModel;
  }
}
BacktestsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
