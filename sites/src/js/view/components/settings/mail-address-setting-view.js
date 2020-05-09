import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "mailAddress", "error", "message", "isSaving"
]);

class MailAddressSettingView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      mailAddress: null,
      error:       null,
      message:     null
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    this.setState(state);
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="mail-address-setting setting">
        <h3><FormattedMessage id='settings.MailAddressSettingView.title'/></h3>
        <ul className="description">
          <li><FormattedMessage id='settings.MailAddressSettingView.description.part1'/></li>
          <li>
            <FormattedMessage id='settings.MailAddressSettingView.description.part2'/>
          </li>
        </ul>
        <div className="setting-body">
          <div className="mail-address">
            <TextField
              ref="mailAddress"
              floatingLabelText={formatMessage({ id: 'settings.MailAddressSettingView.mailAddress' })}
              errorText={this.state.error}
              onChange={this.onMailAddressChanged.bind(this)}
              value={this.state.mailAddress || ""}
              style={{ width: "100%" }} />
          </div>
          <div className="buttons">
            <RaisedButton
              label={formatMessage({ id: 'settings.MailAddressSettingView.save' })}
              primary={true}
              disabled={this.state.isSaving}
              onClick={this.save.bind(this)}
            />
            <span className="loading-for-button-action">
              {this.state.isSaving ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.message}</div>
        </div>
      </div>
    );
  }
  onMailAddressChanged(event) {
    this.setState({mailAddress: event.target.value});
  }
  save() {
    const mailAdress = this.state.mailAddress;
    this.props.model.save(mailAdress, this.props.intl.formatMessage);
  }
}
MailAddressSettingView.propTypes = {
  model: React.PropTypes.object
};
MailAddressSettingView.defaultProps = {
  model: null
};
export default injectIntl(MailAddressSettingView);
