import React             from "react"
import { Router } from 'react-router'

import AbstractComponent from "./abstract-component"
import LoadingImage      from "./loading-image"
import Editor            from "react-ace"

import "brace/mode/ruby"
import "brace/theme/github"
import "brace/ext/searchbox"

export default class AceEditor extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  resize(width, height) {
    if (!this.refs.editor) return;
    const elm = React.findDOMNode(this.refs.editor);
    const editor = this.refs.editor.editor;
    elm.style.width  = width + "px";
    elm.style.height = height + "px";
    editor.resize();
  }

  render() {
    return (
      <div className="ace-editor" ref="parent">
        <div className="center-information loading"
          style={{ display: this.props.targetBody == null ? "block" : "none" }}>
          <LoadingImage left={-20}/>
        </div>
        <div style={{ display: this.props.targetBody == null ? "none" : "block"}}>
          <Editor
            ref="editor"
            mode="ruby"
            theme="github"
            width="0px"
            height="0px"
            value={this.props.targetBody}
            name="agent-source-editor_editor"
            onLoad={this.initEditor.bind(this)}
          />
        </div>
      </div>
    );
  }

  initEditor(editor) {
    editor.commands.addCommand({
      name: 'save',
      bindKey: {win: 'Ctrl-S',  mac: 'Command-S'},
      exec: (editor) => {
        this.props.onSave();
      },
      readOnly: true
    });
    editor.$blockScrolling = Infinity;
    editor.gotoLine(0);
  }

  get value() {
    return this.refs.editor ? this.refs.editor.editor.getValue() : null;
  }
}
AceEditor.propTypes = {
  targetBody: React.PropTypes.string,
  onSave: React.PropTypes.func
};
AceEditor.defaultProps = {
  targetBody: null,
  onSave: () => {}
};
