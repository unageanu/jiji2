import React                  from "react"
import MUI                    from "material-ui"
import Base                   from "../settings/smtp-server-setting-view"
import LoadingImage           from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const FlatButton   = MUI.FlatButton;

export default class SMTPServerSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="smtp-server-setting-view">
        <h3>SMTPサーバーの設定</h3>
        <div className="description">
          メール送信時に使用するSMTPサーバーを設定してください。<br/>
          ※あとで設定することもできます。
        </div>
        <div className="inputs">
          {this.createInputFields()}
        </div>
        {this.createErrorContent(this.state.error)}
        <div className="buttons">
          <span className="button test-mail">
            <RaisedButton
              label="テストメール送信"
              disabled={this.state.isSaving}
              onClick={this.composeTestMail.bind(this)}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="button next">
            <RaisedButton
              label="設定して次へ"
              primary={true}
              disabled={this.state.isSaving}
              onClick={this.next.bind(this)}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="button skip">
            <FlatButton
              label="設定をスキップ"
              disabled={this.state.isSaving}
              onClick={this.skip.bind(this)}
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
    this.props.model.setSMTPServerSetting( settings );
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
