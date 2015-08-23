import React             from "react"
import TrendIcon         from "../widgets/trend-icon"
import AbstractComponent from "../widgets/abstract-component"

const keys = new Set([
  "formatedBalance", "formatedChangesFromPreviousDay",
  "formatedChangeRatioFromPreviousDay", "changesFromPreviousDay"
]);

export default class BalancePanel extends AbstractComponent {

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
    const style = this.props.visibleTradingSummary
      ? { width: "calc(67% - 32px)"} : { width: "100%" };
    return (
      <div key="balance panel" className="balance panel" style={style}>
        <div className="title">口座残高</div>
        <div key="balance" className="balance">￥{this.state.formatedBalance}</div>
        <div key="changes-from-previous-day" className="changes-from-previous-day">
          <span className="label">前日比:</span>
          <span className="price">￥{this.state.formatedChangesFromPreviousDay}</span>
          <span className="ratio">( {this.state.formatedChangeRatioFromPreviousDay} )</span>
          <TrendIcon value={this.state.changesFromPreviousDay} />
        </div>
      </div>
    );
  }
}
BalancePanel.propTypes = {
  model: React.PropTypes.object.isRequired,
  visibleTradingSummary: React.PropTypes.bool
};
