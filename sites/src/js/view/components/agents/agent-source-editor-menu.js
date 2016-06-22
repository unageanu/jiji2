import React             from "react"
import { Router } from 'react-router'

import AbstractComponent from "../widgets/abstract-component"
import ConfirmDialog     from "../widgets/confirm-dialog"
import LoadingImage      from "../widgets/loading-image"

import Dialog from "material-ui/Dialog"
import IconButton from "material-ui/IconButton"
import FontIcon from "material-ui/FontIcon"

const keys = new Set([
  "editTarget", "isSaving"
]);

export default class AgentSourceEditorMenu extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      editTarget:  null
    };
  }

  componentWillMount() {
    const model = this.editor();
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    return (
      <span className="agent-source-editor-menu">
        <IconButton
          className="save-button"
          key="add"
          tooltip={"保存"}
          tooltipPosition="top-center"
          disabled={this.state.isSaving || !this.state.editTarget}
          onClick={this.props.onSave}>
          <FontIcon className="md-save"/>
        </IconButton>
        <IconButton
          className="remove-button"
          key="remove"
          tooltipPosition="top-center"
          tooltip={"削除..."}
          disabled={this.state.isSaving || !this.state.editTarget}
          onClick={this.confirmRemove.bind(this)}>
          <FontIcon className="md-delete"/>
        </IconButton>
        <span className="loading-for-button-action">{
          this.state.isSaving
            ? <LoadingImage size={20} top={-6} />
            : null
        }</span>
        <ConfirmDialog
          ref="confirmDialog"
          text="ファイルを削除します。よろしいですか?" />
      </span>
    );
  }

  confirmRemove() {
    this.refs.confirmDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.editor().remove();
    });
  }

  editor() {
    return this.props.model;
  }
}
AgentSourceEditorMenu.propTypes = {
  model: React.PropTypes.object.isRequired,
  onSave: React.PropTypes.func
};
AgentSourceEditorMenu.defaultProps = {
  onSave: () => {}
};
