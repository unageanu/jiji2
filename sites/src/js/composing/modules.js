function model(binder) {
  binder.bind("preferences")
    .to("model.Preferences")
    .onInitialize("restoreState");
}

function viewModel(binder) {
  binder.bind("application").to("viewmodel.Application");
  binder.bind("navigator").to("viewmodel.Navigator");
}

function remoting(binder) {
  binder.bind("xhrManager").to("remoting.XhrManager");
  binder.bind("urlResolver").to("remoting.UrlResolver");
}

function security(binder) {
  binder.bind("sessionManager").to("security.SessionManager");
}

function services(binder) {
  binder.bind("initialSettingService").to("services.InitialSettingService");
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
