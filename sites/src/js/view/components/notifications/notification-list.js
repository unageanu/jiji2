import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"

const List   = MUI.List;

export default class NotificationList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    const state = this.collectInitialState(this.props.model,
      "items", "selectedNotification");
    this.setState(state);
  }

  render() {
    return (
      <List>{this.createListItems()}</List>
    );
  }

  createListItems() {
    if (this.state.items == null) return [];
    return this.state.items.map((notification, index) => {
       return <NotificationListItem
          key={index}
          notification={notification}
          selected={this.props.selectable && this.state.selectedIndex === index } /> ;
    });
  }

}
NotificationList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectable: React.PropTypes.bool.isRequired
};
