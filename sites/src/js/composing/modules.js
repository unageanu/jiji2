function model(binder) {
  binder.bind("preferences")
    .to("model.Preferences")
    .onInitialize("restoreState");
  binder.bind("pairs").to("model.trading.Pairs");
  binder.bind("rates").to("model.trading.Rates");
}

function viewModel(binder) {
  binder.bind("application").to("viewmodel.Application");
  binder.bind("navigator").to("viewmodel.Navigator");
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
