import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import AgentSourceListItem from "./agent-source-list-item"
import LoadingImage        from "../widgets/loading-image"

const List         = MUI.List;
const ListItem     = MUI.ListItem;
const RaisedButton = MUI.RaisedButton;

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
    if ( !this.state.sources ) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    const items = this.state.sources.map(
      (source) => this.createItemComponent(source));
    const buttonAction = () => this.editor().newSourceFile();
    return (
      <div className="agent-source-list">
        <List>{items}</List>
      </div>
    );
  }

  createItemComponent(agentSource) {
    const tapAction = (e) => this.onItemTapped(e, agentSource);
    const selected  =
      this.state.editTarget && this.state.editTarget.id === agentSource.id;
    return (
      <AgentSourceListItem
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
