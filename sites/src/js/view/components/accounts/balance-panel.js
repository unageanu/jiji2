import React             from "react"
import TrendIcon         from "../widgets/trend-icon"
import AbstractComponent from "../widgets/abstract-component"
import LoadingImage      from "../widgets/loading-image"

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
        <div className="title">
          <span className="icon md-account-balance"></span>
          口座残高
        </div>
        {this.createContent()}
      </div>
    );
  }

  createContent() {
    if (!this.state.formatedBalance) {
      return <div className="center-information"><LoadingImage left={-20} /></div>;
    }
    return [
      <div key="balance" className="balance">￥{this.state.formatedBalance}</div>,
      <div key="changes-from-previous-day" className="changes-from-previous-day">
        {this.createPriceAndRatio()}
        <TrendIcon value={this.state.changesFromPreviousDay} />
      </div>
    ];
  }

  createPriceAndRatio() {
    let result = "前日比: ￥";
    result += this.state.formatedChangesFromPreviousDay || " - ";
    result += " ( " + (this.state.formatedChangeRatioFromPreviousDay || "-%") + " )";
    return result;
  }
}
BalancePanel.propTypes = {
  model: React.PropTypes.object.isRequired,
  visibleTradingSummary: React.PropTypes.bool
};
