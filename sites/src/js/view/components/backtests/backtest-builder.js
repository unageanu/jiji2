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
  "nameError", "memoError", "balanceError",
  "isSaving"
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
            label="以下の設定でバックテストを開始"
            primary={true}
            disabled={this.state.isSaving}
            onClick={this.registerBacktest.bind(this)}
          />
          <span className="loading">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
        <div className="inputs table">
          <div className="item">
            <div className="label">バックテスト名</div>
            <div className="input">
              <TextField
                ref="name"
                hintText="バックテストの名前"
                defaultValue={this.state.name}
                errorText={this.state.nameError}/>
            </div>
          </div>
          <div className="item">
            <div className="label">テスト期間</div>
            <div className="input">
              <RangeSelector
                ref="rangeSelector"
                model={this.model().rangeSelectorModel} />
            </div>
          </div>
          <div className="item">
            <div className="label">初期資金</div>
            <div className="input">
              <TextField
                ref="balance"
                hintText="初期資金"
                defaultValue={this.state.balance}
                errorText={this.state.balanceError} />
            </div>
          </div>
          <div className="item">
            <div className="label">メモ</div>
            <div className="input">
              <TextField
                ref="memo"
                multiLine={true}
                hintText="メモ"
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
            <div className="label">使用する通貨ペア</div>
            <ul className="desc">
              <li>バックテストで使用する通貨ペアを選択してください。</li>
              <li>通貨ペアは最大5つまで選択できます。</li>
              <li>利用する通貨ペアが増えると、バックテストの所要時間も増加しますのでご注意ください。</li>
            </ul>
            <PairSelector
              ref="pairSelector"
              model={this.model().pairSelectorModel} />
          </div>
          <div className="item horizontal">
            <div className="label">エージェント</div>
            <ul className="desc">
              <li>バックテストで動作させるエージェントを設定します。</li>
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
BacktestBuilder.contextTypes = {
  router: React.PropTypes.func
};
