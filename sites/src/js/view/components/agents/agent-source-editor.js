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
      } else if (e.key === "sources") {
        this.updateEditorSize();
      }
      if (newState) this.setState(newState);
    }, this);

    this.context.windowResizeManager.addObserver("windowResized", (n, ev) => {
      this.updateEditorSize();
    }, this);
  }
  componentWillUnmount() {
    this.editor().removeAllObservers(this);
    this.context.windowResizeManager.removeAllObservers(this);
  }


  updateEditorSize() {
    if (this.updateEditorSizerequest) return;
    setTimeout(()=> {
      const elm = React.findDOMNode(this.refs.editor);
      // const w = elm.scrollWidth;
      // const h = elm.scrollHeight;
      const wsize = this.context.windowResizeManager.windowSize;
      const csize = this.context.windowResizeManager.contentSize;
      // console.log("w:" + wsize.w  + " h:" + wsize.h );
      // console.log("w:" + csize.w  + " h:" + csize.h );
      // this.setState({
      //   editorWidth: (wsize.w - 650) + "px",
      //   editorHeight: (wsize.h - 220) + "px"
      // });
      elm.style.width  = (wsize.w - 650) + "px";
      elm.style.height = (wsize.h - 220) + "px";
      this.refs.editor.editor.resize();
    }, 100);
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
        <div className="header">
          <TextField
            ref="name"
            hintText="agent.rb"
            floatingLabelText="名前"
            disabled={!this.state.editTarget}
            onChange={this.onFileNameChanged.bind(this)}
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
        <div className="editor">
          <AceEditor
            ref="editor"
            mode="ruby"
            theme="github"
            width="0px"
            height="0px"
            value={this.state.targetBody}
            name="agent-source-editor_editor"
          />
        </div>
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

  onFileNameChanged(event) {
    this.setState({fileName: event.target.value});
  }

  editor() {
    return this.context.application.agentSourceEditor;
  }
}
AgentSourceEditor.contextTypes = {
  application: React.PropTypes.object.isRequired,
  windowResizeManager: React.PropTypes.object
};
