import React                  from "react"
import MUI                    from "material-ui"
import Base                   from "../settings/smtp-server-setting-view"

const RaisedButton = MUI.RaisedButton;
const FlatButton   = MUI.FlatButton;

export default class SMTPServerSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <h3>SMTPサーバーの設定</h3>
        <div>
          メール送信時に使用するSMTPサーバーを設定してください。<br/>
          ※あとで設定することもできます。
        </div>
        {this.createInputFields()}
        <br/>
        <RaisedButton
          label="テストメール送信"
          onClick={this.composeTestMail.bind(this)}
        />
        <RaisedButton
          label="次へ"
          onClick={this.next.bind(this)}
        />
        <FlatButton
          label="スキップ"
          onClick={this.skip.bind(this)}
        />
        <div className="error">{this.state.error}</div>
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
SMTPServerSettingView.defaultProp = {
  model: null
};
