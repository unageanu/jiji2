import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import AgentSettingEditor from "../widgets/agent-setting-editor"

const TextField    = MUI.TextField;
const DatePicker   = MUI.DatePicker;
const Checkbox     = MUI.Checkbox;
const DropDownMenu = MUI.DropDownMenu;
const RaisedButton = MUI.RaisedButton;

export default class NewBacktestPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      name :           "",
      memo :           "",
      startTime:       null,
      endTime:         null,
      minDate:         new Date(),
      maxDate:         new Date(),
      balance:         1000000,
      availablePairs:  []
    };
  }

  componentWillMount() {
    const builder = this.backtestBuilder();
    this.model().initialize().then(() => {
      this.setState({
        startTime:       builder.startTime,
        endTime:         builder.endTime,
        minDate:         builder.minDate,
        maxDate:         builder.maxDate,
        balance:         builder.balance,
        availablePairs:  builder.availablePairs
      });
    });
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  render() {
    const pairSelector  = this.createPairSelector();
    return (
      <div className="new-backtest">
        <h1>バックテストの新規作成</h1>
        <div>
          <RaisedButton
            label="バックテストを開始"
            onClick={this.registerBscktest.bind(this)}
          />
          <br/>
          <TextField
            ref="name"
            floatingLabelText="バックテストの名前"
            defaultValue={this.state.name}
          />
          <br/>
          <DatePicker
            ref="startTime"
            formatDate={DateFormatter.formatDateYYYYMMDD}
            hintText="開始"
            minDate={this.state.minDate}
            maxDate={this.state.maxDate}
            defaultDate={this.state.startTime}
            showYearSelector={true}
            style={{
              display: "inline-block"
            }} />
          ～
          <DatePicker
            ref="endTime"
            formatDate={DateFormatter.formatDateYYYYMMDD}
            hintText="終了"
            minDate={this.state.minDate}
            maxDate={this.state.maxDate}
            defaultDate={this.state.endTime}
            showYearSelector={true}
            style={{
              display: "inline-block"
            }} />
          <br/>
          <TextField
            ref="balance"
            floatingLabelText="初期資金"
            defaultValue={this.state.balance}
          /><br/>
          <div className="pair-selector">
            {pairSelector}
          </div>
          <TextField
            ref="memo"
            multiLine={true}
            floatingLabelText="メモ"
            defaultValue={this.state.memo} />

          <AgentSettingEditor
            ref="agentSettingEditor"
            model={this.backtestBuilder().agentSettingBuilder}/>

        </div>
      </div>
    );
  }

  createPairSelector() {
    return this.state.availablePairs.map((pair) => {
      return <Checkbox
        ref={pair.name}
        key={pair.name}
        name={pair.name}
        value={pair.name}
        label={pair.name}
        style={{
          width:   "180px",
          display: "inline-block"
        }} />;
    });
  }

  registerBscktest() {
    this.refs.agentSettingEditor.applyAgentConfiguration();

    const builder = this.backtestBuilder();
    builder.name = this.refs.name.getValue();
    builder.memo = this.refs.memo.getValue();
    builder.startTime = this.refs.startTime.getDate();
    builder.endTime   = this.refs.endTime.getDate();
    builder.pairNames = this.getCheckedPairNames();
    builder.balance   = Number.parseInt(this.refs.balance.getValue(), 10);
    builder.build().then(
      (test) => this.context.router.transitionTo("/backtests/list/" + test.id)
    );
  }

  getCheckedPairNames() {
    return this.state.availablePairs
      .filter((pair) => this.refs[pair.name].isChecked())
      .map((pair) => pair.name );
  }

  backtestBuilder() {
    return this.model().backtestBuilder;
  }
  model() {
    return this.context.application.newBacktestPageModel;
  }
}
NewBacktestPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
