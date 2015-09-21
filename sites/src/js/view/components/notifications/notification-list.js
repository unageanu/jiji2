import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"
import LoadingImage         from "../widgets/loading-image"

const List   = MUI.List;

const keys = new Set([
  "items", "selectedNotification",  "selectedNotificationId"
]);

export default class NotificationList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    if (this.state.items == null) {
      return <div className="info"><LoadingImage /></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="info">{this.props.emptyLabel}</div>;
    }
    return <List
      className="list"
      style={{
        paddingTop:0,
        backgroundColor: "rgba(0,0,0,0)"}}>
        {this.createListItems()}
    </List>;
  }
  createListItems() {
    return this.state.items.map((notification, index) => {
      const touchAction = this.props.selectable
        ? () => this.context.router.transitionTo("/notifications/"+notification.id)
        : () => {};
      return <NotificationListItem
        key={index}
        notification={notification}
        innerDivStyle={this.props.innerDivStyle}
        selected={
          this.props.selectable
          && this.state.selectedNotificationId === notification.id
        }
        onTouchTap={touchAction} /> ;
    });
  }

}
NotificationList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectable: React.PropTypes.bool.isRequired,
  innerDivStyle: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string
};
NotificationList.defaultProps = {
  innerDivStyle: {},
  emptyLabel: "未読の通知はありません"
};
NotificationList.contextTypes = {
  router: React.PropTypes.func
};
