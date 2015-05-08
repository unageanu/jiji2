import React      from "react";
import MUI        from "material-ui";
import Router     from "react-router";

const RouteHandler = Router.RouteHandler;
const Link         = Router.Link;

export default class Frame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

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
  }
  getChildContext() {
      return { application: this.props.application };
  }
  navigatorElements() {
    return this.props.application.navigator.menuItems().map((item) => {
      return <Link key={item.route} to={item.route}>{item.text}</Link>;
    });
  }
}
Frame.propTypes =  {
  application: React.PropTypes.object.isRequired
};
Frame.childContextTypes = {
  application: React.PropTypes.object.isRequired
};
