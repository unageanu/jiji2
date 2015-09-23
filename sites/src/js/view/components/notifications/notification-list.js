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

    if (this.props.autoFill) this.registerAutoFillHandler();
  }

  render() {
    if (this.state.items == null) {
      return <div className="info"><LoadingImage /></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="info">{this.props.emptyLabel}</div>;
    }
    const filling = this.state.filling
      ? <div className="info"><LoadingImage /></div> : null;
    return <div>
      <List
        className="list"
        style={{
          paddingTop:0,
          backgroundColor: "rgba(0,0,0,0)"}}>
          {this.createListItems()}
      </List>
      {filling}
    </div>;
  }
  createListItems() {
    return this.state.items.map((notification, index) => {
      return <NotificationListItem
        key={index}
        notification={notification}
        onTouchTap={this.createAction(notification)}
        mobile={this.props.mobile}
        innerDivStyle={this.props.innerDivStyle}
        selected={
          this.props.selectable
          && this.state.selectedNotificationId === notification.id
        } />;
    });
  }

  createAction(notification) {
    if (this.props.selectable) {
      return (ev) => {
        this.context.router.transitionTo("/notifications/"+notification.id);
        ev.preventDefault();
      };
    } else {
      return null;
    }
  }

  registerAutoFillHandler() {
    this.context.windowResizeManager.addObserver("scrolledBottom", () => {
      if ( this.filling || !this.props.model.hasNext ) return;
      this.setState({filling: true});
      this.filling = true;
      this.props.model.fillNext().always(() => {
        this.filling = false;
        this.setState({filling: false});
      });
    });
  }

}
NotificationList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectable: React.PropTypes.bool.isRequired,
  innerDivStyle: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string,
  autoFill: React.PropTypes.bool,
  mobile: React.PropTypes.bool
};
NotificationList.defaultProps = {
  innerDivStyle: {},
  emptyLabel: "未読の通知はありません",
  autoFill: false,
  mobile: false
};
NotificationList.contextTypes = {
  router: React.PropTypes.func,
  windowResizeManager: React.PropTypes.object
};
