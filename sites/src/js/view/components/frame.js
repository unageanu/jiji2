import React               from "react"
import MUI                 from "material-ui"
import Router              from "react-router"
import LeftNavi            from "./left-navi"
import WindowResizeManager from "../window-resize-manager"
import Theme               from "../theme"

const RouteHandler = Router.RouteHandler;
const Link         = Router.Link;
const Types        = MUI.MenuItem.Types;

export default class Frame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};

    this.themeManager = new MUI.Styles.ThemeManager();
    this.windowResizeManager = new WindowResizeManager();
    this.setTheme();
  }

  render() {
    return (
      <div>
        <div className="topbar"></div>
        <div className="container">
          <LeftNavi />
          <div className="content">
            <RouteHandler/>
          </div>
        </div>
      </div>
    );
  }
  getChildContext() {
      return {
        application        : this.props.application,
        muiTheme           : this.themeManager.getCurrentTheme(),
        windowResizeManager: this.windowResizeManager
      };
  }

  setTheme() {
    this.themeManager.setTheme(Theme);
  }

  navigatorElements() {
    return this.props.application.navigator.menuItems().filter((item)=>{
      return item.type === Types.SUBHEADER;
    }).map((item) => {
      return <Link key={item.route} to={item.route}>{item.text}</Link>;
    });
  }
}
Frame.propTypes =  {
  application: React.PropTypes.object.isRequired
};
Frame.childContextTypes = {
  application:         React.PropTypes.object.isRequired,
  windowResizeManager: React.PropTypes.object,
  muiTheme:            React.PropTypes.object
};
