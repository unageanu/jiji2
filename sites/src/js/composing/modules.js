
const viewModel = (binder) => {
  binder.bind("application").to("viewmodel.Application");
  binder.bind("navigator").to("viewmodel.Navigator");
};


export default ( binder ) => {
  viewModel(binder);
}
