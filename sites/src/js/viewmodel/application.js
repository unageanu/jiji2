import ContainerJS  from "container-js"
import Deferred     from "../utils/deferred"

export default class Application {

  constructor() {
    this.navigator         = ContainerJS.Inject;
    this.viewModelFactory  = ContainerJS.Inject;
    this.authenticator     = ContainerJS.Inject;
    this.agentSourceEditor = ContainerJS.Inject;

    this.pairs        = ContainerJS.Inject;
    this.rates        = ContainerJS.Inject;
    this.preferences  = ContainerJS.Inject;

    this.backtests       = ContainerJS.Inject;
    this.backtestBuilder = ContainerJS.Inject;

    this.homePageModel              = ContainerJS.Inject;
    this.rmtTradingSummaryPageModel = ContainerJS.Inject;
    this.rmtChartPageModel          = ContainerJS.Inject;
    this.rmtPositionsPageModel      = ContainerJS.Inject;
    this.rmtAgentSettingPageModel   = ContainerJS.Inject;

    this.newBacktestPageModel       = ContainerJS.Inject;
    this.backtestsPageModel         = ContainerJS.Inject;
  }

  initialize() {
    if ( !this.initializationDeferred ) {
      this.initializationDeferred = Deferred.when([
        this.pairs.initialize()
      ]);
    }
    return this.initializationDeferred;
  }
}
