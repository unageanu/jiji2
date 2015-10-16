import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import NumberFormatter     from "../../../viewmodel/utils/number-formatter"
import DateFormatter       from "../../../viewmodel/utils/date-formatter"
import Utils               from "./utils"
import AgentSettingEditor  from "../agents/agent-setting-editor"
import ConfirmDialog       from "../widgets/confirm-dialog"

const FlatButton = MUI.FlatButton;

const keys = new Set([
  "selectedBacktest"
]);

export default class BacktestPropertiesView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    return <div className="backtest-properties-view">
      <div className="buttons">
        <FlatButton
          label="削除"
          onClick={this.delete.bind(this)}
        />
      </div>
      {this.createItems()}
      <div className="item agent-settings">
        <div className="label">エージェント:</div>
        <div>
          <AgentSettingEditor
            model={this.props.model.agentSettingBuilder}
            readOnly={true} />
        </div>
      </div>
      <ConfirmDialog
        ref="confirmDialog"
        text="バックテストを削除します。よろしいですか?" />
    </div>;
  }

  createItems() {
    const backtest = this.state.selectedBacktest;
    return [
      this.createItem("名前",    backtest.name, "name"),
      this.createItem("登録日時", backtest.formatedCreatedAt, "created-at"),
      this.createItem("状態",    Utils.createStatusContent(backtest), "status"),
      this.createItem("期間",    backtest.formatedPeriod, "period"),
      this.createItem("初期資金", backtest.formatedBalance, "balance"),
      this.createItem("通貨ペア", backtest.pairNames.join(" "), "pairs"),
      this.createItem("メモ",    backtest.memo, "memo")
    ];
  }

  createItem(label, value, key) {
    return <div key={key} className={"item " + key}>
      <div className="label">{label}</div>
      <div className="value">{value}</div>
    </div>;
  }

  delete(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.props.model.remove(backtest.id);
    });
  }
}
BacktestPropertiesView.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestPropertiesView.defaultProps = {};
