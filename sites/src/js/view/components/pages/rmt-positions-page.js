import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"

export default class RMTPositionsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>

      </div>
    );
  }

  model() {
    return this.context.application.rmtAgentSettingPageModel;
  }
}
RMTPositionsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
