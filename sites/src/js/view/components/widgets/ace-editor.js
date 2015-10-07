import React             from "react"
import Router            from "react-router"
import MUI       　　　　 from "material-ui"
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

  componentWillMount() {
    this.context.windowResizeManager.addObserver("windowResized", (n, ev) => {
      this.updateEditorSize();
    }, this);
    this.registerObservable(this.context.windowResizeManager);
  }

  updateEditorSize() {
    if (this.updateEditorSizerequest) return;
    this.updateEditorSizerequest = setTimeout(()=> {
      if (!this.refs.editor) return;
      const elm = React.findDOMNode(this.refs.editor);
      const editor = this.refs.editor.editor;

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

      elm.style.width  = (wsize.w - this.props.outerWidth) + "px";
      elm.style.height = (Math.max(wsize.h, csize.h) - this.props.outerHeight) + "px";
      editor.resize();

      this.updateEditorSizerequest = null;
    }, 100);
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
    this.updateEditorSize();
  }

  get value() {
    return this.refs.editor ? this.refs.editor.editor.getValue() : null;
  }
}
AceEditor.propTypes = {
  targetBody: React.PropTypes.string,
  onSave: React.PropTypes.func,
  outerWidth: React.PropTypes.number.isRequired,
  outerHeight: React.PropTypes.number.isRequired
};
AceEditor.defaultProps = {
  targetBody: null,
  onSave: () => {}
};
AceEditor.contextTypes = {
  windowResizeManager: React.PropTypes.object
};
