import React     from "react"
import Router    from "react-router"
import MUI       from "material-ui"
import AceEditor from "react-ace"

import "brace/mode/ruby"
import "brace/theme/github"
import "brace/ext/searchbox"

const Dialog       = MUI.Dialog;
const TextField    = MUI.TextField;

const RaisedButton = MUI.RaisedButton;
const FlatButton   = MUI.FlatButton;

export default class AgentSourceEditor extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      editTarget:  null,
      fileName:    null,
      targetBody : null
    };
  }

  componentWillMount() {
    this.editor().addObserver("propertyChanged", (n, e) => {
      let newState = null;
      if (e.key === "targetBody") {
        newState = {targetBody: e.newValue};
      } else if (e.key === "editTarget") {
        newState = {
          editTarget: e.newValue,
          fileName:   e.newValue ? e.newValue.name : ""
        };
      }
      if (newState) this.setState(newState);
    }, this);
  }
  componentWillUnmount() {
    this.editor().removeAllObservers(this);
  }

  render() {
    const errorElement = this.createErrorElement();
    const name = this.state.editTarget ? this.state.editTarget.name : "";
    const dialogActions=[
      { text: "いいえ", onTouchTap: this.cancelRemove.bind(this) },
      { text: "はい", onTouchTap: this.remove.bind(this), ref: "submit" }
    ];
    return (
      <div className="agent-source-editor">
        <div>
          <TextField
            ref="name"
            hintText="agent.rb"
            floatingLabelText="名前"
            disabled={!this.state.editTarget}
            onChange={this.onChangeFileName.bind(this)}
            value={this.state.fileName} />
            &nbsp;
          <RaisedButton
            label="保存"
            disabled={!this.state.editTarget}
            onClick={this.save.bind(this)}
          />
          &nbsp;
          <FlatButton
            label="...削除"
            disabled={!this.state.editTarget}
            onClick={this.confirmRemove.bind(this)}
          />
          {errorElement}
          <Dialog
            ref="dialog"
            title="ファイルを削除します。よろしいですか?"
            actions={dialogActions}
            modal={true}
          />
        </div>
        <AceEditor
          ref="editor"
          mode="ruby"
          theme="github"
          width="auto"
          height="400px"
          value={this.state.targetBody}
          name="agent-source-editor_editor"
        />
      </div>
    );
  }

  createErrorElement() {
    if (this.state.editTarget && this.state.editTarget.status === "error") {
      return <div className="error">{this.state.editTarget.error}</div>;
    } else {
      return null;
    }
  }

  save() {
    const body = this.refs.editor.editor.getValue();
    const name = this.state.fileName;
    this.editor().save(name, body);
  }

  confirmRemove() {
    this.refs.dialog.show();
  }
  cancelRemove() {
    this.refs.dialog.dismiss();
  }
  remove() {
    this.editor().remove();
    this.refs.dialog.dismiss();
  }

  onChangeFileName(e, newValue) {
    this.setState({fileName: event.target.value});
  }
  onChangeBody(newValue) {
    this.setState({targetBody: newValue});
  }

  editor() {
    return this.context.application.agentSourceEditor;
  }
}
AgentSourceEditor.contextTypes = {
  application: React.PropTypes.object.isRequired
};
