import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import AccountView      from "../accounts/account-view"
import MiniChart        from "../chart/mini-chart-view"

export default class HomePage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize();
  }

  render() {
    return (
      <div>
        <AccountView model={this.model().accounts} />
        <MiniChart
          model={this.model().miniChart}/>
      </div>
    );
  }

  model() {
    return this.context.application.homePageModel;
  }
}
HomePage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
