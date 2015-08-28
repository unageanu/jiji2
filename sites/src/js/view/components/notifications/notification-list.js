import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"
import LoadingImage         from "../widgets/loading-image"

const List   = MUI.List;

const keys = new Set([
  "items", "selectedNotification"
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
      return <div className="info">未読の通知はありません</div>;
    }
    return <List style={{paddingTop:0}}>{this.createListItems()}</List>;
  }
  createListItems() {
    return this.state.items.map((notification, index) => {
       return <NotificationListItem
          key={index}
          notification={notification}
          innerDivStyle={this.props.innerDivStyle}
          selected={this.props.selectable && this.state.selectedIndex === index } /> ;
    });
  }

}
NotificationList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectable: React.PropTypes.bool.isRequired,
  innerDivStyle: React.PropTypes.object,
};
NotificationList.defaultProp = {
  innerDivStyle: {}
};
