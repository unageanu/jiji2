import Observable from "../utils/observable"

function model(binder) {
  binder.bind("preferences")
    .to("model.Preferences")
    .onInitialize("initialize");

  binder.bind("pairs").to("model.trading.Pairs");
  binder.bind("rates").to("model.trading.Rates");
  binder.bind("backtests").to("model.trading.Backtests");
  binder.bind("backtestBuilder").to("model.trading.BacktestBuilder");

  binder.bind("agentSources").to("model.agents.AgentSources");
  binder.bind("agentClasses").to("model.agents.AgentClasses");
}

function viewModel(binder) {
  binder.bind("application").to("viewmodel.Application");
  binder.bind("navigator").to("viewmodel.Navigator");

  binder.bind("homePageModel")
    .to("viewmodel.pages.HomePageModel")
    .onInitialize("postCreate");
  binder.bind("rmtTradingSummaryPageModel")
    .to("viewmodel.pages.RmtTradingSummaryPageModel")
    .onInitialize("postCreate");
  binder.bind("rmtChartPageModel")
    .to("viewmodel.pages.RmtChartPageModel")
    .onInitialize("postCreate");
  binder.bind("rmtPositionsPageModel")
    .to("viewmodel.pages.RmtPositionsPageModel")
    .onInitialize("postCreate");
  binder.bind("rmtAgentSettingPageModel")
    .to("viewmodel.pages.RmtAgentSettingPageModel")
    .onInitialize("postCreate");
  binder.bind("rmtLogPageModel")
    .to("viewmodel.pages.RmtLogPageModel")
    .onInitialize("postCreate");
  binder.bind("newBacktestPageModel")
    .to("viewmodel.pages.NewBacktestPageModel")
    .onInitialize("postCreate");
  binder.bind("backtestsPageModel")
    .to("viewmodel.pages.BacktestsPageModel")
    .onInitialize("postCreate");
  binder.bind("notificationsPageModel")
    .to("viewmodel.pages.NotificationsPageModel")
    .onInitialize("postCreate");
  binder.bind("settingsPageModel")
      .to("viewmodel.pages.SettingsPageModel")
      .onInitialize("postCreate");
  binder.bind("loginPageModel")
      .to("viewmodel.pages.LoginPageModel")
      .onInitialize("postCreate");
  binder.bind("initialSettingsPageModel")
      .to("viewmodel.pages.InitialSettingsPageModel")
      .onInitialize("postCreate");

  binder.bind("agentSourceEditor")
    .to("viewmodel.agents.AgentSourceEditor")
    .onInitialize("initialize");

  binder.bind("viewModelFactory").to("viewmodel.ViewModelFactory");

  binder.bind("eventQueue")
    .to("viewmodel.widgets.EventQueue");
}

function remoting(binder) {
  binder.bind("xhrManager").to("remoting.XhrManager").withProperties({
    supportRelogin: true
  });
  binder.bind("urlResolver").to("remoting.UrlResolver");
}

function errorHandling(binder) {
  binder.bind("errorHandler")
    .to("errorhandling.ErrorHandler")
    .onInitialize("registerHandlers");
}

function security(binder) {
  binder.bind("sessionManager").to("security.SessionManager")
      .onInitialize("initialize");
  binder.bind("authenticator").to("security.Authenticator");
}

function services(binder) {
  binder.bind("initialSettingService").to("services.InitialSettingService");
  binder.bind("rateService").to("services.RateService");
  binder.bind("positionService").to("services.PositionService");
  binder.bind("graphService").to("services.GraphService");
  binder.bind("agentService").to("services.AgentService");
  binder.bind("backtestService").to("services.BacktestService");
  binder.bind("tradingSummariesService")
    .to("services.TradingSummariesService");
  binder.bind("rmtService").to("services.RmtService");
  binder.bind("logService").to("services.LogService");
  binder.bind("notificationService").to("services.NotificationService");
  binder.bind("actionService").to("services.ActionService");
  binder.bind("securitiesSettingService")
    .to("services.SecuritiesSettingService");
  binder.bind("smtpServerSettingService")
    .to("services.SmtpServerSettingService");
  binder.bind("userSettingService").to("services.UserSettingService");
  binder.bind("passwordResettingService")
    .to("services.PasswordResettingService");
  binder.bind("initialSettingService").to("services.InitialSettingService");
  binder.bind("deviceService").to("services.DeviceService");
}

function stores(binder) {
  binder.bind("localStorage").to("stores.LocalStorage");
}
function utils(binder) {
  binder.bind("timeSource").to("utils.TimeSource");
  binder.bind("pushNotifier").toInstance( new Observable() );
}

export default (binder) => {
  remoting(binder);
  model(binder);
  viewModel(binder);
  security(binder);
  services(binder);
  stores(binder);
  utils(binder);
  errorHandling(binder);
}
