import React                from "react"
import MUI                  from "material-ui"
import AbstractList         from "../widgets/abstract-list"
import NotificationListItem from "./notification-list-item"

export default class NotificationList extends AbstractList {

  constructor(props) {
    super(props);
    this.state = {};
  }

  get className() {
    return "notification-list";
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
      this.context.router.transitionTo("/notifications/"+notification.id);
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
  emptyLabel: "未読の通知はありません",
  autoFill: false
};
NotificationList.contextTypes = {
  router: React.PropTypes.func,
  windowResizeManager: React.PropTypes.object
};
