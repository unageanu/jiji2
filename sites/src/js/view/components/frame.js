import React                        from "react"
import MUI                          from "material-ui"
import Router                       from "react-router"
import LeftNavi                     from "./left-navi"
import WindowResizeManager          from "../window-resize-manager"
import Theme                        from "../theme"
import UIEventHandler               from "./widgets/ui-evnet-handler"

const RouteHandler = Router.RouteHandler;
const Link         = Router.Link;
const Types        = MUI.MenuItem.Types;
const IconButton   = MUI.IconButton;
const FontIcon   = MUI.FontIcon;

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
      <div className="root">
        <div className="topbar">
          <span className="buttons">
            <span className="button">
              <span className="button">
                <IconButton
                  key="help"
                  tooltip={"サポート・フォーラム"}
                  iconStyle={{color:"#FFF"}}
                  onClick={() => window.open("https://github.com/unageanu/jiji2/issues", "forum")}>
                  <FontIcon className="md-forum" />
                </IconButton>
              </span>
              <IconButton
                key="help"
                tooltip={"使い方"}
                iconStyle={{color:"#FFF"}}
                onClick={() => window.open("http://jiji.unageanu.net/usage", "usage")}>
                <FontIcon className="md-live-help" />
              </IconButton>
            </span>
          </span>
        </div>
        <div className="container">
          <LeftNavi />
          <div className="content">
            <RouteHandler/>
          </div>
        </div>
        <UIEventHandler />
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
Frame.contextTypes = {
  router: React.PropTypes.func
};
