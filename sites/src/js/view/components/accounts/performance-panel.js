import React                from "react"
import { FormattedMessage } from 'react-intl';

import AbstractComponent from "../widgets/abstract-component"
import PriceView         from "../widgets/price-view"

const keys = new Set(["summary"]);

export default class PerformancePanel extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const summary = this.state.summary || {profitOrLoss:{totalProfitOrLoss:null}};
    return (
      <div className="performance panel">
        <div className="title"><FormattedMessage id="accounts.PerformancePanel.title" /></div>
        <div className="item first">
          <span className="label"><FormattedMessage id="accounts.PerformancePanel.winningPercentage" /></span>
          <span className="value winning-percentage">{summary.formattedWinPercentage}</span>
        </div>
        <div className="item">
          <span className="label"><FormattedMessage id="accounts.PerformancePanel.profitOrLoss" /></span>
          <span className="value">
            <PriceView price={summary.formattedProfitOrLoss}
              showIcon={true} />
          </span>
        </div>
        <div className="item">
          <span className="label">Profit Factor</span>
          <span className="value">{summary.formattedProfitFactor}</span>
        </div>
      </div>
    );
  }
}
PerformancePanel.propTypes = {
  model: React.PropTypes.object.isRequired
};
