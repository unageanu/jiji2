import React                            from "react"
import ReactDOM                         from "react-dom"
import { injectIntl, FormattedMessage } from 'react-intl';
import { Router }                       from 'react-router'

import AbstractComponent     from "../widgets/abstract-component"
import AceEditor             from "../widgets/ace-editor"
import AgentSourceEditorMenu from "./agent-source-editor-menu"
import AgentFileNameField    from "./agent-filename-field"

const outerWidth  = 360+288+16*3+16*2;
const outerHeight = 100+77+72+16*2+16*2;


const keys = new Set([
  "targetBody",  "editTarget", "sources"
]);

class AgentSourceEditor extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      editTarget:  null,
      targetBody : null
    };
  }

  componentWillMount() {
    const model = this.model();
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
      if (!this.editorPanel || !this.editor) return;
      const elm = ReactDOM.findDOMNode(this.editorPanel);
      this.editor.resize(elm.offsetWidth, elm.offsetHeight);
    }, 100);
  }

  onPropertyChanged(n, e) {
    if (e.key === "sources") {
      this.updateEditorSize();
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
            <FormattedMessage id="agents.AgentSourceEditor.description.part1" />
            <a onClick={ () => window.open('http://jiji2.unageanu.net/usage/020000_how_to_create_agent.html', '_blank')} >
              <FormattedMessage id="agents.AgentSourceEditor.description.part2" />
            </a>
            <FormattedMessage id="agents.AgentSourceEditor.description.part3" />
          </li>
        </ul>
        <div className="header">
          <AgentFileNameField
           model={this.model()}
           ref={(ref) => this.fileName = ref} />
            &nbsp;
          <AgentSourceEditorMenu
            model={this.model()}
            onSave={this.save.bind(this)} />
          {errorElement}
        </div>
        <div className="editor" ref={(ref) => this.editorPanel = ref} >
          {this.createEditor()}
        </div>
      </div>
    );
  }

  createEditor() {
    return <div style={{ display: this.state.editTarget ? "block" : "none" }}>
      <AceEditor
        ref={(ref) => this.editor = ref}
        targetBody={this.state.targetBody||""}
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
    const body = this.editor.value;
    const name = this.fileName.getWrappedInstance().value;
    this.model().save(name, body, this.props.intl.formatMessage);
  }

  model() {
    return this.props.model;
  }
}
AgentSourceEditor.propTypes = {
  model: React.PropTypes.object.isRequired
};
AgentSourceEditor.contextTypes = {
  windowResizeManager: React.PropTypes.object
};
export default injectIntl(AgentSourceEditor)
