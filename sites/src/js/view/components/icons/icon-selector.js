import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import Dropzone           from "react-dropzone"
import AbstractComponent  from "../widgets/abstract-component"
import LoadingImage       from "../widgets/loading-image"
import AgentIcon          from "../widgets/agent-icon"
import Theme              from "../../theme"

import FlatButton from "material-ui/FlatButton"
import Dialog from "material-ui/Dialog"

const keys = new Set([
  "icons"
]);
const modelKeys = new Set([
  "selectedId"
]);

class IconSelector extends AbstractComponent  {

  constructor(props) {
    super(props);
    this.state = {
      open: false
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, modelKeys);
    this.registerPropertyChangeListener(this.props.model.icons, keys);
    const state = Object.assign(
      this.collectInitialState(this.props.model, modelKeys),
      this.collectInitialState(this.props.model.icons, keys));
    this.setState(state);
  }

  render() {
    const { formatMessage } = this.props.intl;
    const actions = [
      <FlatButton
        label={formatMessage({ id: 'common.button.cancel' })}
        primary={false}
        onTouchTap={this.dismiss.bind(this)}
      />
    ];
    const editLink = !this.props.readOnly
      ? <a onTouchTap={this.showDialog.bind(this)}><FormattedMessage id='icons.IconSelector.change'/></a>
      : null;
    return (
      <div className="icon-selector">
        <div className="icon-and-action">
          <AgentIcon className="icon"
            iconId={this.state.selectedId}
            onTouchTap={this.showDialog.bind(this)}
            urlResolver={this.props.model.icons.iconService.urlResolver} />
          {editLink}
        </div>
        <Dialog
          open={this.state.open}
          actions={actions}
          modal={true}
          className="icon-selector dialog"
          contentStyle={Theme.dialog.contentStyle}
          onRequestClose={this.dismiss.bind(this)}>
          <div className="dialog-content">
            <div className="dialog-description"><FormattedMessage id='icons.IconSelector.description'/></div>
            <div className="icons">
              {this.createIcons()}
            </div>
            {this.createDropzone()}
          </div>
        </Dialog>
      </div>
    );
  }

  createDropzone() {
    if (this.state.uploading) {
      return <div className="center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    } else {
      return <Dropzone onDrop={this.onDrop.bind(this)} className="drop-area">
        {this.createErrorContent(this.state.error)}
        <div><FormattedMessage id='icons.IconSelector.addDescription.part1'/></div>
        <ul>
          <li><FormattedMessage id='icons.IconSelector.addDescription.part2'/></li>
          <li><FormattedMessage id='icons.IconSelector.addDescription.part3'/></li>
        </ul>
      </Dropzone>;
    }
  }

  showDialog(ev) {
    this.setState({ error: null, open:true });
    ev.preventDefault();
  }

  dismiss() {
    this.setState({open:false});
  }

  createIcons() {
    return (this.state.icons||[]).map((icon, index) => {
      return <FlatButton
        className="icon"
        key={index}
        onTouchTap={(ev) => this.onIconSelected(ev, icon)}
        style={{
          lineHeight: "normal",
          minWidth: "56px",
          width: "56px",
          height: "56px",
          padding: "8px"
        }}
        labelStyle={{
          lineHeight: "normal"
        }}>
        <AgentIcon
          iconId={icon.id}
          urlResolver={this.props.model.icons.iconService.urlResolver} />
      </FlatButton>;
    });
  }

  onIconSelected(ev, icon) {
    this.props.model.selectedId = icon.id;
    this.dismiss();
    ev.preventDefault();
  }

  onDrop(files) {
    const { formatMessage } = this.props.intl;
    this.setState({
      uploading:true,
      error: null
    });
    this.props.model.icons.add(files[0]).then(
      () => this.setState({uploading:false}),
      (error) => {
        this.setState({
          uploading:false,
          error: formatMessage({ id: 'icons.IconSelector.error' })
        });
        error.preventDefault = true;
      });
  }

}
IconSelector.propTypes = {
  model: React.PropTypes.object.isRequired,
  enableUpload: React.PropTypes.bool,
  readOnly : React.PropTypes.bool
};
IconSelector.defaultProps = {
  enableUpload: false,
  readOnly: false
};

export default injectIntl(IconSelector);
