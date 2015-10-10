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

const now = new Date().getTime();
const day = 1000*60*60*24;
const periodSelections = [
  { id: "week",         text: "直近の1週間", time: new Date(now-7*day)},
  { id: "one_month",    text: "直近の30日",  time: new Date(now-30*day)},
  { id: "three_months", text: "直近の90日",  time: new Date(now-90*day)},
  { id: "one_year",     text: "直近の1年",   time: new Date(now-365*day)}
];

const keys = new Set([
  "summary", "enablePeriodSelector"
]);

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
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);

    if (model.enablePeriodSelector) {
      model.startTime = periodSelections[0].time;
    } else {
      model.load();
    }
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
              {label: "最大ドローダウン", value: summary.formatedMaxLoss },
              {label: "平均ドローダウン", value: summary.formatedAvgLoss }
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
            menuItems={periodSelections}
            selectedIndex={this.state.selectedIndex}
            onChange={this.onChange.bind(this)}/>
        </span>
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
TradingSummaryView.defaultProps = {
  model: null
};
