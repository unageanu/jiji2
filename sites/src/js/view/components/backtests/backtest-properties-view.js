import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import NumberFormatter     from "../../../viewmodel/utils/number-formatter"
import DateFormatter       from "../../../viewmodel/utils/date-formatter"
import Utils               from "./utils"
import AgentSettingEditor  from "../agents/agent-setting-editor"
import ConfirmDialog       from "../widgets/confirm-dialog"
import ButtonIcon          from "../widgets/button-icon"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;

const keys = new Set([
  "selectedBacktest"
]);

export default class BacktestPropertiesView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      deleting: false
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    const loading = this.state.deleting
      ? <span className="loading-for-button-action">
          <LoadingImage size={20} left={-20} top={4} />
        </span>
      : null;
    return <div className="backtest-properties-view">
      <div className="buttons">
        <RaisedButton
          label="バックテストを削除..."
          labelStyle={{padding:"0px 16px 0px 8px"}}
          disabled={this.state.deleting}
          onClick={this.delete.bind(this)}>
          <ButtonIcon className="md-delete" />
        </RaisedButton>
        {loading}
      </div>
      <div className="items">
        {this.createItems()}
        <div className="item agent-settings">
          <div className="label">エージェント</div>
          <div>
            <AgentSettingEditor
              model={this.props.model.agentSettingBuilder}
              readOnly={true} />
          </div>
        </div>
      </div>
      <ConfirmDialog
        ref="confirmDialog"
        text="バックテストを削除します。よろしいですか? " />
    </div>;
  }

  createItems() {
    const backtest = this.state.selectedBacktest;
    return [
      this.createItem("名前",    backtest.name, "name"),
      this.createItem("登録日時", backtest.formatedCreatedAt, "created-at"),
      this.createItem("状態",    this.createStatusContent(backtest), "status"),
      this.createItem("期間",    backtest.formatedPeriod, "period"),
      this.createItem("初期資金", "￥ " + backtest.formatedBalance, "balance"),
      this.createItem("通貨ペア", backtest.pairNames.join(" "), "pairs"),
      this.createItem("メモ",    <pre>{backtest.memo}</pre>, "memo")
    ];
  }

  createItem(label, value, key) {
    return <div key={key} className={"item " + key}>
      <div className="label">{label}</div>
      <div className="value">{value}</div>
    </div>;
  }

  createStatusContent(backtest) {
    switch(backtest.status) {
      case "error" :
        return <span className="error">
          <span className={"icon md-warning"} /> エラー (詳細はログを確認してください)
        </span>;
      default :
        return Utils.createStatusContent(backtest);
    }
  }

  delete(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({deleting:true});
      this.props.model.remove(backtest.id).fail(
        () => this.setState({deleting:false}) );
    });
  }
}
BacktestPropertiesView.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestPropertiesView.defaultProps = {};
