import React             from "react"
import MUI               from "material-ui"
import AbstractPage      from "./abstract-page"
import LogViewer         from "../logs/log-viewer"

const Card = MUI.Card;

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
      <div className="rmt-log-page">
        <Card className="card">
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
