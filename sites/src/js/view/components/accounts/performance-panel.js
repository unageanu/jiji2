import React             from "react"
import TrendIcon         from "../widgets/trend-icon"
import AbstractComponent from "../widgets/abstract-component"

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
        <div className="title">直近1週間の成績</div>
        <div className="item first">
          <span className="label">勝率</span>
          <span className="value winning-percentage">{summary.formatedWinPercentage}</span>
        </div>
        <div className="item">
          <span className="label">損益</span>
          <span className="value">¥{summary.formatedProfitOrLoss}</span>
          <TrendIcon value={summary.profitOrLoss.totalProfitOrLoss} />
        </div>
        <div className="item">
          <span className="label">Profit Factor</span>
          <span className="value">{summary.formatedProfitFactor}</span>
        </div>
      </div>
    );
  }
}
PerformancePanel.propTypes = {
  model: React.PropTypes.object.isRequired
};
