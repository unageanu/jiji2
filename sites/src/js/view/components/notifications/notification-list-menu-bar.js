import React                from "react"

import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"
import LoadingImage         from "../widgets/loading-image"

import {List, ListItem} from "material-ui/List"
import FlatButton from "material-ui/FlatButton"
import DropDownMenu from "material-ui/DropDownMenu"
import IconButton from "material-ui/IconButton"
import FontIcon from "material-ui/FontIcon"

const keys = new Set([
  "hasNext", "hasPrev", "availableFilterConditions",
  "filterCondition", "selectedConditionIndex",
  "loading"
]);

export default class NotificationListMenuBar extends AbstractComponent {

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
    return <div className="notification-list-menu-bar ">
      <DropDownMenu
        style={{width:"256px"}}
        menuItems={this.state.availableFilterConditions}
        selectedIndex={this.state.selectedConditionIndex}
        onChange={this.onChange.bind(this)}/>
      <div className="buttons">
        {this.createButtons()}
      </div>
    </div>;
  }

  createButtons() {
    const prev = () => this.props.model.prev();
    const next = () => this.props.model.next();
    return [
      <IconButton
        key="prev"
        tooltip={"前の" + this.props.model.pageSize +  "件"}
        disabled={this.state.loading || !this.state.hasPrev}
        onClick={prev}>
        <FontIcon className="md-navigate-before"/>
      </IconButton>,
      <IconButton
        key="next"
        tooltip={"次の" + this.props.model.pageSize +  "件"}
        disabled={this.state.loading || !this.state.hasNext}
        onClick={next}>
        <FontIcon className="md-navigate-next"/>
      </IconButton>
    ];
  }
  onChange(e, selectedIndex, menuItem) {
    const item = this.state.availableFilterConditions[selectedIndex];
    this.props.model.filter(item.condition);
    this.setState({selectedConditionIndex: selectedIndex});
  }
}
NotificationListMenuBar.propTypes = {
  model: React.PropTypes.object.isRequired
};
