import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

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
        <div>
          <RaisedButton
            label="設定"
            disabled={this.state.isSaving}
            onClick={this.save.bind(this)}
          />
          <span className="loading">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
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
