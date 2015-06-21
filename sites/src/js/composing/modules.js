function model(binder) {
  binder.bind("preferences")
    .to("model.Preferences")
    .onInitialize("initialize");

  binder.bind("pairs").to("model.trading.Pairs");
  binder.bind("rates").to("model.trading.Rates");
  binder.bind("backtests").to("model.trading.backtests");

  binder.bind("agentSources").to("model.agents.AgentSources");
  binder.bind("agentClasses").to("model.agents.AgentClasses");
}

function viewModel(binder) {
  binder.bind("application").to("viewmodel.Application");
  binder.bind("navigator").to("viewmodel.Navigator");

  binder.bind("agentSourceEditor")
    .to("viewmodel.agents.AgentSourceEditor")
    .onInitialize("initialize");

  binder.bind("viewModelFactory").to("viewmodel.ViewModelFactory");
}

function remoting(binder) {
  binder.bind("xhrManager").to("remoting.XhrManager");
  binder.bind("urlResolver").to("remoting.UrlResolver");
}

function security(binder) {
  binder.bind("sessionManager").to("security.SessionManager");
  binder.bind("authenticator").to("security.Authenticator");
}

function services(binder) {
  binder.bind("initialSettingService").to("services.InitialSettingService");
  binder.bind("rateService").to("services.RateService");
  binder.bind("positionService").to("services.PositionService");
  binder.bind("graphService").to("services.GraphService");
  binder.bind("agentService").to("services.AgentService");
  binder.bind("backtestService").to("services.BacktestService");
}

function stores(binder) {
  binder.bind("localStorage").to("stores.LocalStorage");
}

export default (binder) => {
  remoting(binder);
  model(binder);
  viewModel(binder);
  security(binder);
  services(binder);
  stores(binder);
}
