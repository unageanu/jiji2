import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"

const TextField    = MUI.TextField;
const RaisedButton = MUI.RaisedButton;

export default class LoginPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {
      error: ""
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.model());
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  render() {
    return (
      <div>
        パスワード&nbsp;:&nbsp;
        <input ref="password-input" type="password" />
        &nbsp;&nbsp;
        <br/>
        <RaisedButton
          label="ログイン"
          onClick={this.login.bind(this)}
        />
        <br/>
        <div className="error">{this.state.error}</div>
      </div>
    );
  }

  login(event) {
    const password = React.findDOMNode(this.refs["password-input"]).value;
    this.model().login(password).then( () => {
      this.context.application.xhrManager.cancel();
      this.router().transitionTo("/");
    });
  }

  model() {
    return this.context.application.loginPageModel;
  }
  router() {
    return this.context.router;
  }
}

LoginPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
