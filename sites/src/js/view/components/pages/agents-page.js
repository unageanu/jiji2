import React               from "react"

import AbstractPage        from "./abstract-page"
import AgentSourceList     from "../agents/agent-source-list"
import AgentSourceListMenu from "../agents/agent-source-list-menu"
import AgentSourceEditor   from "../agents/agent-source-editor"

import "brace/mode/ruby"
import "brace/theme/github"
import "brace/ext/searchbox"

import Card from "material-ui/Card"

export default class AgentsPage extends AbstractPage {

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
      <div className="agents-page page">
        <Card className="main-card">
          <div className="agent-list-panel">
            <AgentSourceListMenu model={this.model().agentSourceEditor} />
            <AgentSourceList model={this.model().agentSourceEditor}/>
          </div>
          <div className="agent-editor-panel">
            <AgentSourceEditor model={this.model().agentSourceEditor} />
          </div>
        </Card>
      </div>
    );
  }

  model() {
    return this.context.application.agentsPageModel;
  }
}
AgentsPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
