import React                            from "react"
import { Router, Link }                 from 'react-router'
import { injectIntl, FormattedMessage } from 'react-intl';

import LeftNavi                         from "./left-navi"
import WindowResizeManager              from "../window-resize-manager"
import theme                            from "../theme"
import UIEventHandler                   from "./widgets/ui-evnet-handler"
import IconButton                       from "material-ui/IconButton"
import FontIcon                         from "material-ui/FontIcon"
import MuiThemeProvider                 from 'material-ui/styles/MuiThemeProvider'

class Frame extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};

    this.windowResizeManager = new WindowResizeManager();
  }

  render() {
    const { formatMessage } = this.props.intl
    return (
      <MuiThemeProvider muiTheme={theme}>
        <div className="root">
          <div className="topbar">
            <span className="buttons">
              <span className="button">
                <span className="button">
                  <IconButton
                    key="help"
                    tooltip={formatMessage({ id: 'Frame.support' })}
                    iconStyle={{color:"#FFF"}}
                    onClick={() => window.open("https://github.com/unageanu/jiji2/issues", "forum")}>
                    <FontIcon className="md-forum" />
                  </IconButton>
                </span>
                <IconButton
                  key="help"
                  tooltip={formatMessage({ id: 'Frame.usage' })}
                  iconStyle={{color:"#FFF"}}
                  onClick={() => window.open("http://jiji2.unageanu.net/usage", "usage")}>
                  <FontIcon className="md-live-help" />
                </IconButton>
              </span>
            </span>
          </div>
          <div className="container">
            <LeftNavi />
            <div className="content">
              {this.props.children}
            </div>
          </div>
          <UIEventHandler />
        </div>
      </MuiThemeProvider>
    );
  }
  getChildContext() {
      return {
        application        : this.props.application,
        windowResizeManager: this.windowResizeManager
      };
  }

  navigatorElements() {
    return this.props.application.navigator.menuItems().filter((item)=>{
      return item.type === "subheader";
    }).map((item) => {
      return <Link key={item.route} to={item.route}>
        <FormattedMessage id={`viewmodel.Navigation.${item.labelId}`} />
      </Link>;
    });
  }
}
Frame.propTypes =  {
  application: React.PropTypes.object.isRequired
};
Frame.childContextTypes = {
  application:         React.PropTypes.object.isRequired,
  windowResizeManager: React.PropTypes.object
};
Frame.contextTypes = {
  router: React.PropTypes.object
};

export default injectIntl(Frame);
