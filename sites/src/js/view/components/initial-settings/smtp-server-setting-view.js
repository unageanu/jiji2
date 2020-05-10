import React                  from "react"
import { injectIntl, FormattedMessage, FormattedHTMLMessage } from 'react-intl';

import { SMTPServerSettingView as Base } from "../settings/smtp-server-setting-view"
import LoadingImage           from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import FlatButton from "material-ui/FlatButton"

class SMTPServerSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="smtp-server-setting-view">
        <h3><FormattedMessage id='initialSettings.SMTPServerSettingView.title'/></h3>
        <div className="description">
          <FormattedHTMLMessage id='initialSettings.SMTPServerSettingView.description'/>
        </div>
        <div className="inputs">
          {this.createInputFields()}
        </div>
        {this.createErrorContent(this.state.error)}
        <div className="buttons">
          <span className="button test-mail">
            <RaisedButton
              label={formatMessage({ id: 'initialSettings.SMTPServerSettingView.composeTestMail' })}
              disabled={this.state.isSaving}
              onClick={this.composeTestMail.bind(this)}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="button next">
            <RaisedButton
              label={formatMessage({ id: 'initialSettings.SMTPServerSettingView.next' })}
              primary={true}
              disabled={this.state.isSaving}
              onClick={this.next.bind(this)}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="button skip">
            <FlatButton
              label={formatMessage({ id: 'initialSettings.SMTPServerSettingView.skip' })}
              disabled={this.state.isSaving}
              onClick={this.skip.bind(this)}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="loading-for-button-action">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
          <div className="message">{this.state.testMailMessage}</div>
        </div>
      </div>
    );
  }

  next() {
    const settings = this.collectSetting();
    this.props.model.setSMTPServerSetting( settings, this.props.intl.formatMessage );
  }
  skip() {
    this.props.model.skipSMTPServerSetting( );
  }

  model() {
    return this.props.model.smtpServerSetting;
  }
}
SMTPServerSettingView.propTypes = {
  model: React.PropTypes.object
};
SMTPServerSettingView.defaultProps = {
  model: null
};

export default injectIntl(SMTPServerSettingView);
