import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import PositionsTable   from "../positions/positions-table"

export default class NotificationsPage extends AbstractPage {

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
      </div>
    );
  }

  model() {
    return this.context.application.notificationsPageModel;
  }
}
NotificationsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
