import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

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
      error:         null
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
    this.props.model.addObserver("propertyChanged", (k, ev) => {
      if (ev.key === "error") this.setState({error:ev.newValue});
    }, this);

    this.setState({
      mailError:     mailSetting.error,
      passwordError: passwordSetting.error,
      error:         this.props.model.error
    });
  }
  componentWillUnmount() {
    this.props.model.mailAddressSetting.removeAllObservers(this);
    this.props.model.passwordSetting.removeAllObservers(this);
    this.props.model.removeAllObservers(this);
  }

  render() {
    return (
      <div>
        <h3>メールアドレスとパスワードの設定</h3>
        <div>
          初めに、メールアドレスとシステムのログインパスワードを設定してください。
        </div>
        <ul>
          <li>パスワードはシステムを利用する際に必要になります。</li>
          <li>
            メールアドレスは、パスワードを忘れて再設定するときに使用されます。
            必ず、メールを受信可能なアドレスを設定してください。
          </li>
        </ul>
        <TextField
           ref="mailAddress"
           floatingLabelText="メールアドレス"
           errorText={this.state.mailError}
           onChange={(e) => this.setState({mailAddress: e.target.value}) }
           value={this.state.mailAddress} /><br/>
        <TextField
            ref="newPassword1"
            floatingLabelText="新しいパスワード"
            onChange={(e) => this.setState({password1: e.target.value}) }
            errorText={this.state.passwordError}
            value={this.state.password1}>
            <input type="password" />
        </TextField><br/>
        <TextField
            ref="newPassword2"
            floatingLabelText="新しいパスワード(確認のため、もう一度入力してください)"
            onChange={(e) => this.setState({password2: e.target.value}) }
            errorText={this.state.passwordError}
            value={this.state.password2}>
            <input type="password" />
        </TextField>
        <br/><br/>
        <RaisedButton
          label="次へ"
          onClick={this.next.bind(this)}
        />
        <div className="error">{this.state.error}</div>
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
