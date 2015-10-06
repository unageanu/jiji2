import React             from "react"
import Router            from "react-router"
import MUI       　　　　 from "material-ui"
import AbstractComponent from "../widgets/abstract-component"
import AceEditor         from "react-ace"
import ConfirmDialog     from "../widgets/confirm-dialog"

import "brace/mode/ruby"
import "brace/theme/github"
import "brace/ext/searchbox"

const Dialog       = MUI.Dialog;
const TextField    = MUI.TextField;

const RaisedButton = MUI.RaisedButton;
const FlatButton   = MUI.FlatButton;

const IconButton = MUI.IconButton;
const FontIcon   = MUI.FontIcon;

const keys = new Set([
  "targetBody",  "editTarget", "sources"
]);

export default class AgentSourceEditor extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      editTarget:  null,
      fileName:    null,
      targetBody : null
    };
  }

  componentWillMount() {
    const model = this.editor();
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);

    this.context.windowResizeManager.addObserver("windowResized", (n, ev) => {
      this.updateEditorSize();
    }, this);
    this.registerObservable(this.context.windowResizeManager);
  }

  onPropertyChanged(n, e) {
    if (e.key === "editTarget") {
      this.setState({
        editTarget: e.newValue,
        fileName:   e.newValue ? e.newValue.name : ""
      });
    } else if (e.key === "sources") {
      this.updateEditorSize();
    } else {
      super.onPropertyChanged(n, e);
    }
  }

  updateEditorSize() {
    if (this.updateEditorSizerequest) return;
    this.updateEditorSizerequest = setTimeout(()=> {
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
      this.updateEditorSizerequest = null;
    }, 100);
  }

  render() {
    const errorElement = this.createErrorElement();
    const name = this.state.editTarget ? this.state.editTarget.name : "";
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
          <span className="buttons">
            <IconButton
              className="save-button"
              key="add"
              tooltip={"保存"}
              disabled={!this.state.editTarget}
              onClick={this.save.bind(this)}>
              <FontIcon className="md-save"/>
            </IconButton>
            <IconButton
              className="remove-button"
              key="remove"
              tooltip={"削除..."}
              disabled={!this.state.editTarget}
              onClick={this.confirmRemove.bind(this)}>
              <FontIcon className="md-delete"/>
            </IconButton>
          </span>
          {errorElement}
          <ConfirmDialog
            ref="confirmDialog"
            text="ファイルを削除します。よろしいですか?" />
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
    this.refs.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.editor().remove();
    });
  }

  onFileNameChanged(event) {
    this.setState({fileName: event.target.value});
  }

  editor() {
    return this.props.model;
  }
}
AgentSourceEditor.propTypes = {
  model: React.PropTypes.object.isRequired
};
AgentSourceEditor.contextTypes = {
  windowResizeManager: React.PropTypes.object
};
