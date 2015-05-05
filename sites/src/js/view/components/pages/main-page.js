import React      from "react";
import MUI        from "material-ui";
import Router     from "react-router";

const RouteHandler = Router.RouteHandler;
const Link         = Router.Link;

export default React.createClass({
  propTypes: {
    application: React.PropTypes.object.isRequired
  },
  childContextTypes: {
    application: React.PropTypes.object.isRequired
  },
  render() {
    return (
      <div>
        <div className="navi">
          {this.navigatorElements()}
        </div>
        <div className="content">
          <RouteHandler/>
        </div>
      </div>
    );
  },
  getChildContext: function() {
      return { application: this.props.application };
  },
  navigatorElements() {
    return this.props.application.navigator.menuItems().map((item) => {
      return <Link key={item.route} to={item.route}>{item.text}</Link>;
    });
  }
});
