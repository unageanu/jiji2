import React                from "react"
import { injectIntl }       from 'react-intl';

import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"
import LoadingImage         from "../widgets/loading-image"

import {List, ListItem} from "material-ui/List"
import FlatButton from "material-ui/FlatButton"
import DropDownMenu from "material-ui/DropDownMenu"
import MenuItem     from 'material-ui/MenuItem'
import IconButton from "material-ui/IconButton"
import FontIcon from "material-ui/FontIcon"

const keys = new Set([
  "hasNext", "hasPrev", "availableFilterConditions",
  "filterCondition", "selectedCondition",
  "loading"
]);

class NotificationListMenuBar extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = { selectedCondition: "all" };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    state.selectedCondition = "all";
    this.setState(state);
  }

  render() {
    return <div className="notification-list-menu-bar ">
      <DropDownMenu
        style={{width:"256px"}}
        value={this.state.selectedCondition}
        onChange={this.onChange.bind(this)}>
        {this.createMenuItems()}
      </DropDownMenu>
      <div className="buttons">
        {this.createButtons()}
      </div>
    </div>;
  }

  createMenuItems() {
    const { formatMessage } = this.props.intl;
    return this.state.availableFilterConditions.map((item) => {
      return <MenuItem key={item.id}
        value={item.id} primaryText={item.text || formatMessage({id:'viewmodel.NotificationTableModel.' + item.id }) } />
    });
  }

  createButtons() {
    const { formatMessage } = this.props.intl;
    const prev = () => this.props.model.prev();
    const next = () => this.props.model.next();
    return [
      <IconButton
        key="prev"
        tooltip={formatMessage({ id: 'common.action.prev'}, {size: this.props.model.pageSize})}
        disabled={this.state.loading || !this.state.hasPrev}
        onClick={prev}>
        <FontIcon className="md-navigate-before"/>
      </IconButton>,
      <IconButton
        key="next"
        tooltip={formatMessage({ id: 'common.action.next'}, {size: this.props.model.pageSize})}
        disabled={this.state.loading || !this.state.hasNext}
        onClick={next}>
        <FontIcon className="md-navigate-next"/>
      </IconButton>
    ];
  }
  onChange(e, selectedIndex, payload) {
    const item = this.state.availableFilterConditions
      .find( (item) => item.id == payload );
    this.props.model.filter(item.condition);
    this.setState({selectedCondition: payload});
  }
}
NotificationListMenuBar.propTypes = {
  model: React.PropTypes.object.isRequired
};

export default  injectIntl(NotificationListMenuBar);
