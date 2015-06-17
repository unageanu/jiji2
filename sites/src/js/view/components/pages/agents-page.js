import React           from "react"
import MUI             from "material-ui"
import AbstractPage    from "./abstract-page"
import AgentSourceList from "../agents/agent-source-list"

export default class AgentsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <AgentSourceList />
      </div>
    );
  }
}
