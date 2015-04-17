
function viewModel(binder) {
    binder.bind("application").to("viewmodel.Application");
    binder.bind("navigator").to("viewmodel.Navigator");
}

function remoting(binder) {
    binder.bind("xhrManager").to("remoting.XhrManager");
}
function security(binder) {
    binder.bind("sessionManager").to("security.SessionManager");
}
export default ( binder ) => {
    remoting(binder);
    viewModel(binder);
    security(binder);
}
