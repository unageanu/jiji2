import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import Deferred            from "../../utils/deferred"
import Validators          from "../../utils/validation/validators"
import AgentSettingBuilder from "./agent-setting-builder"
import _                   from "underscore"

export default class BacktestBuilder extends Observable {

  constructor() {
    super();

    this.timeSource      = ContainerJS.Inject;
    this.agentClasses    = ContainerJS.Inject;
    this.rates           = ContainerJS.Inject;
    this.pairs           = ContainerJS.Inject;
    this.backtestService = ContainerJS.Inject;
  }

  initialize(agents=[]) {
    this.agentSettingBuilder = new AgentSettingBuilder(this.agentClasses);
    this.initializeBuilderState();
    return Deferred.when([
      this.pairs.initialize(),
      this.rates.initialize(),
      this.agentSettingBuilder.initialize(agents)
    ]);
  }

  initializeBuilderState() {
    const now        = this.timeSource.now;
    const oneWeekAgo = new Date(now.getTime() - (1000 * 60 * 60 * 24 * 7));
    const startTime  = this.truncate(oneWeekAgo);
    const endTime    = this.truncate(now);

    this.backtest = {
      pairNames:     [],
      balance:       1000000,
      name:          "",
      memo:          "",
      startTime:     startTime,
      endTime:       endTime
    };
  }

  truncate(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  build() {
    this.validateAllProperties();
    const backtest = _.defaults(this.backtest,
      {agentSetting: this.agentSettingBuilder.toArray()});
    return this.backtestService.register(backtest);
  }

  getAgentClass(index) {
    return this.agentSettingBuilder.getAgentClass(index);
  }

  addAgent( agentClass, configuration={} ) {
    return this.agentSettingBuilder.addAgent( agentClass, configuration );
  }
  removeAgent( index ) {
    return this.agentSettingBuilder.removeAgent( index );
  }
  updateAgentConfiguration(index, name, configuration) {
    this.agentSettingBuilder.updateAgentConfiguration(
      index, name, configuration);
  }

  validateAllProperties() {
    for( let i in this.backtest ) {
      Validators.backtest[i].validate(this.backtest[i]);
    }
    Validators.backtest.agentSetting.validate(this.agentSetting);
  }

  get name() {
    return this.backtest.name;
  }
  set name(name) {
    Validators.backtest.name.validate(name);
    this.backtest.name = name;
  }
  get memo() {
    return this.backtest.memo;
  }
  set memo(memo) {
    Validators.backtest.memo.validate(memo);
    this.backtest.memo = memo;
  }
  get pairNames() {
    return this.backtest.pairNames;
  }
  set pairNames(pairNames) {
    Validators.backtest.pairNames.validate(pairNames);
    this.backtest.pairNames = pairNames;
  }
  get startTime() {
    return this.backtest.startTime;
  }
  set startTime(startTime) {
    Validators.backtest.startTime.validate(startTime);
    this.backtest.startTime = startTime;
  }
  get endTime() {
    return this.backtest.endTime;
  }
  set endTime(endTime) {
    Validators.backtest.endTime.validate(endTime);
    this.backtest.endTime = endTime;
  }
  get balance() {
    return this.backtest.balance;
  }
  set balance(balance) {
    Validators.backtest.balance.validate(balance);
    this.backtest.balance = balance;
  }
  get agentSetting() {
    return this.agentSettingBuilder.toArray();
  }
}
