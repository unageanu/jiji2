import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import TextInRadius        from "../widgets/text-in-radius"

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
        innerDivStyle={
          Object.assign({ paddingRight:"72px"}, this.props.innerDivStyle)
        }
        leftAvatar={this.createAvatar(notification)}
        primaryText={notification.message}
        secondaryText={this.createSecondaryText(notification)}
        rightIcon={this.createRightIcon(notification)} />
    );
  }
  createPrimaryTextt(notification) {
    return <span className="primary-text">{this.notification.message}</span>;
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
  innerDivStyle: React.PropTypes.object
};
NotificationListItem.defaultProps = {
  notification: null,
  selected: false,
  innerDivStyle: {}
};
