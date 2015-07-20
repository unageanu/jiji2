import React             from "react"
import Router            from "react-router"
import MUI               from "material-ui"
import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"

const DropDownMenu  = MUI.DropDownMenu;
const DoughnutChart = ReactChart.Doughnut;
const doughnutChartOptions = {
  tooltipTemplate(values) {
    return `${values.label} ${values.value}`;
  }
};

const now = new Date().getTime();
const day = 1000*60*60*24;
const periodSelections = [
  { id: "week",         text: "直近の1週間", time: new Date(now-7*day)},
  { id: "one_month",    text: "直近の30日",  time: new Date(now-30*day)},
  { id: "three_months", text: "直近の90日",  time: new Date(now-90*day)},
  { id: "one_year",     text: "直近の1年",   time: new Date(now-365*day)}
];

export default class TradingSummaryView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      summary :              null,
      enablePeriodSelector : false,
      selectedIndex:         0
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    if (this.props.model.enablePeriodSelector) {
      this.props.model.startTime = periodSelections[0].time;
    } else {
      this.props.model.load();
    }
    this.setState({
      summary :               this.props.model.summary,
      enablePeriodSelector :  this.props.model.enablePeriodSelector
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    if (!this.state.summary) return null;
    const periodSelector = this.createPeriodSelector();
    const summary = this.state.summary;
    return (
      <div className="trading-summary">
        {periodSelector}
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

  createPeriodSelector() {
    if (!this.state.enablePeriodSelector) return null;
    return (
      <div>
        集計期間
        <DropDownMenu
          menuItems={periodSelections}
          selectedIndex={this.state.selectedIndex}
          onChange={this.onChange.bind(this)}/>
      </div>
    );
  }

  onChange(e, selectedIndex, menuItem) {
    this.props.model.startTime = periodSelections[selectedIndex].time;
    this.setState({selectedIndex:selectedIndex});
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
