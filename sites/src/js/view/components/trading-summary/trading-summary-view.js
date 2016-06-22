import React             from "react"
import { Router } from 'react-router'

import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"
import SummaryItem       from "./summary-item"
import CircleGraph       from "./circle-graph"
import LoadingImage      from "../widgets/loading-image"
import PriceView         from "../widgets/price-view"

import DropDownMenu from "material-ui/DropDownMenu"

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
      return <div className="center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    }
    return (
      <div className="content">
        <div className="summaries">
          <SummaryItem
            label="損益合計"
            value={
              <PriceView price={summary.formatedProfitOrLoss} showIcon={true} />
            }
            subContents={[
              {label: "総利益", value: <PriceView price={summary.formatedTotalProfit} />},
              {label: "総損失", value: <PriceView price={summary.formatedTotalLoss} /> }
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
              {label: "最大損失", value: <PriceView price={summary.formatedMaxLoss} />  },
              {label: "平均損失", value: <PriceView price={summary.formatedAvgLoss} />  }
            ]} />
        </div>
        <div className="charts">
          <CircleGraph
            title="通貨ペア"
            data={summary.pairData}
            size={this.props.graphSize} />
          <CircleGraph
            title="売/買"
            data={summary.sellOrBuyData}
            size={this.props.graphSize} />
          <CircleGraph
            title="エージェント"
            data={summary.agentsData}
            size={this.props.graphSize} />
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
  model: React.PropTypes.object,
  graphSize:  React.PropTypes.number
};
TradingSummaryView.defaultProps = {
  model: null,
  graphSize: 200
};
