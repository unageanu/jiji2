
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
export default ( binder ) => {
    remoting(binder);
    viewModel(binder);
    security(binder);
    services(binder);
}
