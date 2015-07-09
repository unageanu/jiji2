import React             from "react"
import Router            from "react-router"
import MUI               from "material-ui"
import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"

const DoughnutChart = ReactChart.Doughnut;
const doughnutChartOptions = {
  tooltipTemplate(values) {
    return `${values.label} ${values.value}`;
  }
};

export default class TradingSummaryView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      summary :    null
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      summary :         this.props.model.summary
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    if (!this.state.summary) return null;
    const summary = this.state.summary;
    return (
      <div className="trading-summary">
        <div className="total-profit-or-loss">
          <span>損益合計:{summary.formatedProfitOrLoss}</span>
        </div>
        <div className="total-profit-or-loss">
          <span>取引回数(約定済み):
          {summary.formatedPositionCount}
          ({summary.formatedExitedPositionCount})</span>
        </div>
        <div>
          <DoughnutChart
            data={summary.winsAndLossesData}
            options={doughnutChartOptions}/>
          <DoughnutChart
            data={summary.sellOrBuyData}
            options={doughnutChartOptions}/>
          <DoughnutChart
            data={summary.pairData}
            options={doughnutChartOptions}/>
        </div>
      </div>
    );
  }
}
TradingSummaryView.propTypes = {
  model: React.PropTypes.object
};
TradingSummaryView.defaultProp = {
  model: null
};
TradingSummaryView.contextTypes = {
  application: React.PropTypes.object.isRequired
};
