import React                 from "react"
import Router                from "react-router"

import AbstractComponent     from "../widgets/abstract-component"
import AceEditor             from "../widgets/ace-editor"
import AgentSourceEditorMenu from "./agent-source-editor-menu"
import AgentFileNameField    from "./agent-filename-field"

const outerWidth  = 360+288+16*3+16*2;
const outerHeight = 100+77+72+16*2+16*2;


const keys = new Set([
  "targetBody",  "editTarget", "sources"
]);

export default class AgentSourceEditor extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      editTarget:  null,
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
  }

  updateEditorSize() {
    if (this.updateEditorSizerequest) return;
    this.updateEditorSizerequest = setTimeout(()=> {
      this.updateEditorSizerequest = null;
      if (!this.refs.editorPanel || !this.refs.editor) return;
      const elm = React.findDOMNode(this.refs.editorPanel);
      this.refs.editor.resize(elm.offsetWidth, elm.offsetHeight);
    }, 100);
  }

  onPropertyChanged(n, e) {
    if (e.key === "sources") {
      if (this.refs.aceEditor) this.refs.aceEditor.updateEditorSize();
    } else {
      super.onPropertyChanged(n, e);
    }
  }

  render() {
    this.updateEditorSize();
    const errorElement = this.createErrorElement();
    return (
      <div className="agent-source-editor">
        <ul className="info">
          <li>
            エージェントの詳しい作り方は
            <a onClick={ () => window.open('http://jiji2.unageanu.net/usage/020000_how_to_create_agent.html', '_blank')} >こちら</a>
            をご覧ください。
          </li>
        </ul>
        <div className="header">
          <AgentFileNameField ref="filename" model={this.editor()} />
            &nbsp;
          <AgentSourceEditorMenu
            model={this.editor()}
            onSave={this.save.bind(this)} />
          {errorElement}
        </div>
        <div className="editor" ref="editorPanel">
          {this.createEditor()}
        </div> 
      </div>
    );
  }

  createEditor() {
    return <div style={{ display: this.state.editTarget ? "block" : "none" }}>
      <AceEditor
        ref="editor"
        targetBody={this.state.targetBody}
        onSave={this.save.bind(this)}
        outerWidth={outerWidth}
        outerHeight={
          outerHeight + (this.state.editTarget && this.state.editTarget.error ? 40 : 0 )
        } />
    </div>;
  }

  createErrorElement() {
    if (this.state.editTarget && this.state.editTarget.status === "error") {
      return this.createErrorContent(this.state.editTarget.error);
    } else {
      return null;
    }
  }

  save() {
    const body = this.refs.editor.value;
    const name = this.refs.filename.value;
    this.editor().save(name, body);
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
