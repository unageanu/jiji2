import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"

export default class LoginPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = { error: "", title:"" };
  }

  render() {
    return (
      <div>
        password:
        &nbsp;
        <input
          type="password"
          value={this.state.password}
          onChange={this.onChange.bind(this)}
        ></input>
        &nbsp;&nbsp;
        <button onClick={this.login.bind(this)}>
          ログイン
        </button>
        <div className="error">{this.state.error}</div>
      </div>
    );
  }

  onChange(event) {
    this.setState({error:"", password: event.target.value});
  }

  login(event) {
    const authenticator = this.context.application.authenticator;
    authenticator.login( this.state.password ).fail(
      (error) => this.setState({error:"ログイン失敗 : " + error.message, title:""}));
    this.setState({error:"", title:""});
  }
}

LoginPage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
