import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Validators   from "../../utils/validation/validators"

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
    this.initializeBuilderState(agents);
    return Deferred.when([
      this.pairs.initialize(),
      this.rates.initialize(),
      this.agentClasses.load()
    ]);
  }

  initializeBuilderState(agents) {
    const now        = this.timeSource.now;
    const oneWeekAgo = new Date(now.getTime() - (1000 * 60 * 60 * 24 * 7));
    const startTime  = this.truncate(oneWeekAgo);
    const endTime    = this.truncate(now);

    this.backtest = {
      agentSetting: agents,
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
    return this.backtestService.register(this.backtest);
  }

  getAgentClass(index) {
    const agentSetting = this.backtest.agentSetting[index];
    return this.agentClasses.classes.find((a) => a.name === agentSetting.name );
  }

  addAgent( agentClass, configuration={} ) {
    this.backtest.agentSetting.push({
      name:       agentClass,
      properties: configuration
    });
    this.fire("agentAdded", {agents:this.backtest.agentSetting});
    return this.backtest.agentSetting.length -1;
  }
  removeAgent( index ) {
    this.backtest.agentSetting.splice(index, 1);
    this.fire("agentRemoved", {agents:this.backtest.agentSetting});
  }
  updateAgentConfiguration(index, configuration) {
    this.backtest.agentSetting[index].properties = configuration;
  }

  validateAllProperties() {
    for( let i in this.backtest ) {
      Validators.backtest[i].validate(this.backtest[i]);
    }
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
    return this.backtest.agentSetting;
  }
}
