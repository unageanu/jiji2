import React               from "react"
import { injectIntl }      from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import TextInRadius        from "../widgets/text-in-radius"
import Theme               from "../../theme"
import Environment         from "../../environment"

import Avatar from "material-ui/Avatar"
import {List} from "material-ui/List"

const nullNotification = {
};

class NotificationListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const notification = this.props.notification || nullNotification;
    const props = {
      className: "list-item",
      innerDivStyle : Object.assign( {}, Theme.listItem.innerDivStyle, {
        paddingRight:"72px",
        backgroundColor: this.props.selected
          ? Theme.palette.backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }),
      leftAvatar: this.createAvatar(notification),
      primaryText: this.createPrimaryText(notification),
      secondaryText: this.createSecondaryText(notification),
      secondaryTextLines: 2,
      onTouchTap: this.props.onTouchTap,
      rightIcon: this.createRightIcon(notification)
    };
    return Environment.get().createListItem(props);
  }
  createPrimaryText(notification) {
    return <div
      className={"primary-text " + (!notification.readAt ? "not-read" : "" )}>
      {notification.message}
    </div>;
  }
  createSecondaryText(notification) {
    const { formatMessage } = this.props.intl;
    const content = [];
    if ( notification.formattedTimestamp != null ) {
      content.push( <div key="time">{notification.formattedTimestamp}</div> );
    }
    if ( notification.agent && notification.agent.name != null ) {
      content.push( <div key="agentName">{notification.getAgentAndBacktestName(formatMessage)}</div> );
    }
    return <div>{content}</div>;
  }
  createRightIcon(notification) {
      const { formatMessage } = this.props.intl;
      if (notification.readAt) return null;
      return <span className="right-icon" style={{width:"auto"}}>
        <TextInRadius text={formatMessage({ id: 'notifications.NotificationListItem.unread' })} />
      </span>;
  }
  createAvatar(notification) {
    return <Avatar className="left-icon" src={notification.agentIconUrl} />
  }
}
NotificationListItem.propTypes = {
  notification: React.PropTypes.object,
  selected: React.PropTypes.bool,
  onTouchTap: React.PropTypes.func
};
NotificationListItem.defaultProps = {
  notification: null,
  selected: false,
  onTouchTap: null
};

export default injectIntl(NotificationListItem)
