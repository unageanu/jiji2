import React             from "react"
import MUI               from "material-ui"
import AbstractPage      from "./abstract-page"
import LogViewer         from "../logs/log-viewer"

export default class RMTLogPage extends AbstractPage {

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
        <LogViewer model={this.model().logViewerModel} />
      </div>
    );
  }

  model() {
    return this.context.application.rmtLogPageModel;
  }
}

RMTLogPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
