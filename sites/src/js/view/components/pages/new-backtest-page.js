import React              from "react"
import MUI                from "material-ui"
import AbstractPage       from "./abstract-page"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import AgentClassSelector from "../backtests/agent-class-selector"

const TextField    = MUI.TextField;
const DatePicker   = MUI.DatePicker;
const Checkbox     = MUI.Checkbox;
const DropDownMenu = MUI.DropDownMenu;
const RaisedButton = MUI.RaisedButton;
const List         = MUI.List;
const ListItem     = MUI.ListItem;
const Dialog       = MUI.Dialog;

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
      availablePairs:  [],
      availableAgents: [],
      agents:          []
    };
  }

  componentWillMount() {
    this.registerObservers();
    this.initializeModel();
  }
  componentWillUnmount() {
    this.unregisterObservers();
  }

  render() {
    const pairSelector  = this.createPairSelector();
    const agents        = this.createAgents();
    const dialogActions=[
      { text: "Cancel", onTouchTap: () => this.refs.agentSelectorDialog.dismiss() }
    ];
    const agentDetails  = this.createAgentDetail();
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

          <div className="agents">
            <RaisedButton
              label="エージェントを追加"
              onClick={this.showAgentSelector.bind(this)}
            />
            <Dialog
              ref="agentSelectorDialog"
              title=""
              actions={dialogActions}
              modal={true}
            >
            <div>
             <div>追加するエージェントを選択してください。</div>
             <AgentClassSelector
              classes={this.state.availableAgents}
              onSelect={this.addAgent.bind(this)}
              />
            </div>
            </Dialog>
          </div>
          <div>
            <div className="agent-list">
              <List>{agents}</List>
            </div>
            <div className="agent-details">
              {agentDetails}
            </div>
          </div>
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

  createAgents() {
    return this.state.agents.map((agent, index) => {
      const selected  = this.state.selectedAgentIndex === index;
      const tapAction = (ev) => {
        this.applyAgentConfiguration();
        this.setState({selectedAgentIndex:index});
      };
      return <ListItem
            key={index}
            className={selected ? "mui-selected" : ""}
            onTouchTap={tapAction}>
            {agent.name}
          </ListItem>;
    });
  }

  createAgentDetail() {
    const selectedAgent = this.getSelectedAgent();
    const agentClass    = this.getAgentClass();
    const agentPropertyEditors =
      this.createAgentPropertyEditor(selectedAgent, agentClass);
    return <div className="agent-details">
      <div>{selectedAgent ? selectedAgent.name : ""}</div>
      <div>{agentClass ? agentClass.description : ""}</div>
      <div>
        {agentPropertyEditors}
      </div>
    </div>;
  }

  createAgentPropertyEditor(selectedAgent, agentClass) {
    if (!selectedAgent || !agentClass) return null;
    return agentClass.properties.map((p) => {
      const value = selectedAgent.properties[p.id] || p.default;
      return  <TextField
          key={ this.state.selectedAgentIndex+"_"+p.id}
          ref={"agent_properties_" + p.id}
          floatingLabelText={p.name}
          defaultValue={value} />;
    });
  }

  registerBscktest() {
    this.applyAgentConfiguration();

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

  applyAgentConfiguration() {
    const selectedAgent = this.getSelectedAgent();
    const agentClass    = this.getAgentClass();
    if (!selectedAgent) return;
    const configuration = agentClass.properties.reduce((r, p) => {
      r[p.id] = this.refs["agent_properties_" + p.id].getValue();
      return r;
    }, {});
    this.backtestBuilder().updateAgentConfiguration(
      this.state.selectedAgentIndex, configuration);
  }

  getSelectedAgent() {
    if (this.state.selectedAgentIndex >= 0) {
      return this.backtestBuilder()
        .backtest.agentSetting[this.state.selectedAgentIndex];
    } else {
      return null;
    }
  }
  getAgentClass() {
    if (this.state.selectedAgentIndex >= 0) {
      return this.backtestBuilder()
        .getAgentClass(this.state.selectedAgentIndex);
    } else {
      return null;
    }
  }

  showAgentSelector() {
    this.refs.agentSelectorDialog.show();
  }

  addAgent(agent) {
    const index = this.backtestBuilder().addAgent( agent.name );
    this.refs.agentSelectorDialog.dismiss();

    this.applyAgentConfiguration();
    this.setState({selectedAgentIndex:index});
  }

  initializeModel() {
    const builder = this.backtestBuilder();
    builder.initialize().then((values) => {
      this.setState({
        startTime:       builder.startTime,
        endTime:         builder.endTime,
        minDate:         builder.rates.range.start,
        maxDate:         builder.rates.range.end,
        balance:         builder.balance,
        availablePairs:  builder.pairs.pairs,
        availableAgents: builder.agentClasses.classes
      });
    });
  }

  registerObservers() {
    const builder  = this.backtestBuilder();
    const observer = (n, ev) => this.setState({agents:ev.agents});
    ["agentAdded", "agentRemoved"].forEach(
      (e) => builder.addObserver(e, observer, this)
    );
  }
  unregisterObservers() {
    this.backtestBuilder().removeAllObservers(this);
  }

  backtestBuilder() {
    return this.context.application.backtestBuilder;
  }
}
NewBacktestPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
