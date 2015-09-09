import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

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
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      mailAddress:   this.props.model.mailAddress,
      error:         this.props.model.error,
      message:       this.props.model.message
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    return (
      <div className="securities-setting">
        <h3>メールアドレスの設定</h3>
        <div>
        <TextField
           ref="mailAddress"
           floatingLabelText="メールアドレス"
           errorText={this.state.error}
           onChange={this.onMailAddressChanged.bind(this)}
           value={this.state.mailAddress} />
        </div>
        <br/>
        <RaisedButton
          label="設定"
          onClick={this.save.bind(this)}
        />
        <div className="message">{this.state.message}</div>
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
