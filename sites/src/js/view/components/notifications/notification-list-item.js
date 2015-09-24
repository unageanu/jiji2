import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import TextInRadius        from "../widgets/text-in-radius"
import Theme               from "../../theme"
import MobileListItem      from "../widgets/mobile/list-item"

const Avatar     = MUI.Avatar;
const ListItem   = MUI.ListItem;

const nullNotification = {
};

export default class NotificationListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const notification = this.props.notification || nullNotification;
    const props = {
      className: "list-item",
      innerDivStyle : Object.assign({
        paddingRight:"72px",
        backgroundColor: this.props.selected
          ? Theme.getPalette().backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }, this.props.innerDivStyle),
      leftAvatar: this.createAvatar(notification),
      primaryText: this.createPrimaryText(notification),
      secondaryText: this.createSecondaryText(notification),
      secondaryTextLines: 2,
      onTouchTap: this.props.onTouchTap,
      rightIcon: this.createRightIcon(notification)
    };
    return this.props.mobile
      ? <MobileListItem {...props} />
      : <ListItem {...props} />;
  }
  createPrimaryText(notification) {
    return <span
      className={"primary-text " + (!notification.readAt ? "not-read" : "" )}>
      {notification.message}
    </span>;
  }
  createSecondaryText(notification) {
    const content = [];
    if ( notification.formatedTimestamp != null ) {
      content.push( <div>{notification.formatedTimestamp}</div> );
    }
    if ( notification.agent && notification.agent.name != null ) {
      content.push( <div>{notification.agentAndBacktestName}</div> );
    }
    return <div>{content}</div>;
  }
  createRightIcon(notification) {
      if (notification.readAt) return null;
      return <span className="right-icon" style={{width:"auto"}}>
        <TextInRadius text="未読" />
      </span>;
  }
  createAvatar(notification) {
    return <Avatar className="left-icon" src={notification.agentIconUrl} />
  }
}
NotificationListItem.propTypes = {
  notification: React.PropTypes.object,
  selected: React.PropTypes.bool,
  innerDivStyle: React.PropTypes.object,
  onTouchTap: React.PropTypes.func,
  mobile: React.PropTypes.bool
};
NotificationListItem.defaultProps = {
  notification: null,
  selected: false,
  innerDivStyle: {},
  onTouchTap: null,
  mobile: false
};
