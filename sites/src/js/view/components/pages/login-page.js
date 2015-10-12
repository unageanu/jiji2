import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import LoadingImage from "../widgets/loading-image"

const TextField    = MUI.TextField;
const Card         = MUI.Card;
const RaisedButton = MUI.RaisedButton;

const keys = new Set([
  "error", "authenticating"
]);

export default class LoginPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      error: ""
    };
  }

  componentWillMount() {
      this.registerPropertyChangeListener(this.model(), keys);
      this.setState(this.collectInitialState(this.model(), keys));
  }

  render() {
    const error = this.state.error
      ? <div className="error">{this.state.error}</div>
      : null;
    return (
      <div className="login-page">
        <Card className="card">
          <div className="inputs">
            <TextField
               ref="password"
               floatingLabelText="パスワード"
               onChange={(ev) => this.setState({password: ev.target.value}) }
               value={this.state.password}
               style={{ width: "100%" }}>
               <input type="password" />
            </TextField>
          </div>
          {error}
          <div className="buttons">
            <RaisedButton
              label="ログイン"
              primary={true}
              disabled={this.state.authenticating}
              onClick={this.login.bind(this)}
              style={{ width: "100%" }}
            />
            <span className="loading">
              {this.state.authenticating ? <LoadingImage size={20} /> : null}
            </span>
          </div>
        </Card>
      </div>
    );
  }

  login(event) {
    this.model().login(this.state.password);
  }

  model() {
    return this.context.application.loginPageModel;
  }
}

LoginPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
