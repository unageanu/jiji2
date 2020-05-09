import React                                from "react"
import { injectIntl, FormattedHTMLMessage } from 'react-intl';

import Theme              from "../../theme"
import RangeSelector      from "../widgets/range-selector"
import AbstractComponent  from "../widgets/abstract-component"

import Dialog from "material-ui/Dialog"
import {RadioButton, RadioButtonGroup} from 'material-ui/RadioButton'
import FlatButton from "material-ui/FlatButton"

const keys = new Set([
  "downloadType"
]);

class DownloadPositionsDialog extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {open: false};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const { formatMessage } = this.props.intl;
    const labelForAll = <span>
      <FormattedHTMLMessage id='positions.DownloadPositionsDialog.label' />
    </span>;

    return (
      <Dialog
        actions={this.createActionButtons()}
        open={this.state.open}
        modal={true}
        contentClassName="dialog download-positions-dialog"
        contentStyle={Theme.dialog.contentStyle}
        onRequestClose={this.dismiss.bind(this)}>
        <div className="dialog-content">
          <div className="dialog-description">
            <FormattedHTMLMessage id='positions.DownloadPositionsDialog.description' />
          </div>
          <div className="body">
            <RadioButtonGroup
              name="downloadType"
              valueSelected={this.state.downloadType}
              onChange={this.onDownloadTypeChanged.bind(this)}>
              <RadioButton
                value="all"
                label={labelForAll}>
              </RadioButton>
              <RadioButton
                value="filterd"
                label={formatMessage({id:'positions.DownloadPositionsDialog.filter'})}>
              </RadioButton>
            </RadioButtonGroup>
            <RangeSelector
              ref={(ref) => this.rangeSelector = ref}
              model={this.props.model.rangeSelectorModel} />
          </div>
        </div>
      </Dialog>
    );
  }

  createActionButtons() {
    const { formatMessage } = this.props.intl;
    return [
      <FlatButton
        label={formatMessage({id:'positions.DownloadPositionsDialog.download'})}
        primary={false}
        onTouchTap={this.downloadCSV.bind(this)}
      />, <FlatButton
        label={formatMessage({id:'common.button.cancel'})}
        primary={false}
        onTouchTap={this.dismiss.bind(this)}
      />
    ];
  }

  onDownloadTypeChanged(ev, newValue) {
    this.props.model.downloadType = newValue;
  }

  downloadCSV() {
    this.rangeSelector.applySetting();
    this.props.model.createCSVDownloadUrl(this.props.intl.formatMessage).then((url)=> {
      if (!url) return;
      this.dismiss();
      setTimeout( () => { window.location.href = url }, 500 );
      // delay for avoiding dialog problem on IE.
    });
  }
  show() {
    this.props.model.prepare();
    this.setState({open:true});
  }
  dismiss() {
    this.setState({open:false});
  }
}
DownloadPositionsDialog.propTypes = {
  model : React.PropTypes.object
};
DownloadPositionsDialog.defaultProps = {
};

export default injectIntl(DownloadPositionsDialog)
