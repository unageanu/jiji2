import React                   from "react"
import MUI                     from "material-ui"
import AbstractPage            from "./abstract-page"
import NotificationList        from "../notifications/notification-list"
import NotificationListMenuBar from "../notifications/notification-list-menu-bar"
import NotificationDetailsView from "../notifications/notification-details-view"

export default class NotificationsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize(this.props.params.id);
  }

  componentWillReceiveProps(nextProps) {
    this.model().notificationsTable.selectedNotificationId = nextProps.params.id;
  }

  render() {
    return (
      <div className="notifications-page">
        <div className="list-panel">
          <NotificationListMenuBar
            model={this.model().notificationsTable}
            />
          <NotificationList
            model={this.model().notificationsTable}
            emptyLabel="通知はありません"
            selectable={true} />
        </div>
        <div className="details-panel">
          <NotificationDetailsView
            model={this.model().notificationsTable}
          />
        </div>
      </div>
    );
  }

  model() {
    return this.context.application.notificationsPageModel;
  }
}
NotificationsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
