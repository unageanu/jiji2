import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';
import TrendIcon                        from "../widgets/trend-icon"
import AbstractComponent                from "../widgets/abstract-component"
import LoadingImage                     from "../widgets/loading-image"

const keys = new Set([
  "formattedBalance", "formattedChangesFromPreviousDay",
  "formattedChangeRatioFromPreviousDay", "changesFromPreviousDay"
]);

class BalancePanel extends AbstractComponent {

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
          <span className="text"><FormattedMessage id="accounts.BalancePanel.title" /></span>
        </div>
        {this.createContent()}
      </div>
    );
  }

  createContent() {
    if (!this.state.formattedBalance) {
      return <div className="center-information loading">
        <LoadingImage left={-20} />
      </div>;
    }
    return [
      <div key="balance" className="balance">¥{this.state.formattedBalance}</div>,
      <div key="changes-from-previous-day" className="changes-from-previous-day">
        {this.createPriceAndRatio()}
        <TrendIcon value={this.state.changesFromPreviousDay} />
      </div>
    ];
  }

  createPriceAndRatio() {
    const { formatMessage } = this.props.intl;
    let result = `${formatMessage({ id: 'accounts.BalancePanel.dayBeforeRatio' })}: ${formatMessage({ id: 'common.currencyUnit' })}`;
    result += this.state.formattedChangesFromPreviousDay || " - ";
    result += " ( " + (this.state.formattedChangeRatioFromPreviousDay || "-%") + " )";
    return result;
  }
}
BalancePanel.propTypes = {
  model: React.PropTypes.object.isRequired,
  visibleTradingSummary: React.PropTypes.bool
};

export default injectIntl(BalancePanel);
