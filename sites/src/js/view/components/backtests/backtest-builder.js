import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent    from "../widgets/abstract-component"
import DateFormatter        from "../../../viewmodel/utils/date-formatter"
import AgentSettingEditor   from "../agents/agent-setting-editor"
import RangeSelector        from "../widgets/range-selector"
import PairSelector         from "../widgets/pair-selector"
import LoadingImage         from "../widgets/loading-image"
import TickIntervalSelector from "./tick-interval-selector"

import TextField from "material-ui/TextField"
import RaisedButton from "material-ui/RaisedButton"

const keys = new Set([
  "name", "memo", "balance",
  "nameError", "memoError", "balanceError",
  "isSaving"
]);

class BacktestBuilder extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      loading: true
    };
  }

  componentWillMount() {
    this.model().initialize().then(() => {
      this.registerPropertyChangeListener(this.model(), keys);
      const state = this.collectInitialState(this.model(), keys);
      state.loading = false;
      this.setState(state);
    });
  }

  render() {
    if (this.state.loading) {
      return <div className="backtest-builder center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    }
    const { formatMessage } = this.props.intl;
    return (
      <div className="backtest-builder">
        <div className="top-button">
          <RaisedButton
            label={formatMessage({ id: 'backtests.BacktestBuilder.button' })}
            primary={true}
            disabled={this.state.isSaving}
            onClick={this.registerBacktest.bind(this)}
            style={{width:"300px"}}
          />
          <span className="loading-for-button-action">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
        <div className="inputs table">
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.name' /></div>
            <div className="input">
              <TextField
                ref="name"
                hintText={formatMessage({ id: 'backtests.BacktestBuilder.nameHint' })}
                defaultValue={this.state.name}
                errorText={this.state.nameError}/>
            </div>
          </div>
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.range' /></div>
            <div className="input">
              <RangeSelector
                ref="rangeSelector"
                model={this.model().rangeSelectorModel} />
            </div>
          </div>
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.balance' /></div>
            <div className="input">
              <TextField
                ref="balance"
                hintText={formatMessage({ id: 'backtests.BacktestBuilder.balance' })}
                defaultValue={this.state.balance}
                errorText={this.state.balanceError} />
            </div>
          </div>
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.tickInterval' /></div>
            <div className="input">
              <TickIntervalSelector
                model={this.model()} />
              <ul className="desc">
                <li><FormattedMessage id='backtests.BacktestBuilder.tickIntervalDescription.part1' /> <code>next_tick(tick)</code> <FormattedMessage id='backtests.BacktestBuilder.tickIntervalDescription.part2' /></li>
                <li><FormattedMessage id='backtests.BacktestBuilder.tickIntervalDescription.part3' /></li>
              </ul>
            </div>
          </div>
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.memo' /></div>
            <div className="input">
              <TextField
                ref="memo"
                multiLine={true}
                hintText={formatMessage({ id: 'backtests.BacktestBuilder.memo' })}
                defaultValue={this.state.memo}
                errorText={this.state.memoError}
                style={{
                  width: "600px"
                }} />
            </div>
          </div>
        </div>
        <div  className="inputs">
          <div className="item">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.pairs' /></div>
            <ul className="desc">
              <li><FormattedMessage id='backtests.BacktestBuilder.pairsDescription.part1' /></li>
              <li><FormattedMessage id='backtests.BacktestBuilder.pairsDescription.part2' /></li>
              <li><FormattedMessage id='backtests.BacktestBuilder.pairsDescription.part3' /></li>
            </ul>
            <PairSelector
              ref="pairSelector"
              model={this.model().pairSelectorModel} />
          </div>
          <div className="item horizontal">
            <div className="label"><FormattedMessage id='backtests.BacktestBuilder.agent' /></div>
            <ul className="desc">
              <li><FormattedMessage id='backtests.BacktestBuilder.agentDescription' /></li>
            </ul>
            <AgentSettingEditor
              ref="agentSettingEditor"
              model={this.model().agentSettingBuilder}/>
          </div>
        </div>
      </div>
    );
  }

  registerBacktest() {
    this.refs.agentSettingEditor.applyAgentConfiguration();
    this.refs.rangeSelector.getWrappedInstance().applySetting();

    const builder = this.model();
    builder.name = this.refs.name.getValue();
    builder.memo = this.refs.memo.getValue();
    builder.balance   = this.refs.balance.getValue();

    if (!builder.validate(this.props.intl.formatMessage)) return;

    builder.build().then(
      (test) => this.context.router.push({
        pathname:"/backtests/list/" + test.id
      })
    );
  }

  model() {
    return this.props.model;
  }
}
BacktestBuilder.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestBuilder.defaultProps = {
};
BacktestBuilder.contextTypes = {
  router: React.PropTypes.object
};

export default injectIntl(BacktestBuilder);
