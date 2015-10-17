import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import Validators          from "../../utils/validation/validators"
import AgentSettingBuilder from "../agents/agent-setting-builder"
import _                   from "underscore"
import Deferred            from "../../utils/deferred"
import RangeSelectorModel  from "../widgets/range-selector-model"
import PairSelectorModel   from "../widgets/pair-selector-model"
import ValidationUtils     from "../utils/validation-utils"

export default class BacktestBuilder extends Observable {

  constructor() {
    super();

    this.timeSource      = ContainerJS.Inject;
    this.agentClasses    = ContainerJS.Inject;
    this.backtestService = ContainerJS.Inject;
    this.backtests       = ContainerJS.Inject;
    this.rates           = ContainerJS.Inject;
    this.pairs           = ContainerJS.Inject;
    this.icons           = ContainerJS.Inject;

    this.rangeSelectorModel = new RangeSelectorModel(
      Validators.backtest.startTime,
      Validators.backtest.endTime
    );
    this.pairSelectorModel = new PairSelectorModel(
      Validators.backtest.pairNames);
  }

  initialize(agents=[]) {
    this.agentSettingBuilder = new AgentSettingBuilder(
      this.agentClasses, this.icons, Validators.backtest.agentSetting);
    this.initializeBuilderState();
    return Deferred.when([
      this.agentSettingBuilder.initialize(agents),
      this.pairs.initialize(),
      this.rates.initialize()
    ]).then((results) => {
      this.rangeSelectorModel.initialize(
        this.rates.range.start, this.rates.range.end,
        this.backtest.startTime, this.backtest.endTime);
      this.pairSelectorModel.initialize(this.pairs.pairs);
    });
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
    const backtest = _.defaults(
      {agentSetting: this.agentSettingBuilder.agentSetting}, this.backtest);
    backtest.startTime = this.rangeSelectorModel.startTime;
    backtest.endTime   = this.rangeSelectorModel.endTime;
    backtest.pairNames = this.pairSelectorModel.pairNames;
    backtest.balance   = Number.parseInt(backtest.balance, 10)

    this.isSaving = true;
    const d = this.backtests.register(backtest)
    d.always(() => this.isSaving = false );
    return d;
  }

  getAgentClassForSelected() {
    return this.agentSettingBuilder.getAgentClassForSelected();
  }

  addAgent( agentClass, configuration={} ) {
    return this.agentSettingBuilder.addAgent( agentClass, configuration );
  }
  removeSelectedAgent( ) {
    return this.agentSettingBuilder.removeSelectedAgent();
  }
  updateSelectedAgent(name, iconId, configuration) {
    this.agentSettingBuilder.updateSelectedAgent(
      name, iconId, configuration);
  }

  validate() {
    return Validators.all(
      ValidationUtils.validate(Validators.backtest.name, this.name,
        {field: "テスト名"}, (error) => this.nameError = error ),
      ValidationUtils.validate(Validators.backtest.memo, this.memo,
        {field: "メモ"}, (error) => this.memoError = error ),
      ValidationUtils.validate(Validators.backtest.balance, this.balance,
        {field: "初期資金"}, (error) => this.balanceError = error ),
      this.agentSettingBuilder.validate(),
      this.pairSelectorModel.validate(),
      this.rangeSelectorModel.validate()
    );
  }

  get name() {
    return this.backtest.name;
  }
  set name(name) {
    this.backtest.name = name;
  }
  get nameError() {
    return this.getProperty("nameError");
  }
  set nameError(error) {
    this.setProperty("nameError", error);
  }

  get memo() {
    return this.backtest.memo;
  }
  set memo(memo) {
    this.backtest.memo = memo;
  }
  get memoError() {
    return this.getProperty("memoError");
  }
  set memoError(error) {
    this.setProperty("memoError", error);
  }

  get balance() {
    return this.backtest.balance;
  }
  set balance(balance) {
    this.backtest.balance = balance;
  }
  get balanceError() {
    return this.getProperty("balanceError");
  }
  set balanceError(error) {
    this.setProperty("balanceError", error);
  }

  get agentSetting() {
    return this.agentSettingBuilder.agentSetting;
  }

  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
  get isSaving() {
    return this.getProperty("isSaving");
  }
}
