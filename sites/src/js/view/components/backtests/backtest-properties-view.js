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
      executingAction: false
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    return <div className="backtest-properties-view">
      <ConfirmDialog
        key="confirmRemoveDialog" ref="confirmRemoveDialog"
        text="バックテストを削除します。よろしいですか? " />
      <ConfirmDialog
        key="confirmCancelDialog" ref="confirmCancelDialog"
        text="バックテストの実行をキャンセルします。よろしいですか? " />
      <ConfirmDialog
        key="confirmRestartDialog" ref="confirmRestartDialog"
        text="同じ設定でバックテストを再実行します。よろしいですか? " />
      {this.createButtons()}
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
    </div>;
  }

  createButtons() {
    const buttons = [];
    const backtest = this.state.selectedBacktest;

    if (backtest.enableRestart) {
      buttons.push(this.createButton("restart",
        "再実行...", "md-replay", this.restart.bind(this)));
    }
    if (backtest.enableCancel) {
      buttons.push(this.createButton("cancel",
        "キャンセル...", "md-pause", this.cancel.bind(this)));
    }
    if (backtest.enableDelete) {
      buttons.push(this.createButton("delete",
        "削除...", "md-delete", this.delete.bind(this)));
    }
    const loading = this.state.executingAction
      ? <span className="loading">
          <LoadingImage size={20} top={0} left={-16} />
        </span>
      : null;
    return <div className="buttons">
      {loading}
      {buttons}
    </div>;
  }

  createButton(key, label, icon, action) {
    return <RaisedButton
      className="button"
      key={key}
      label={label}
      labelStyle={{padding:"0px 16px 0px 8px"}}
      disabled={this.state.executingAction}
      onClick={action}>
      <ButtonIcon className={icon} />
    </RaisedButton>;
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
    this.refs.confirmRemoveDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.remove(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
  restart(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmRestartDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.restart(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
  cancel(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmCancelDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.cancel(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
}
BacktestPropertiesView.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestPropertiesView.defaultProps = {};
