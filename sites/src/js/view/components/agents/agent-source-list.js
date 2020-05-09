import React                from "react"
import { FormattedMessage } from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import AgentSourceListItem from "./agent-source-list-item"
import LoadingImage        from "../widgets/loading-image"

import {List, ListItem} from "material-ui/List"
import RaisedButton from "material-ui/RaisedButton"

const keys = new Set([
  "sources", "editTarget"
]);

export default class AgentSourceList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      sources :    null,
      editTarget : null
    };
  }

  componentWillMount() {
    const model = this.editor();
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    return <div className="agent-source-list list">
      {this.createContent()}
    </div>;
  }

  createContent() {
    if ( !this.state.sources ) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    if (this.state.sources.length <= 0) {
      return <div className="center-information"><FormattedMessage id="agents.AgentSourceList.noFile" /></div>;
    }
    const items = this.state.sources.map(
      (source) => this.createItemComponent(source));
    const buttonAction = () => this.editor().newSourceFile();
    return (
      <List style={{
        paddingTop:0,
        backgroundColor: "rgba(0,0,0,0)"}}>
        {items}
      </List>
    );
  }

  createItemComponent(agentSource) {
    const tapAction = (e) => this.onItemTapped(e, agentSource);
    const selected  =
      this.state.editTarget && this.state.editTarget.id === agentSource.id;
    return (
      <AgentSourceListItem
        key={agentSource.id}
        agentSource={agentSource}
        selected={selected}
        onTouchTap={tapAction}>
      </AgentSourceListItem>
    );
  }

  onItemTapped(e, source) {
    this.editor().startEdit(source.id);
    e.preventDefault();
  }

  editor() {
    return this.props.model;
  }
}
AgentSourceList.propTypes = {
  model: React.PropTypes.object.isRequired
};
