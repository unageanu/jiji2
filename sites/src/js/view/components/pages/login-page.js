import React      from "react";
import MUI        from "material-ui";

export default React.createClass({

  contextTypes: {
    application: React.PropTypes.object.isRequired
  },

  getInitialState(){
      return { error: "", title:"" };
  },

  render() {
    return (
      <div>
        password:
        &nbsp;
        <input
          type="password"
          value={this.state.password}
          onChange={this.onChange}
        ></input>
        &nbsp;&nbsp;
        <button onClick={this.login}>
          ログイン
        </button>
        <div className="error">{this.state.error}</div>
      </div>
    );
  },

  onChange(event) {
    this.setState({error:"", password: event.target.value});
  },

  login(event) {
    const authenticator = this.context.application.authenticator;
    authenticator.login( this.state.password ).fail(
      (error) => this.setState({error:"ログイン失敗 : " + error.message, title:""}));
    this.setState({error:"", title:""});
  }
});
