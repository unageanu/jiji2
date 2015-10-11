import React             from "react"
import Router            from "react-router"
import MUI               from "material-ui"
import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"
import SummaryItem       from "./summary-item"
import CircleGraph       from "./circle-graph"
import TrendIcon         from "../widgets/trend-icon"
import LoadingImage      from "../widgets/loading-image"

const DropDownMenu  = MUI.DropDownMenu;

const keys = new Set([
  "summary", "enablePeriodSelector", "availableAggregationPeriods"
]);

export default class TradingSummaryView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      summary :              null,
      enablePeriodSelector : false,
      availableAggregationPeriods: [],
      selectedIndex:         0
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    const periodSelector = this.createPeriodSelector();
    return (
      <div className="trading-summary-view">
        {this.createPeriodSelector()}
        {this.createContnet()}
      </div>
    );
  }

  createContnet() {
    const summary = this.state.summary;
    if (!summary) {
      return <div className="center-information">
        <LoadingImage left={-20}/>
      </div>;
    }
    return (
      <div className="content">
        <div className="summaries">
          <SummaryItem
            label="損益合計"
            value={[
              <span key="1">¥{summary.formatedProfitOrLoss}</span>,
              <TrendIcon key="2" value={summary.profitOrLoss.totalProfitOrLoss} />
            ]}
            subContents={[
              {label: "総利益", value: "¥" + (summary.formatedTotalProfit||"-") },
              {label: "総損失", value: "¥" + (summary.formatedTotalLoss||"-") }
            ]} />
          <SummaryItem
            label="勝率"
            value={summary.formatedWinPercentage}
            subContents={[
              {label: "勝", value: summary.winsAndLosses.win },
              {label: "負",   value: summary.winsAndLosses.lose }
            ]} />
          <SummaryItem
            label="取引回数"
            value={summary.formatedPositionCount}
            subContents={[
              {label: "決済済",   value: summary.formatedExitedPositionCount }
            ]} />
          <SummaryItem
            label="Profit Factor"
            value={summary.formatedProfitFactor}
            subContents={[
              {label: "最大損失", value: summary.formatedMaxLoss },
              {label: "平均損失", value: summary.formatedAvgLoss }
            ]} />
        </div>
        <div className="charts">
          <CircleGraph
            title="通貨ペア"
            data={summary.pairData} />
          <CircleGraph
            title="売/買"
            data={summary.sellOrBuyData} />
          <CircleGraph
            title="エージェント"
            data={summary.agentsData} />
        </div>
        <div className="data">
          <div className="item">
            <div className="title">建玉の保有期間</div>
            <div className="details">
              <div className="item">
                <div className="label">最長</div>
                <div className="value">
                  {summary.formatedMaxPeriod}
                </div>
              </div>
              <div className="item">
                <div className="label">最短</div>
                <div className="value">
                  {summary.formatedMinPeriod}
                </div>
              </div>
              <div className="item">
                <div className="label">平均</div>
                <div className="value">
                  {summary.formatedAvgPeriod}
                </div>
              </div>
            </div>
          </div>
          <div className="item">
            <div className="title">取引数量</div>
            <div className="details">
              <div className="item">
                <div className="label">最大</div>
                <div className="value">
                  {summary.formatedMaxUnits}
                </div>
              </div>
              <div className="item">
                <div className="label">最小</div>
                <div className="value">
                  {summary.formatedMinUnits}
                </div>
              </div>
              <div className="item">
                <div className="label">平均</div>
                <div className="value">
                  {summary.formatedAvgUnits}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  createPeriodSelector() {
    if (!this.state.enablePeriodSelector) return null;
    return (
      <div className="selector-bar">
        <span className="label">集計期間: </span>
        <span className="selector">
          <DropDownMenu
            menuItems={this.state.availableAggregationPeriods}
            selectedIndex={this.state.selectedIndex}
            onChange={this.onChange.bind(this)}/>
        </span>
      </div>
    );
  }

  onChange(e, selectedIndex, menuItem) {
    this.props.model.startTime =
      this.state.availableAggregationPeriods[selectedIndex].time;
    this.setState({selectedIndex:selectedIndex});
  }
}
TradingSummaryView.propTypes = {
  model: React.PropTypes.object
};
TradingSummaryView.defaultProps = {
  model: null
};
