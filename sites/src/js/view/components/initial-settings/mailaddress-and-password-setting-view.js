import React                  from "react"

import AbstractComponent      from "../widgets/abstract-component"
import LoadingImage           from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "error", "isSaving"
]);

export default class MailaddressAndPasswordSettingView
extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      mailError:     null,
      mailAddress:   null,
      password1:     null,
      password2:     null,
      passwordError: null,
      error:         null,
      isSaving:      false
    };
  }

  componentWillMount() {
    const mailSetting = this.props.model.mailAddressSetting;
    mailSetting.addObserver("propertyChanged", (k, ev) => {
      if (ev.key === "error") this.setState({mailError:ev.newValue});
    }, this);
    const passwordSetting = this.props.model.passwordSetting;
    passwordSetting.addObserver("propertyChanged", (k, ev) => {
      if (ev.key === "error") this.setState({passwordError:ev.newValue});
    }, this);
    this.registerPropertyChangeListener(this.props.model, keys);

    this.setState(Object.assign({
      mailError:     mailSetting.error,
      passwordError: passwordSetting.error
    }, this.collectInitialState(this.props.model, keys)));
  }

  componentWillUnmount() {
    this.props.model.mailAddressSetting.removeAllObservers(this);
    this.props.model.passwordSetting.removeAllObservers(this);
    this.props.model.removeAllObservers(this);
  }

  render() {
    return (
      <div className="mailaddress-and-password-setting-view">
        <h3>メールアドレスとパスワードの設定</h3>
        <div className="description">
          メールアドレスとシステムのログインパスワードを設定してください。
        </div>
        <ul className="description">
          <li>パスワードはシステムを利用する際に必要になります。</li>
          <li>
            メールアドレスは、パスワードを忘れて再設定するときに使用されます。
            必ず、メールを受信可能なアドレスを設定してください。
          </li>
        </ul>
        <div className="inputs">
          <div className="mail-address">
            <TextField
               ref="mailAddress"
               floatingLabelText="メールアドレス"
               errorText={this.state.mailError}
               onChange={(e) => this.setState({mailAddress: e.target.value}) }
               value={this.state.mailAddress}
               style={{ width: "100%" }}
                />
          </div>
          <div className="password">
            <TextField
                ref="newPassword1"
                floatingLabelText="パスワード"
                onChange={(e) => this.setState({password1: e.target.value}) }
                errorText={this.state.passwordError}
                value={this.state.password1}
                style={{ width: "100%" }}>
                <input type="password" />
            </TextField>
          </div>
          <div className="password">
            <TextField
                ref="newPassword2"
                floatingLabelText="パスワード (確認用)"
                onChange={(e) => this.setState({password2: e.target.value}) }
                errorText={this.state.passwordError}
                value={this.state.password2}
                style={{ width: "100%" }}>
                <input type="password" />
            </TextField>
            <div className="description">
              ※確認のため、パスワードを再入力してください。
            </div>
          </div>
        </div>
        {this.createErrorContent(this.state.error)}
        <div className="buttons">
          <span className="button">
            <RaisedButton
              label="次へ"
              onClick={this.next.bind(this)}
              disabled={this.state.isSaving}
              primary={true}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="loading-for-button-action">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
      </div>
    );
  }

  next() {
    this.props.model.setMailAddressAndPassword(
      this.state.mailAddress, this.state.password1, this.state.password2);
  }
}
MailaddressAndPasswordSettingView.propTypes = {
  model: React.PropTypes.object
};
MailaddressAndPasswordSettingView.defaultProps = {
  model: null
};
