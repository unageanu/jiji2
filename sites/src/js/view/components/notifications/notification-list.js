import React          from "react"
import { injectIntl } from 'react-intl';

import AbstractList         from "../widgets/abstract-list"
import NotificationListItem from "./notification-list-item"

class NotificationList extends AbstractList {

  constructor(props) {
    super(props);
    this.state = {};
  }

  get className() {
    return "notification-list";
  }
  get emptyLabel() {
    const { formatMessage } = this.props.intl;
    return formatMessage({ id: 'notifications.NotificationList.noUnread' });
  }
  createListItem(notification, index) {
    return <NotificationListItem
      key={index}
      notification={notification}
      onTouchTap={this.createAction(notification)}
      selected={
        this.state.selectedId === notification.id
      } />;
  }

  createAction(notification) {
    return (ev) => {
      this.context.router.push({
        pathname: "/notifications/"+notification.id
      });
      ev.preventDefault();
    };
  }
}
NotificationList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectionModel: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string,
  autoFill: React.PropTypes.bool
};
NotificationList.defaultProps = {
  selectionModel: null,
  emptyLabel: "",
  autoFill: false
};
NotificationList.contextTypes = {
  router: React.PropTypes.object,
  windowResizeManager: React.PropTypes.object
};
export default injectIntl(NotificationList);
