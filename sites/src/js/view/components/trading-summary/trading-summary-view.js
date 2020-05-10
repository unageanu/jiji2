import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';
import { Router }                       from 'react-router'

import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"
import SummaryItem       from "./summary-item"
import CircleGraph       from "./circle-graph"
import LoadingImage      from "../widgets/loading-image"
import PriceView         from "../widgets/price-view"

import DropDownMenu from "material-ui/DropDownMenu"
import MenuItem     from 'material-ui/MenuItem'

const keys = new Set([
  "summary", "enablePeriodSelector", "availableAggregationPeriods"
]);

export class TradingSummaryView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      summary :              null,
      enablePeriodSelector : false,
      availableAggregationPeriods: [],
      selected:         0
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    state.selected = state.availableAggregationPeriods[0].id;
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
    const { formatMessage } = this.props.intl;
    return (
      <div className="content">
        <div className="summaries">
          <SummaryItem
            label={formatMessage({ id: 'tradingSummary.TradingSummaryView.totalProfitOrLoss' })}
            value={
              <PriceView price={summary.formattedProfitOrLoss} showIcon={true} />
            }
            subContents={[
              {label: formatMessage({ id: 'tradingSummary.TradingSummaryView.totalProfit' }), value: <PriceView price={summary.formattedTotalProfit} />},
              {label: formatMessage({ id: 'tradingSummary.TradingSummaryView.totalLoss' }),   value: <PriceView price={summary.formattedTotalLoss} /> }
            ]} />
          <SummaryItem
            label={formatMessage({ id: 'tradingSummary.TradingSummaryView.winPercentage' })}
            value={summary.formattedWinPercentage}
            subContents={[
              {label: formatMessage({ id: 'common.win' }),  value: summary.winsAndLosses.win },
              {label: formatMessage({ id: 'common.lose' }), value: summary.winsAndLosses.lose }
            ]} />
          <SummaryItem
            label={formatMessage({ id: 'tradingSummary.TradingSummaryView.positionCount' })}
            value={summary.formattedPositionCount}
            subContents={[
              {label: formatMessage({ id: 'tradingSummary.TradingSummaryView.closedPositionCount' }),   value: summary.formattedExitedPositionCount }
            ]} />
          <SummaryItem
            label={formatMessage({ id: 'tradingSummary.TradingSummaryView.profitFactor' })}
            value={summary.formattedProfitFactor}
            subContents={[
              {label: formatMessage({ id: 'tradingSummary.TradingSummaryView.maxLoss' }), value: <PriceView price={summary.formattedMaxLoss} />  },
              {label: formatMessage({ id: 'tradingSummary.TradingSummaryView.avgLoss' }), value: <PriceView price={summary.formattedAvgLoss} />  }
            ]} />
        </div>
        <div className="charts">
          <CircleGraph
            title={formatMessage({ id: 'tradingSummary.TradingSummaryView.pair' })}
            data={summary.pairData}
            size={this.props.graphSize} />
          <CircleGraph
            title={formatMessage({ id: 'tradingSummary.TradingSummaryView.sellOrBuy' })}
            data={summary.getSellOrBuyData(formatMessage)}
            size={this.props.graphSize} />
          <CircleGraph
            title={formatMessage({ id: 'tradingSummary.TradingSummaryView.agent' })}
            data={summary.getAgentsData(formatMessage)}
            size={this.props.graphSize} />
        </div>
        <div className="data">
          <div className="item">
            <div className="title"><FormattedMessage id='tradingSummary.TradingSummaryView.holdTime'/></div>
            <div className="details">
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.longest'/></div>
                <div className="value">
                  {summary.getFormattedMaxPeriod(formatMessage)}
                </div>
              </div>
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.shortest'/></div>
                <div className="value">
                  {summary.getFormattedMinPeriod(formatMessage)}
                </div>
              </div>
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.avg'/></div>
                <div className="value">
                  {summary.getFormattedAvgPeriod(formatMessage)}
                </div>
              </div>
            </div>
          </div>
          <div className="item">
            <div className="title"><FormattedMessage id='tradingSummary.TradingSummaryView.volume'/></div>
            <div className="details">
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.max'/></div>
                <div className="value">
                  {summary.formattedMaxUnits}
                </div>
              </div>
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.min'/></div>
                <div className="value">
                  {summary.formattedMinUnits}
                </div>
              </div>
              <div className="item">
                <div className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.avg'/></div>
                <div className="value">
                  {summary.formattedAvgUnits}
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
        <span className="label"><FormattedMessage id='tradingSummary.TradingSummaryView.term'/>: </span>
        <span className="selector">
          <DropDownMenu
            value={this.state.selected}
            onChange={this.onChange.bind(this)}>
            {this.createDropDownMenuItems()}
          </DropDownMenu>
        </span>
      </div>
    );
  }

  createDropDownMenuItems() {
    const { formatMessage } = this.props.intl;
    return this.state.availableAggregationPeriods.map((item) => {
      return <MenuItem key={item.id}
        value={item.id} primaryText={formatMessage({id: item.labelId})} />
    });
  }

  onChange(e, selectedIndex, payload) {
    this.props.model.startTime = this.state.availableAggregationPeriods
      .find((item)=> item.id == payload).time;
    this.setState({selected:payload});
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
export default injectIntl(TradingSummaryView)
