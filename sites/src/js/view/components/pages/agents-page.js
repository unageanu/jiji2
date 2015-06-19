import React             from "react"
import MUI               from "material-ui"
import AbstractPage      from "./abstract-page"
import AgentSourceList   from "../agents/agent-source-list"
import AgentSourceEditor from "../agents/agent-source-editor"
import AceEditor from "react-ace"

import "brace/mode/ruby"
import "brace/theme/github"
import "brace/ext/searchbox"

export default class AgentsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <AgentSourceList />
        <AgentSourceEditor />
      </div>
    );
  }
}
