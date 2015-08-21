import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const ListItem   = MUI.ListItem;
const Avatar     = MUI.Avatar;

const nullNotification = {
};

export default class NotificationListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const notification = this.props.notification || nullNotification;
    return (
      <ListItem
        leftAvatar={this.createAvatar(notification)}
        primaryText={notification.message}
        secondaryText={this.createSecondaryText(notification)} />
    );
  }

  createSecondaryText(notification) {
    let result = "";
    if ( notification.formatedTimestamp != null ) {
      result += notification.formatedTimestamp;
    }
    if ( notification.agent && notification.agent.name != null ) {
      result += (result ? " - " : "") + notification.agent.name;
    }
    return result;
  }
  createAvatar(notification) {
    return <Avatar src={this.createIconUrl(notification)} />
  }
  createIconUrl(notification) {
    const iconId = notification.agent ? notification.agent.iconId : null;
    return "/api/icon-images/" + (iconId || "default");
  }
}
NotificationListItem.propTypes = {
  notification: React.PropTypes.object,
  selected: React.PropTypes.bool
};
NotificationListItem.defaultProp = {
  notification: null,
  selected: false
};
