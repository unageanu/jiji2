import React             from "react"

import AbstractPage      from "./abstract-page"
import LogViewer         from "../logs/log-viewer"

import Card from "material-ui/Card"

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
      <div className="rmt-log-page page">
        <Card className="main-card">
          <LogViewer model={this.model().logViewerModel} />
        </Card>
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
