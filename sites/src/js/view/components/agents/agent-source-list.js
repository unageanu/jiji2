import React  from "react"
import Router from "react-router"
import MUI    from "material-ui"

const List         = MUI.List;
const ListItem     = MUI.ListItem;
const RaisedButton = MUI.RaisedButton;

export default class AgentSourceList extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      sources :    [],
      editTarget : null
    };
  }

  componentWillMount() {
    this.editor().addObserver("propertyChanged", (n, e) => {
      let newState = null;
      if (e.key === "sources") {
        newState = {sources: e.newValue};
      } else if (e.key === "editTarget") {
        newState = {editTarget: e.newValue};
      }
      this.setState(newState);
    }, this);
    this.editor().load();
  }
  componentWillUnmount() {
    this.editor().removeAllObservers(this);
  }

  render() {
    const items = this.state.sources.map(
      (source) => this.createItemcomponent(source));
    const buttonAction = () => this.editor().newSourceFile();
    return (
      <div className="agent-source-list">
        <div className="buttons">
          <RaisedButton
            label="新規作成"
            onTouchTap={buttonAction}
             />
        </div>
        <div className="list">
          <List>{items}</List>
        </div>
      </div>
    );
  }

  createItemcomponent(agentSource) {
    const tapAction = (e) => this.onItemTapped(e, agentSource);
    const selected  =
      this.state.editTarget && this.state.editTarget.id === agentSource.id;
    return (
      <ListItem
        key={agentSource.id}
        className={selected ? "mui-selected" : ""}
        onTouchTap={tapAction}>
        {agentSource.name}
      </ListItem>
    );
  }

  onItemTapped(e, source) {
    this.editor().startEdit(source.id);
  }

  editor() {
    return this.context.application.agentSourceEditor;
  }
}
AgentSourceList.contextTypes = {
  application: React.PropTypes.object.isRequired
};
