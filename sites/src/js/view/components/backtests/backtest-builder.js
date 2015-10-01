import React              from "react"
import MUI                from "material-ui"
import AbstractComponent  from "../widgets/abstract-component"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import AgentSettingEditor from "../agents/agent-setting-editor"
import RangeSelector      from "../widgets/range-selector"
import PairSelector       from "../widgets/pair-selector"
import LoadingImage       from "../widgets/loading-image"

const TextField    = MUI.TextField;
const RaisedButton = MUI.RaisedButton;

const keys = new Set([
  "name", "memo", "balance",
  "nameError", "memoError", "balanceError"
]);

export default class BacktestBuilder extends AbstractComponent {

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
      return <div className="backtest-builder center-information">
        <LoadingImage left={-20}/>
      </div>;
    }
    return (
      <div className="backtest-builder">
        <div className="top-button">
          <RaisedButton
            label="バックテストを開始"
            onClick={this.registerBacktest.bind(this)}
          />
        </div>
        <div className="inputs">
          <div className="item">
            <TextField
              ref="name"
              floatingLabelText="バックテストの名前"
              defaultValue={this.state.name}
              errorText={this.state.nameError}/>
          </div>
          <div className="item">
            <RangeSelector
              ref="rangeSelector"
              model={this.model().rangeSelectorModel} />
          </div>
          <div className="item">
            <TextField
              ref="balance"
              floatingLabelText="初期資金"
              defaultValue={this.state.balance}
              errorText={this.state.balanceError} />
          </div>
          <div className="item">
            <PairSelector
              ref="pairSelector"
              model={this.model().pairSelectorModel} />
          </div>
          <div className="item">
            <TextField
              ref="memo"
              multiLine={true}
              floatingLabelText="メモ"
              defaultValue={this.state.memo}
              errorText={this.state.memoError} />
          </div>
          <div className="item">
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
    this.refs.rangeSelector.applySetting();
    this.refs.pairSelector.applySetting();

    const builder = this.model();
    builder.name = this.refs.name.getValue();
    builder.memo = this.refs.memo.getValue();
    builder.balance   = this.refs.balance.getValue();

    if (!builder.validate()) return;

    builder.build().then(
      (test) => this.context.router.transitionTo("/backtests/list/" + test.id)
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
