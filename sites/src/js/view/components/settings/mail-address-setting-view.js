import React               from "react"

import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "mailAddress", "error", "message", "isSaving"
]);

export default class MailAddressSettingView extends AbstractComponent {

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
    return (
      <div className="mail-address-setting setting">
        <h3>メールアドレスの設定</h3>
        <ul className="description">
          <li>システムで使用するメールアドレスを設定します。</li>
          <li>
            メールアドレスは、パスワードを忘れて再設定するときに使用されます。
            必ず、メールを受信可能なアドレスを設定してください。
          </li>
        </ul>
        <div className="setting-body">
          <div className="mail-address">
            <TextField
              ref="mailAddress"
              floatingLabelText="メールアドレス"
              errorText={this.state.error}
              onChange={this.onMailAddressChanged.bind(this)}
              value={this.state.mailAddress || ""}
              style={{ width: "100%" }} />
          </div>
          <div className="buttons">
            <RaisedButton
              label="設定"
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
    this.props.model.save(mailAdress);
  }
}
MailAddressSettingView.propTypes = {
  model: React.PropTypes.object
};
MailAddressSettingView.defaultProps = {
  model: null
};
