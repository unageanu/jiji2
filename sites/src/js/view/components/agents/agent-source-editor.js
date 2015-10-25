import React                 from "react"
import Router                from "react-router"
import MUI       　　　　     from "material-ui"
import AbstractComponent     from "../widgets/abstract-component"
import AceEditor             from "../widgets/ace-editor"
import AgentSourceEditorMenu from "./agent-source-editor-menu"

const TextField    = MUI.TextField;

const outerWidth  = 360+288+16*3+16*2;
const outerHeight = 100+77+72+16*2+16*2;


const keys = new Set([
  "targetBody",  "editTarget", "sources", "fileNameError"
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
  }

  onPropertyChanged(n, e) {
    if (e.key === "editTarget") {
      this.setState({
        editTarget: e.newValue,
        fileName:   e.newValue ? e.newValue.name : ""
      });
    } else if (e.key === "sources") {
      if (this.refs.aceEditor) this.refs.aceEditor.updateEditorSize();
    } else {
      super.onPropertyChanged(n, e);
    }
  }

  render() {
    const errorElement = this.createErrorElement();
    return (
      <div className="agent-source-editor">
        <ul className="info">
          <li>エージェントの作り方は<a href="http://" target="blank">こちら</a>をご確認ください。</li>
          <li>
            現在動作しているエージェントのコードを変更しても、動作は即座には変わりません。
            変更後のコードは、新しくエージェントを作成した場合に有効になります。
          </li>
        </ul>
        <div className="header">
          <TextField
            ref="name"
            hintText="agent.rb"
            floatingLabelText="ファイル名"
            errorText={this.state.fileNameError}
            disabled={!this.state.editTarget}
            onChange={this.onFileNameChanged.bind(this)}
            value={this.state.fileName} />
            &nbsp;
          <AgentSourceEditorMenu
            model={this.editor()}
            onSave={this.save.bind(this)} />
          {errorElement}
        </div>
        <div className="editor">
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
    const name = this.state.fileName;
    this.editor().save(name, body);
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
